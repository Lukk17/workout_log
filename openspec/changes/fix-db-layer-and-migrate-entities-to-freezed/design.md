## Context

After proposal #1, the toolchain is current. The DB layer in `lib/util/dbProvider.dart` still has correctness bugs and mixes data access, business logic, JSON-backup, and seed data in one 380-line file. Entities use hand-rolled `toMap`/`fromMap`/`toString`/JSON serializers with `Map<dynamic, dynamic>` field types — fragile to refactor and the source of every `Map<String, dynamic>` warning the analyzer will surface later.

`BodyPart` is a `SCREAMING_CASE` Dart 2-era enum (`enum BodyPart { CHEST, BACK, ARM, LEG, ABDOMINAL, CARDIO, UNDEFINED }`) with a 60-line custom string switch for serialization. Effective Dart wants `lowerCamelCase` enum members, and modern Dart provides `Enum.name` + `<EnumType>.values.byName(s)` out of the box.

The Riverpod migration (proposal #3) consumes immutable domain models. Doing freezed here lets #3 expose `AsyncValue<List<WorkLog>>` over real value types instead of "mutable class with public setters".

## Goals / Non-Goals

**Goals:**
- DB layer is correct: no fire-and-forget seed loop, no hard-coded table-name literals, no N+1 dedup scans, has `onUpgrade`.
- `WorkLog`, `Exercise` are immutable freezed classes with generated `toJson`/`fromJson`, `copyWith`, value equality, and `toString`.
- `BodyPart` renamed to lowerCamelCase, switch-based serializer collapsed to 4 lines.
- DB unit tests cover golden + error paths via `sqflite_common_ffi`.
- Existing on-device DBs from prior app versions continue to load unchanged.
- `lib/data/db/` carved out from `lib/util/`.

**Non-Goals:**
- No Riverpod yet (proposal #3).
- No full `data/domain/presentation` reorg (proposal #4 finishes it).
- No UI refactor (proposal #4).
- No DB schema change. `version` bumps to 2 only to install the `onUpgrade` hook; the migration is a no-op.
- No `BodyPart.undefined` removal (kept for legacy on-device rows).

## Decisions

### D1 — Freezed over hand-rolled immutability

**Decision**: Use `freezed` + `freezed_annotation` for `WorkLog` and `Exercise`. Keep `json_serializable` integration via `@Freezed(toJson: true, fromJson: true)`.

**Rationale**: `freezed` is the de-facto standard for immutable Dart data classes. It auto-generates `copyWith`, `==`, `hashCode`, `toString`, and pattern-matchable unions if we ever want a discriminated `WorkoutSet` later. Hand-rolling these in 2026 is regression.

**Alternative considered**: `dart_mappable`. Rejected — smaller ecosystem, less common in Flutter codebases.

### D2 — `BodyPart` rename strategy

**Decision**: Rename enum members to lowerCamelCase (`BodyPart.chest`, `BodyPart.back`, …). Serialize via `b.name` (returns `"chest"`, `"back"`, …). Deserialize via `BodyPart.values.byName(s)` with a `try/catch` falling back to `BodyPart.undefined`.

**On-disk backward compatibility**: Existing DBs store the OLD strings (`"CHEST"`, `"BACK"`, …). The deserializer SHALL accept both forms via a `.toLowerCase()` before `byName` — covered by a unit test loading a fixture row with `"CHEST"`.

**Rationale**: Effective Dart compliance. `name` / `values.byName` is built-in and drops 60 lines of switch.

**Alternative considered**: Keep `SCREAMING_CASE` and silence the lint. Rejected — global rule #1 forbids silencing lints to avoid work.

### D3 — DB layer split

**Decision**: Move `DBProvider` to `lib/data/db/db_provider.dart` but do NOT split into `WorkLogDao` + `ExerciseDao` yet. That's a proposal #3-time decision once Riverpod providers exist to consume them.

**Rationale**: One refactor per proposal. Splitting DAOs without a consumer to depend on them is premature.

### D4 — `onUpgrade` strategy

**Decision**: Bump `version: 1` → `version: 2`. Add `onUpgrade: (db, oldV, newV) async { /* no-op for 1→2 */ }`. Document the migration pattern in a `// CONVENTION:` comment block at the top of the file (NOT inline rationale — this is a how-to, allowed per `.claude/CLAUDE.md`'s carve-out for module-local conventions; alternatively move to `docs/architecture/`).

**Rationale**: Installing the hook now means the next proposal that changes the schema can `if (oldV < 3) await db.execute(...)` instead of bricking installs.

### D5 — `series` / `load` typing

**Decision**: Change `Map<dynamic, dynamic>` to `Map<String, String>` in the in-memory model. Serializer continues to store as JSON string in the sqflite cell. `getRepsSum` becomes `series.values.fold(0, (s, v) => s + int.parse(v))`.

**Rationale**: Typed at the boundary. `dynamic` was a 2019-era workaround; freezed + json_serializable handle generic maps fine.

**Alternative considered**: Normalize into a `WorkLogSet` row per set (real schema). Rejected — too much scope; would require a real migration. Park as a follow-up proposal.

### D6 — Test infrastructure

**Decision**: Add `sqflite_common_ffi` as a dev dep. Initialize FFI in `test/test_helper.dart`. Use real sqflite for DB tests, not mocks.

**Rationale**: Matches the global rule about not mocking DBs that have ever surprised us, and `sqflite_common_ffi` is the project-standard approach for testing sqflite code on dev machines.

### D7 — Path of partial folder restructure

**Decision**: Only `dbProvider.dart` moves in this proposal. `entity/*.dart` stays at `lib/entity/` for now; will move to `lib/domain/models/` in proposal #4.

**Rationale**: Moving entity files in this proposal would compound the diff (every file already touched for `BodyPart` rename would also move). Defer.

## Risks / Trade-offs

- **[Risk]** `BodyPart` rename breaks deserialization of existing on-device rows → **Mitigation**: D2 explicitly supports both cases; unit test covers a fixture row containing `"CHEST&"`.
- **[Risk]** Freezed regeneration churn buries real bugs in the diff → **Mitigation**: `*.freezed.dart` and `*.g.dart` reviewed once and committed separately within this proposal.
- **[Risk]** Switching `series`/`load` from `dynamic` to `String` breaks an existing row with non-string values → **Mitigation**: defensive `jsonDecode(...) as Map<String, dynamic>` then `.map((k, v) => MapEntry(k.toString(), v.toString()))` on read. Unit test with a hostile fixture.
- **[Risk]** `editExercise` / `updateExercise` consolidation changes behavior subtly → **Mitigation**: dedicated unit tests covering each method's documented semantics (additive `addAll` vs. full replace) before consolidating.
- **[Risk]** `onUpgrade` no-op runs on existing installs because version bumps 1 → 2 → **Mitigation**: this is the intended path; the hook is empty so it's harmless. Documented in commit message.

## Migration Plan

1. **Phase A — Test scaffolding first** (TDD): add `sqflite_common_ffi`, write tests for current behavior of `getAllExercise`, `newWorkLog`, `editExercise`, `backup`/`restore`, `BodyPart` `"CHEST"` deserialization. Confirm they pass against the current code.
2. **Phase B — DB correctness fixes**: await seed loop, table-name constants, `newWorkLog` dedup query, `getWorkLogByID` typing, `backup` dead-map removal, `onUpgrade` stub, `editExercise`/`updateExercise` consolidation, external-storage try/catch. Tests must stay green.
3. **Phase C — Entity migration**: introduce freezed deps, convert `Exercise` and `WorkLog` to freezed, switch `BodyPart` to lowerCamelCase, collapse the serializer. Update every call-site. Tests must stay green.
4. **Phase D — File move**: `lib/util/dbProvider.dart` → `lib/data/db/db_provider.dart`. Update imports.
5. **Phase E — Smoke test on emulator** with a DB copied from an existing v1.2.3 install (simulate upgrade).
6. **Phase F — Commit sequence** (per global rule, split into multiple commits within this proposal): one for test infra + behavior-preserving tests, one for DB fixes, one for freezed + BodyPart rename, one for file move.

**Rollback**: each commit reverts independently; freezed/test commits don't change runtime behavior, only the DB-correctness commit does.

## Open Questions

- Q1: Should `WorkLog.created` migrate from `DateTime` (with sub-day precision) to `DateOnly`/`String` (since the schema column is YYYY-MM-DD)? **Punted to proposal #3** — affects Riverpod provider keying.
- Q2: Should `secondaryBodyParts` default `{}` move to a freezed default constructor argument? **Yes**, decided in this proposal.

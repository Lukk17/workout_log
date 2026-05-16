## Why

`lib/util/dbProvider.dart` has real correctness bugs: the `onCreate` seed loop is fire-and-forget (race on first launch), `newWorkLog` does an N+1 + linear scan in Dart to detect duplicates, three query methods hard-code the table name `"worklog"` instead of using the `workLogTable` constant (works only because Android sqflite is case-insensitive), `backup()` builds an unused `jsons` map then writes a different value, `getWorkLogByID` takes `int` but the schema PK is `VARCHAR(32)` (dead code path), and there is no `onUpgrade` handler — the first schema change after release will brick existing installs. The `Exercise` enum serializer is a 60-line hand-rolled switch on a magic `"&"` separator that could be 4 lines using `BodyPart.values.byName(s)`. `WorkLog.series` and `WorkLog.load` are typed as `Map<dynamic, dynamic>` and round-tripped through JSON strings inside SQLite cells, which forces every read to `jsonDecode` and every aggregate (`getRepsSum`) to runtime-parse. Migrating both entities to **freezed** eliminates the hand-rolled `toMap`/`fromMap`/`toString` boilerplate, gives us immutability + `copyWith` + value equality, and is the precondition for the Riverpod migration in proposal #3 (providers should expose immutable value types).

## What Changes

- **DB correctness fixes** in `lib/util/dbProvider.dart`:
  - `onCreate` seed loop: `await` every `db.insert` instead of fire-and-forget `forEach`.
  - Replace hard-coded `"worklog"` literals in `getWorkLogByID`, `getDateAllWorkLogs`, `getDateBodyPartWorkLogs` with the `workLogTable` constant. Same for `"exercise"` → `exerciseTable` in `getExerciseByID`, `getAllExercise`.
  - Replace the linear-scan dedup in `newWorkLog` with `SELECT id FROM $exerciseTable WHERE name = ? LIMIT 1`.
  - Add an `onUpgrade` stub that bumps `version: 1` → `version: 2` with a no-op delta, plus a documented pattern for future migrations.
  - Delete the unused `Map<String, dynamic> jsons` block in `backup()`.
  - Change `getWorkLogByID(int id)` → `getWorkLogByID(String id)` to match the schema (or delete it — no callers found in the current codebase).
  - Make `backup()`, `restore()`, `deleteWorkLog()`, `close()` return `Future<void>` and await at call sites in `helloWorldView.dart` / `workLogPageView.dart` / `backupView.dart`.
  - Wrap `getExternalStorageDirectory()` in a try/catch and surface a SnackBar on failure (security/robustness — devices may not expose external storage).
  - Extract the two near-identical `updateExercise` / `editExercise` methods into one parameterized method.
- **Entity migration to freezed**:
  - Add `freezed`, `freezed_annotation` dev deps; regenerate.
  - Convert `WorkLog` and `Exercise` to freezed data classes — immutable, `copyWith`, value equality, generated `toJson`/`fromJson` via `json_serializable`.
  - **BREAKING** (internal): `WorkLog.series` and `WorkLog.load` change from `Map<dynamic, dynamic>` to `Map<String, String>`. Stored as JSON strings in sqflite as today; typed in memory.
  - **BREAKING** (internal): `BodyPart` enum renamed from `SCREAMING_CASE` (`CHEST`, `BACK`, …) to `lowerCamelCase` (`chest`, `back`, …). Add `BodyPart.undefined` last for the deprecated catch-all.
  - Replace the 60-line `Exercise.recreateBodyPart` switch + `bodyPartsToString` with `BodyPart.values.byName(s)` + `bodyParts.map((b) => b.name).join('&')`.
  - Preserve the `"&"` separator format so existing on-device DBs deserialize unchanged.
- **DB unit tests** under `test/data/db/`:
  - Use `sqflite_common_ffi` to run sqflite on the dev machine.
  - Cover: seed inserts complete before `database` getter returns; `newWorkLog` dedup; `editExercise` / `updateExercise` semantics; `backup` → `restore` roundtrip; `getDateAllWorkLogs` with multiple dates; v1 IDs from existing installs read back unchanged.
  - Both golden-path and error-path scenarios per the global "do the good job" rule.
- **Folder restructure (partial)**: move `lib/util/dbProvider.dart` → `lib/data/db/db_provider.dart` and rename to `lower_snake_case.dart`. Other `util/*` files stay until proposal #4.

Depends on: proposal #1 (upgrade-deps-and-codegen) being merged for the newer `build_runner` + `json_serializable`.

## Capabilities

### New Capabilities

- `workout-persistence`: The contract for how workouts and exercises are stored, retrieved, updated, deleted, backed up, and restored from the local sqflite database. Covers `onCreate`, `onUpgrade`, dedup semantics, transactional guarantees on seed data, and JSON backup roundtrip.
- `domain-models`: The contract for `WorkLog`, `Exercise`, and `BodyPart` value types — immutability, equality, JSON serialization, and the `BodyPart` enum naming convention.

### Modified Capabilities

- `entity-identifiers` (from proposal #1): MODIFIED to clarify that IDs are immutable on `WorkLog` / `Exercise` once constructed (enforced by freezed).

## Impact

- **Affected files**: `pubspec.yaml`, `lib/entity/*.dart` (full rewrite), `lib/util/dbProvider.dart` → `lib/data/db/db_provider.dart`, every caller of `BodyPart.CHEST`/etc (view files: `helloWorldView.dart`, `workLogPageView.dart`, `exerciseManipulationView.dart`, `exerciseView.dart`, `calendarView.dart`, `backupView.dart`, `exerciseListView.dart`, `util.dart`), `test/data/db/*.dart` (new).
- **Data**: No DB schema change. `BodyPart` rename uses `.name` which preserves the existing `"CHEST"` / `"BACK"` strings on disk via the existing `"&"` serializer — verify backward compat in a unit test.
- **Risk**: Largest. Freezed migration touches every file that constructs an entity. Cross-cutting `BodyPart` rename touches ~10 files. Manual smoke test on a real DB from a prior install is mandatory before merge.
- **Downstream**: Unblocks proposal #3 (Riverpod providers expose freezed types).

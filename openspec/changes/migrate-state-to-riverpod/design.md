## Context

After proposals #1 and #2, the app has current deps, immutable freezed entities, a correct DB layer, and DB tests. State sharing remains the largest source of latent bugs: `Util.rebuild`, static `HelloWorldView.date`, static `AppThemeSettings.theme`, and `AppBuilder.of(context)?.rebuild()`. Every screen does `setState` after `await` without a `mounted` check.

Riverpod is the canonical state-management choice for new Flutter code (recommended by `dart-flutter-patterns` and `flutter-architecture` skills). Two viable framework alternatives — BLoC and vanilla `ChangeNotifier` + `Provider` — were considered and rejected (see D1).

## Goals / Non-Goals

**Goals:**
- Zero global mutable state in app code. `AppBuilder`, `Util.rebuild`, `HelloWorldView.date`, mutable static `AppThemeSettings.theme` are deleted.
- Theme mode and background image preference flow through Riverpod and `SharedPreferences`, applied via `MaterialApp.themeMode`.
- Workout-list and exercise-list data flow through `FutureProvider` / `FutureProvider.family`. Mutations invalidate the relevant provider; UI rebuilds via `ref.watch`.
- Every screen converted to `ConsumerWidget` / `ConsumerStatefulWidget`.
- `BuildContext` access after `await` is guarded by `if (!context.mounted) return;`.
- DB layer split into per-aggregate DAOs behind providers.
- Widget tests for the three primary screens with fake DAO overrides.

**Non-Goals:**
- No new features.
- No styling / design changes (proposal #4 handles UI cleanup).
- No file renames beyond the moves listed in the proposal.
- No Riverpod 3.0 features (using current stable 2.x).
- No code-generation Riverpod for trivial providers; `riverpod_generator` used only where it improves readability.

## Decisions

### D1 — Riverpod over BLoC / Provider

**Decision**: `flutter_riverpod` 2.x.

**Rationale**:
- Single-developer codebase, ~6 pieces of shared state. BLoC's event/state ceremony is overkill.
- `FutureProvider.family` matches `workLogsByDate(DateTime)` exactly — no hand-rolled cache invalidation.
- Compile-time provider safety vs. `Provider`'s runtime `context.read` lookup failures.
- Skill `dart-flutter-patterns` lists Riverpod as the default recommendation.

**Alternatives**:
- **BLoC**: rejected — too much ceremony for this scale.
- **`ChangeNotifier` + `Provider`**: rejected — Riverpod's typed `ref` and provider composition are strictly better, and the migration cost is identical.
- **`signals_flutter`**: rejected — smaller ecosystem.

### D2 — Theme application

**Decision**: Two top-level `ThemeData` constants (`lightTheme`, `darkTheme`). `MaterialApp.themeMode: ref.watch(themeModeProvider)`. Colors moved into the `ThemeData.colorScheme` properly (no more `AppThemeSettings.buttonColor` etc. — use `Theme.of(context).colorScheme.primary`).

**Rationale**: Material 3 idiomatic. Eliminates the mutating-static-fields pattern entirely. Side effect: a real material-design system review (skill `design-system`) becomes possible.

**Risk**: Bigger blast radius — every `AppThemeSettings.XYZColor` call site (~150) gets touched. **Mitigation**: stage in one commit, smoke-test theme toggle.

### D3 — `selectedDateProvider` type

**Decision**: `StateProvider<DateTime>` whose value is the start-of-day (`DateTime(year, month, day)`) in device-local time.

**Rationale**: The sqflite `created` column is `YYYY-MM-DD`, so day-precision is what queries match. Storing a full `DateTime` in the provider hides the truncation and creates aliasing bugs ("Today" vs "Today at 03:42").

### D4 — DB layer split

**Decision**: Three classes — `WorkLogDao`, `ExerciseDao`, `BackupService`. All take an injected `Future<Database>` (so tests can override).

**Rationale**: Riverpod providers now consume DAOs. One-DAO-per-aggregate matches the data shape. Splitting now (after #2) is incremental; doing it during #2 would compound the diff.

### D5 — `mounted` check pattern

**Decision**: After every `await` that's followed by a `BuildContext` use, insert:
```dart
if (!context.mounted) return;
```
For Navigator/ScaffoldMessenger, prefer capturing the `Navigator.of(context)` / `ScaffoldMessenger.of(context)` reference BEFORE the `await` when possible.

**Rationale**: Flutter `BuildContext` is single-frame-valid after dispose. Currently the codebase has ~12 unguarded post-await context uses (e.g. `exerciseManipulationView.dart:387`).

### D6 — Code-generation vs hand-written providers

**Decision**: Hand-write providers. Skip `riverpod_generator` for this proposal.

**Rationale**: Adding another codegen system increases build time and onboarding cost. The providers in this app are simple enough that the `@riverpod` annotations save little. Revisit if provider count grows past ~20.

### D7 — Widget caching

**Decision**: Delete `_wList` and `_exerciseList` widget lists. Build from `ListView.builder` driven by `ref.watch(workLogsByDateProvider(date))`.

**Rationale**: Caching `Widget` instances in state is anti-pattern. `ref.watch` + `ListView.builder` is idiomatic Flutter.

### D8 — Provider invalidation vs StateNotifier mutation

**Decision**: For lists fetched from DB, use `FutureProvider` and `ref.invalidate(...)` after mutations. Do NOT model the list as a `StateNotifier<List<WorkLog>>`.

**Rationale**: DB is the source of truth. `StateNotifier` would force us to sync two stores. `invalidate` triggers a re-fetch — simpler, less drift.

## Risks / Trade-offs

- **[Risk]** `MaterialApp` rebuild on theme change re-creates the entire widget tree → **Mitigation**: that's the same blast radius as the current `AppBuilder.rebuild()`. No regression.
- **[Risk]** `ref.invalidate` causes flicker between old and new list states → **Mitigation**: use `previous` argument in `AsyncValue.when` (`(prev) => prev ?? const CircularProgressIndicator()`) for graceful transitions.
- **[Risk]** Tests with `ProviderScope` overrides become verbose → **Mitigation**: provide a `testProviderScope({WorkLogDao? workLogDao, ExerciseDao? exerciseDao})` helper in `test/helpers/`.
- **[Risk]** Moving theme to `ThemeData.colorScheme` changes some specific colors → **Mitigation**: capture screenshots of every screen pre-migration; diff post-migration; reject deltas not explicitly intended.

## Migration Plan

1. **Phase A — Riverpod scaffolding**: add deps, wrap `MyApp` in `ProviderScope`, no behavior change yet. Smoke-test.
2. **Phase B — Theme migration**: introduce `themeModeProvider` + `backgroundImageProvider`, convert `MaterialApp`. Delete `AppBuilder`. Refactor `AppThemeSettings` to two `ThemeData` constants + colorScheme usage at call sites.
3. **Phase C — Selected date migration**: introduce `selectedDateProvider`, update `CalendarView`, `WorkLogPageView`, DB date queries to read from provider. Delete `HelloWorldView.date` static + `Util.rebuild` static.
4. **Phase D — DB DAO split**: introduce `WorkLogDao`, `ExerciseDao`, `BackupService` + their providers. Delete `DBProvider` class.
5. **Phase E — Async data providers**: `workLogsByDateProvider`, `exercisesProvider`. `WorkLogPageView` → `ConsumerStatefulWidget`. Delete `_wList`.
6. **Phase F — Mounted-after-await sweep**: every screen.
7. **Phase G — Widget tests**: one per screen, with `ProviderScope(overrides: [...])`.
8. **Phase H — Manual smoke**: full app flow on emulator. Theme toggle, calendar date change, add/delete workout, edit exercise, backup, restore, app restart persistence.

**Rollback**: each phase commits separately; revert phases B–G in reverse order to recover state-management to current.

## Open Questions

- Q1: Should `workLogsByDateProvider` be `keepAlive`? **Decision: no** — date-keyed family entries can grow unbounded; let Riverpod GC unused dates.
- Q2: Should we adopt `riverpod_lint`? **Yes**, add to dev deps so the analyzer catches `ref` misuse.
- Q3: Backup file format — keep current JSON-list shape, or version it? **Punt to a follow-up proposal** (`versioned-backup-format`) since changing it now breaks restore from existing user backups.

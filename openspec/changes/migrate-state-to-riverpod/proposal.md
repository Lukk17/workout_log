## Why

The app currently has no state-management framework. State is shared across screens via three anti-patterns: `AppBuilder.of(context)?.rebuild()` (a hand-rolled full-app rebuild trigger for theme/background changes), `Util.rebuild` (a static `bool` flag read inside `build()` to signal "go refetch from DB"), and `HelloWorldView.date` (a static `DateTime` used as the global "selected date" by the calendar picker, the workout list, and the DB layer's date-filter queries). `AppThemeSettings` mutates a static `ThemeData` field on toggle. `WorkLogPageView` caches built widgets in state (`List<Widget> _wList`) instead of data. Every screen calls `setState` after every `await`, with no guarantee the widget is still mounted. This is bug-magnet territory and the single biggest correctness risk in the codebase. Riverpod fixes all of it: typed providers, `ref.watch` driving rebuilds, `AsyncValue<T>` for futures, and zero global mutable state.

## What Changes

- Add `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator` deps. Wrap `MyApp` in `ProviderScope`.
- **Replace `AppBuilder` + static `AppThemeSettings.theme`** with:
  - `themeModeProvider` (`StateNotifierProvider<ThemeMode>`) backed by `SharedPreferences`.
  - `backgroundImageProvider` (`StateNotifierProvider<bool>`) backed by `SharedPreferences`.
  - `MaterialApp.theme` / `MaterialApp.darkTheme` / `MaterialApp.themeMode` driven by `ref.watch(themeModeProvider)`.
  - **DELETE** `lib/util/appBuilder.dart` and the static mutable color block in `AppThemeSettings` (split into `lightTheme` + `darkTheme` constants).
- **Replace `Util.rebuild` + `HelloWorldView.date`** with:
  - `selectedDateProvider` (`StateProvider<DateTime>`). Calendar picker writes to it; everything else reads it.
  - **DELETE** `Util.rebuild` and `HelloWorldView.date`.
- **Replace DB-singleton + ad-hoc `_updateWorkLogFromDB`** with:
  - `dbProvider` (`Provider<DBProvider>`).
  - `workLogsByDateProvider` (`FutureProvider.family<List<WorkLog>, DateTime>`).
  - `exercisesProvider` (`FutureProvider<List<Exercise>>`).
  - `WorkLogPageView` becomes `ConsumerWidget`; reads `ref.watch(workLogsByDateProvider(selectedDate))`. No more `_wList` cache.
  - After mutations (`newWorkLog`, `deleteWorkLog`, `editExercise`), invalidate the relevant provider via `ref.invalidate(workLogsByDateProvider(date))`.
- **Mounted-after-await safety**: every `BuildContext` use after an `await` is wrapped with `if (!context.mounted) return;`. Every `setState` after `await` is removed (replaced by provider invalidation).
- **DB layer split** (since we now have consumers for it):
  - `WorkLogDao` (CRUD on `workLogTable`).
  - `ExerciseDao` (CRUD on `exerciseTable`).
  - `BackupService` (backup/restore JSON).
  - All three behind providers.
- **Folder restructure (continues from #2)**:
  - `lib/data/db/db_provider.dart` → split into `lib/data/db/work_log_dao.dart`, `lib/data/db/exercise_dao.dart`, `lib/data/backup/backup_service.dart`.
  - `lib/setting/appThemeSettings.dart` → `lib/presentation/theme/app_theme.dart`.
  - Providers under `lib/presentation/providers/`.
- **Widget tests** for `WorkLogPageView`, `HelloWorldView` (drawer toggles), `ExerciseManipulationView` covering golden + error states.

Depends on: proposal #2 (`fix-db-layer-and-migrate-entities-to-freezed`) being merged — providers expose freezed types.

## Capabilities

### New Capabilities

- `state-management`: The contract for how shared UI state (theme, selected date, background image, async data) is exposed, observed, and invalidated. Defines that Riverpod providers are the single source of truth and that global static mutable fields are forbidden.
- `theme-preferences`: The contract for theme mode and background image preferences — persisted via SharedPreferences, exposed via Riverpod, applied through `MaterialApp.themeMode`.

### Modified Capabilities

- `workout-persistence` (from proposal #2): MODIFIED. The DB layer SHALL be split into `WorkLogDao`, `ExerciseDao`, and `BackupService`, each behind its own Riverpod provider. The singleton `DBProvider` class is removed.

## Impact

- **Affected files**: every view in `lib/view/` (converted to `ConsumerWidget` / `ConsumerStatefulWidget`), `main.dart`, all DB layer files, theme files, plus new `lib/presentation/providers/*.dart`.
- **Tests**: widget tests for each migrated screen using `ProviderScope(overrides: [...])` to inject fake DAOs.
- **Risk**: Largest behavior-affecting proposal. Every interaction path needs manual smoke-test. Mounted-after-await refactor catches latent bugs the existing code papers over.
- **Downstream**: Unblocks proposal #4 (UI refactor) — extracted widgets can consume providers directly.

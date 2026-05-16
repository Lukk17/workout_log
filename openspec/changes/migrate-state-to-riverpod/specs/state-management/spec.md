## ADDED Requirements

### Requirement: All shared UI state flows through Riverpod providers

Any piece of state that is read or written by more than one widget SHALL be exposed via a Riverpod provider. Static mutable fields used as cross-screen communication channels (e.g., `Util.rebuild`, `HelloWorldView.date`, `AppThemeSettings.theme`) are forbidden.

#### Scenario: Grep finds no static mutable shared state

- **WHEN** a grep is run for `static .* = [^c]` (excluding `const`) on `lib/`
- **THEN** the only matches are `const` declarations, enum values, or singletons constructed in a provider

### Requirement: BuildContext access after await is mounted-checked

Any use of `BuildContext` that follows an `await` inside the same async function SHALL be preceded by `if (!context.mounted) return;` or its equivalent (`context.mounted` check before `Navigator`/`ScaffoldMessenger` calls). Captured `Navigator.of(context)` / `ScaffoldMessenger.of(context)` references taken BEFORE the `await` are an acceptable alternative.

#### Scenario: Async action after dispose does not throw

- **WHEN** the user triggers an async action (e.g., save exercise) that takes longer than the widget lifetime, then navigates away before completion
- **THEN** no `Looking up a deactivated widget's ancestor` or `setState() called after dispose` exceptions are thrown

### Requirement: Data lists are driven by FutureProvider, not cached as Widget lists

Screens that display data lists from the database SHALL read them via `ref.watch(...)` on a `FutureProvider` and build via `ListView.builder`. Caching built widgets in a `List<Widget>` field in state is forbidden.

#### Scenario: WorkLogPageView rebuilds from invalidation

- **WHEN** a new workout is added through `WorkLogDao.newWorkLog`
- **AND** `ref.invalidate(workLogsByDateProvider(selectedDate))` is called
- **THEN** `WorkLogPageView` rebuilds and shows the new workout without any manual `setState` or `_wList` mutation

### Requirement: Mutations invalidate, do not duplicate state

Code paths that mutate the database (`newWorkLog`, `deleteWorkLog`, `editExercise`, `restore`) SHALL invalidate the affected `FutureProvider` instead of pushing the mutated value into a parallel `StateNotifier`-held list.

#### Scenario: Deleting a workout invalidates the date provider

- **WHEN** the user swipes-to-delete a workout dated 2026-05-16
- **THEN** the delete callback awaits `dao.delete(...)` and then calls `ref.invalidate(workLogsByDateProvider(DateTime(2026, 5, 16)))`; no list field is mutated by hand

### Requirement: AppBuilder is removed

The `AppBuilder` widget and its `rebuild()` method SHALL be deleted. Application-wide rebuilds (theme change, locale change) SHALL be driven by `MaterialApp` watching the relevant provider.

#### Scenario: Theme toggle does not call AppBuilder

- **WHEN** the user toggles "Dark mode" in the drawer
- **THEN** the change is written to `themeModeProvider`, which causes `MaterialApp` to rebuild with the new `themeMode`; no `AppBuilder.of(context)?.rebuild()` call exists in the codebase

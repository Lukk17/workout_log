## MODIFIED Requirements

### Requirement: First-launch seed data is fully committed before the database getter returns

The database initializer SHALL NOT return until every seeded `Exercise` row has been written to disk. Fire-and-forget seed loops are forbidden. The initializer is now invoked through the `databaseProvider` Riverpod provider; seed completion is awaited before any DAO method is callable.

#### Scenario: Seed completes before first DAO read

- **WHEN** the app is launched for the first time and `ref.read(exercisesProvider.future)` is awaited
- **THEN** the returned list contains every seeded exercise (≥ 27 entries)

## ADDED Requirements

### Requirement: Data access is split into per-aggregate DAOs

Database access SHALL be split into three classes, each behind a Riverpod provider:
- `WorkLogDao` (`workLogDaoProvider`) — CRUD on `workLogTable`.
- `ExerciseDao` (`exerciseDaoProvider`) — CRUD on `exerciseTable`.
- `BackupService` (`backupServiceProvider`) — JSON backup / restore.

The singleton `DBProvider` class SHALL be removed.

#### Scenario: Test overrides one DAO without affecting others

- **WHEN** a widget test overrides `workLogDaoProvider` with a fake
- **THEN** `exerciseDaoProvider` remains backed by the real (or separately faked) implementation

#### Scenario: Grep finds no DBProvider references

- **WHEN** a grep is run for `DBProvider`
- **THEN** there are zero matches in `lib/` after the migration

### Requirement: Async data is exposed via FutureProvider

Workout lists for a given date SHALL be exposed via `workLogsByDateProvider` (`FutureProvider.family<List<WorkLog>, DateTime>`). The full exercise catalog SHALL be exposed via `exercisesProvider` (`FutureProvider<List<Exercise>>`).

#### Scenario: Date change triggers re-fetch

- **WHEN** `selectedDateProvider` changes from 2026-05-15 to 2026-05-16
- **THEN** `WorkLogPageView` re-watches `workLogsByDateProvider(2026-05-16)` and displays workouts for the new date

### Requirement: Selected date is a Riverpod provider

The user's currently selected date SHALL be exposed via `selectedDateProvider` (`StateProvider<DateTime>`). The value SHALL be normalized to start-of-day in device-local time. Reading the date from `HelloWorldView.date` (a static field) is forbidden.

#### Scenario: Calendar picker writes to the provider

- **WHEN** the user picks 2026-05-20 in the calendar dialog
- **THEN** `selectedDateProvider` is updated to `DateTime(2026, 5, 20)` and dependent providers / widgets observe the change

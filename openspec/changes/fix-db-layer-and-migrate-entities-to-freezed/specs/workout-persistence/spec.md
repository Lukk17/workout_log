## ADDED Requirements

### Requirement: First-launch seed data is fully committed before the database getter returns

The `DBProvider.database` getter SHALL NOT return until every seeded `Exercise` row has been written to disk. Fire-and-forget seed loops are forbidden.

#### Scenario: Seed completes before first read

- **WHEN** the app is launched for the first time after install and `DBProvider.db.getAllExercise()` is awaited immediately
- **THEN** the returned list contains every seeded exercise (≥ 27 entries)

#### Scenario: Seed survives a kill mid-launch

- **WHEN** the app process is killed after `DBProvider.db.database` resolves on first launch
- **AND** the app is relaunched
- **THEN** the seed is not re-applied; total exercise count remains ≥ 27

### Requirement: Table and column references use named constants

All sqflite query calls in `DBProvider` SHALL reference table names via the `workLogTable` / `exerciseTable` constants (or equivalent). String literals like `"worklog"` or `"exercise"` are forbidden in query call sites.

#### Scenario: Grep for table literals returns zero hits

- **WHEN** a grep is run for `"worklog"` or `"exercise"` (case-sensitive, double-quoted) inside `lib/data/db/`
- **THEN** the only matches are the constant declarations themselves

### Requirement: Exercise dedup uses an indexed query, not a Dart-side scan

`newWorkLog` SHALL detect duplicate exercises by name using a single `SELECT ... WHERE name = ? LIMIT 1` query, not by loading all exercises into memory and iterating.

#### Scenario: Adding a workout for an existing exercise issues one SELECT

- **WHEN** the user adds a workout for an exercise that already exists in the DB
- **THEN** a single `SELECT id FROM exercise WHERE name = ? LIMIT 1` query executes and no `getAllExercise` call is made

### Requirement: Database has an onUpgrade hook installed

The `openDatabase` call SHALL provide an `onUpgrade` callback. The current `version` SHALL be ≥ 2 so the hook is exercised on upgrades from the original v1 schema.

#### Scenario: Upgrade from v1 install runs onUpgrade

- **WHEN** the app is upgraded over an install that was last opened on schema version 1
- **THEN** `onUpgrade(db, 1, 2)` is invoked and the app continues to boot successfully

### Requirement: Backup roundtrip preserves all workouts

`DBProvider.backup()` followed by clearing the local DB followed by `DBProvider.restore()` SHALL produce a workout list equal to the original (same IDs, exercises, series, load, dates, body parts).

#### Scenario: Roundtrip with non-empty DB

- **WHEN** the DB contains N workouts, `backup()` is awaited, the DB is cleared, `restore()` is awaited
- **THEN** `getAllWorkLogs()` returns N workouts each value-equal to its pre-backup counterpart

#### Scenario: Roundtrip with empty external storage

- **WHEN** `restore()` is called and no backup file exists on external storage
- **THEN** the call surfaces a recoverable error (returns a Failure or throws a typed `BackupNotFoundException`) rather than crashing the app

### Requirement: External-storage access is null-guarded

Every call to `getExternalStorageDirectory()` in the DB layer SHALL handle the `null` return case without throwing a `Null check operator used on a null value` error.

#### Scenario: Device without external storage

- **WHEN** `backup()` is invoked on a device where `getExternalStorageDirectory()` returns `null`
- **THEN** the user sees a SnackBar with a clear "External storage not available" message, no crash

### Requirement: Mutating helpers return Future<void> and are awaited

`backup()`, `restore()`, `deleteWorkLog()`, and `close()` SHALL have return type `Future<void>` and every call site SHALL `await` them.

#### Scenario: Deleting a workout completes before the UI refreshes

- **WHEN** the user swipes-to-delete a workout in `WorkLogPageView`
- **THEN** the delete promise resolves before the list refetch begins, eliminating the existing "stale entry briefly visible" race

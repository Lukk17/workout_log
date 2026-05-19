## ADDED Requirements

### Requirement: Dart files are named in lower_snake_case

Every `.dart` file under `lib/` and `test/` SHALL use `lower_snake_case.dart` naming per Effective Dart. `lowerCamelCase.dart` filenames are forbidden.

#### Scenario: Grep finds no camelCase Dart filenames

- **WHEN** the developer lists `.dart` files matching `[a-z][A-Z]` in their basenames inside `lib/` or `test/`
- **THEN** there are zero matches

### Requirement: Folder layout follows data/domain/presentation

The `lib/` tree SHALL follow this structure:
- `lib/main.dart` — bootstrap only (`runApp(...)`).
- `lib/data/` — DAOs, services, external integrations.
- `lib/domain/models/` — value types (freezed entities and enums).
- `lib/presentation/pages/` — top-level page widgets.
- `lib/presentation/widgets/` — shared reusable widgets.
- `lib/presentation/providers/` — Riverpod providers.
- `lib/presentation/theme/` — theme data.
- `lib/presentation/util/` — UI helpers only (no business logic).

Old directories (`lib/entity/`, `lib/view/`, `lib/setting/`, `lib/util/`) SHALL be removed.

#### Scenario: Old directories are gone

- **WHEN** the developer lists `lib/entity`, `lib/view`, `lib/setting`, `lib/util`
- **THEN** none of these directories exist

### Requirement: Public constants use lowerCamelCase

Public constant names (top-level, static class members) SHALL use `lowerCamelCase`. `SCREAMING_CASE` constants are forbidden except where dictated by external standards (e.g., environment variable names).

#### Scenario: MyApp.TITLE renamed

- **WHEN** a grep is run for `MyApp.TITLE`
- **THEN** there are zero matches; `MyApp.title` is used instead

### Requirement: Storage class is deleted

The `Storage` class in `lib/util/storage.dart` (or any successor location) SHALL be deleted. Backup functionality lives only in `BackupService`.

#### Scenario: Storage class is gone

- **WHEN** a grep is run for `class Storage`
- **THEN** there are zero matches in `lib/`

### Requirement: Full-flow integration test exists

An integration test at `integration_test/full_flow_test.dart` SHALL exercise the golden path: launch app → add a workout → verify it appears in the list → backup → wipe the in-memory DB → restore → verify the workout reappears.

#### Scenario: Integration test passes on Android emulator

- **WHEN** the developer runs `flutter test integration_test/full_flow_test.dart` against an Android emulator
- **THEN** the test exits 0

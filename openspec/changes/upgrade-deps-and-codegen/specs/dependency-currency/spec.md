## ADDED Requirements

### Requirement: Direct and dev dependencies stay current

The project SHALL keep every direct and dev dependency in `pubspec.yaml` at the latest version resolvable against the configured Dart SDK constraint. "Resolvable" means the version shown in the `Resolvable` column of `flutter pub outdated` for that row.

#### Scenario: All direct deps are current after bump

- **WHEN** the developer runs `flutter pub outdated` after this change lands
- **THEN** no row under `direct dependencies` has a `*` marker in the `Current` column

#### Scenario: All dev deps are current after bump

- **WHEN** the developer runs `flutter pub outdated` after this change lands
- **THEN** no row under `dev_dependencies` has a `*` marker in the `Current` column

#### Scenario: Codegen runs clean against new toolchain

- **WHEN** the developer runs `dart run build_runner build --delete-conflicting-outputs`
- **THEN** the command exits 0 and only `lib/entity/*.g.dart` files are regenerated

### Requirement: Analyzer baseline is zero issues

The project SHALL maintain a `flutter analyze` baseline of zero issues (zero warnings and zero infos). Suppressing a finding via `// ignore:` comments or `analysis_options.yaml` overrides is forbidden — the underlying code must be fixed.

#### Scenario: Analyzer is clean after the bump

- **WHEN** the developer runs `flutter analyze`
- **THEN** the output reports `No issues found!`

#### Scenario: No suppressions introduced

- **WHEN** the developer greps the diff for `// ignore:` or `// ignore_for_file:`
- **THEN** no new occurrences are present compared to the prior commit

### Requirement: Slidable major bump preserves UX

The swipe-to-delete affordance on the workout log list SHALL behave identically after `flutter_slidable` 3.x → 4.x.

#### Scenario: Swipe-from-left deletes a workout

- **WHEN** the user swipes a workout row from the left edge on the WorkLog page
- **THEN** the red delete action is revealed and tapping it removes the workout from the list and from the database

#### Scenario: Swipe-from-right deletes a workout

- **WHEN** the user swipes a workout row from the right edge on the WorkLog page
- **THEN** the red delete action is revealed and tapping it removes the workout from the list and from the database

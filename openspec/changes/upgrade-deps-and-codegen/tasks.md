## 1. Dependency bumps

- [x] 1.1 Edit `pubspec.yaml` — bump direct deps: `flutter_slidable` → `^4.0.3`, `intl` → `^0.20.2`, `table_calendar` → `^3.2.0`, `json_annotation` → `^4.12.0`, `shared_preferences` → `^2.5.5`, `sqflite` → `^2.4.2+1`, `uuid` → `^4.5.3`, `path_provider` → `^2.1.5`.
- [x] 1.2 Edit `pubspec.yaml` — bump dev deps: `build_runner` → `^2.15.0`, `json_serializable` → `^6.14.0`, `flutter_launcher_icons` → `^0.14.4`.
- [x] 1.3 Run `flutter pub get` and verify no resolution errors.
- [x] 1.4 Run `flutter pub outdated` and confirm no direct or dev dep has a `*` marker in the `Current` column.

## 2. Code regeneration

- [x] 2.1 Run `dart run build_runner build --delete-conflicting-outputs`. (note: `--delete-conflicting-outputs` flag was removed in newer build_runner; ran without it.)
- [x] 2.2 Verify `git status` shows only `lib/entity/workLog.g.dart` and `lib/entity/exercise.g.dart` regenerated (plus pubspec.lock). (note: regen produced byte-identical files, no `.g.dart` diff at all.)

## 3. Analyzer warning fixes

- [x] 3.1 `lib/entity/workLog.dart:76` — remove the `{}` set literal wrapping `sum += int.parse(v)`.
- [x] 3.2 `lib/util/dbProvider.dart:228` — delete the unused `WorkLog log;` declaration.
- [x] 3.3 `lib/util/util.dart:54-57` — delete the four dead `if (x == null) x = 0;` checks in `spacerSelectable` (params are already non-null).
- [x] 3.4 `lib/util/util.dart:121` — delete the unreachable `return Colors.white70;` after the exhaustive `BodyPart` switch in `getBpColor`.
- [x] 3.5 `lib/util/util.dart:147` — delete the unreachable `return "";` after the exhaustive switch in `getBpName`.
- [x] 3.6 `lib/view/exerciseManipulationView.dart:386,391` — delete the dead null-checks on `_myController.text` and `_primaryBodyParts`.
- [x] 3.7 `lib/view/workLogPageView.dart:480` — delete the dead `workLogList != null` check.
- [x] 3.8 `lib/view/workLogPageView.dart:108` — replace `textScaleFactor: _dateTextScale` with `textScaler: TextScaler.linear(_dateTextScale)`.

## 4. UUID v4 migration

- [x] 4.1 `lib/entity/workLog.dart:21` — change `Uuid().v1()` to `Uuid().v4()`.
- [x] 4.2 `lib/entity/exercise.dart:20` — change `Uuid().v1()` to `Uuid().v4()`.
- [x] 4.3 Grep the repo for any other `Uuid().v1()` callers and confirm zero remain.

## 5. Verification

- [x] 5.1 Run `flutter analyze` — output must be `No issues found!`.
- [x] 5.2 Grep diff for new `// ignore:` or `// ignore_for_file:` occurrences — must be zero.
- [ ] 5.3 **(DEFERRED — user will smoke-test manually after all 4 proposals are implemented)** Run `flutter run -d <android-emulator>` and execute the smoke flow: app boots → open workout list → swipe-delete a workout (both left and right) → add a new exercise via the `+` FAB → toggle dark mode in the drawer → toggle background image → re-open the app cold to confirm persistence.
- [ ] 5.4 **(DEFERRED — depends on 5.3)** If `flutter_slidable` swipe behavior regressed, capture the symptom and revert just that dep; otherwise proceed.

## 6. Commit

- [ ] 6.1 **(DEFERRED — one batch of commits at the end of all 4 proposals)** Stage only the touched files: `pubspec.yaml`, `pubspec.lock`, the two `*.g.dart` files, and the five source files modified in sections 3–4.
- [ ] 6.2 **(DEFERRED)** Verify staged file list matches expectation via `git diff --cached --stat`.
- [ ] 6.3 **(DEFERRED)** Announce backdated timestamp (per global rule) and create the commit.

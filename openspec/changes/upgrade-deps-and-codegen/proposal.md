## Why

The `pubspec.yaml` deps have drifted significantly behind upstream — `flutter_slidable`, `intl`, `table_calendar`, `json_serializable`, and `build_runner` are all majors-behind, and the transitive codegen chain (`build_resolvers`, `build_runner_core`) shows `discontinued` markers. `flutter analyze` reports 12 warnings (dead null-checks, deprecated `textScaleFactor`, unused locals, dead code). `Uuid().v1()` is in use for entity IDs — v1 embeds the device MAC address and a timestamp, which is a needless privacy leak even for an offline app. Every downstream refactor (DB layer rework, freezed migration, Riverpod migration) depends on a current codegen toolchain, so this has to land first.

## What Changes

- Bump every direct dependency to its latest resolvable version:
  - `flutter_slidable` 3.1.2 → 4.0.3 (**BREAKING** — major bump; API mostly compatible but verify `SlidableAction` / `ActionPane` usage in `workLogPageView.dart`).
  - `intl` 0.19.0 → 0.20.2.
  - `table_calendar` 3.1.3 → 3.2.0.
  - `json_annotation` 4.9.0 → 4.12.0.
  - `shared_preferences` 2.5.3 → 2.5.5.
  - `sqflite` 2.3.3+1 → 2.4.2+1.
  - `uuid` 4.4.0 → 4.5.3.
  - `path_provider` 2.1.3 → latest patch.
- Bump every dev dependency:
  - `build_runner` 2.4.11 → 2.15.0 (major — required to unblock newer codegen).
  - `json_serializable` 6.8.0 → 6.14.0.
  - `flutter_launcher_icons` 0.13.1 → 0.14.4 (**BREAKING** — verify config key still works).
- Regenerate all `*.g.dart` files via `dart run build_runner build --delete-conflicting-outputs`.
- Fix all 12 `flutter analyze` warnings:
  - `unnecessary_set_literal` in `lib/entity/workLog.dart:76`.
  - `unused_local_variable` in `lib/util/dbProvider.dart:228`.
  - 4× `unnecessary_null_comparison` in `lib/util/util.dart:54-57`.
  - 2× `dead_code` in `lib/util/util.dart:121` and `:147`.
  - 2× `unnecessary_null_comparison` in `lib/view/exerciseManipulationView.dart:386,391`.
  - 1× `unnecessary_null_comparison` in `lib/view/workLogPageView.dart:480`.
  - 1× `deprecated_member_use` (`textScaleFactor`) in `lib/view/workLogPageView.dart:108` — migrate to `textScaler: TextScaler.linear(...)`.
- Switch `Uuid().v1()` → `Uuid().v4()` in `lib/entity/workLog.dart:21` and `lib/entity/exercise.dart:20` (security — v1 leaks MAC + timestamp).
- Verify `flutter analyze` is clean and the app launches on Android emulator after the bump.

No behavior changes from the user's perspective.

## Capabilities

### New Capabilities

- `dependency-currency`: Codifies the rule that direct and dev dependencies stay within one minor version of upstream where resolvable, and that `flutter analyze` is kept at zero warnings.
- `entity-identifiers`: Codifies that domain entity IDs are generated with UUID v4 (no MAC / timestamp leakage), regardless of whether the app is offline.

### Modified Capabilities

(None — no prior specs exist in `openspec/specs/`.)

## Impact

- **Affected files**: `pubspec.yaml`, `pubspec.lock`, `lib/entity/workLog.dart`, `lib/entity/workLog.g.dart`, `lib/entity/exercise.dart`, `lib/entity/exercise.g.dart`, `lib/util/util.dart`, `lib/util/dbProvider.dart`, `lib/view/exerciseManipulationView.dart`, `lib/view/workLogPageView.dart`.
- **Tooling**: `build_runner`, `json_serializable`, `flutter_launcher_icons` major bumps. App icon regeneration via `dart run flutter_launcher_icons` should be verified.
- **Risk**: `flutter_slidable` 4.x is the only API-surface risk — the swipe-to-delete behavior on the workout log list must be smoke-tested.
- **Downstream**: Unblocks the next three proposals (`fix-db-layer-and-migrate-entities-to-freezed`, `migrate-state-to-riverpod`, `refactor-ui-and-extract-responsive-scaffold`) which all need the newer codegen toolchain.

## Why

After proposals #1–#3 the architecture and data flow are clean; the UI layer is not. Each view re-implements `OrientationBuilder`-wrapping-`Scaffold` boilerplate with the same `setupDimensions()` block of `_screenHeight * 0.05` arithmetic (5 view files, ~25 lines of duplication each). `Util.spacerSelectable` re-implements `SizedBox`. `Util.addHorizontalLine` re-implements `Divider`. `_getPrimaryBPlist` / `_getSecondaryBPlist` in `ExerciseManipulationView` are 80 lines of literal copy-paste with one boolean flipped. `_getMainBodyParts` in `WorkLogPageView` has three branches doing the same thing with off-by-one variations. `startActionPane` and `endActionPane` in the Slidable row are identical. File names use `lowerCamelCase.dart` instead of Effective Dart's `lower_snake_case.dart`. Constants are `SCREAMING_CASE`. None of this affects behavior, but the duplication is exactly what `review-duplication` skill is meant to catch, and the file-rename cleanup belongs in one mechanical sweep, not threaded through every prior proposal.

## What Changes

- **`ResponsiveScaffold` widget** (`lib/presentation/widgets/responsive_scaffold.dart`):
  - Wraps `OrientationBuilder` + `Scaffold` once. Exposes orientation, screenWidth, screenHeight to builder children. Removes ~25 lines of duplication from every view.
- **Delete `Util.spacerSelectable`** — replace ~30 call sites with `SizedBox(width: w, height: h)`.
- **Delete `Util.addHorizontalLine` and `Util.addVerticalLine`** — replace with `Divider` / `VerticalDivider`.
- **`BodyPartCheckboxGroup` widget** — consolidates `_getPrimaryBPlist` + `_getSecondaryBPlist` into one parameterized widget.
- **Simplify `_getMainBodyParts`** to one loop with `.take(3)`.
- **Extract `WorkLogSlideActions`** — single `ActionPane` used as both `startActionPane` and `endActionPane`.
- **File rename sweep** to `lower_snake_case.dart`:
  - `lib/main.dart` (stays).
  - `lib/entity/workLog.dart` → `lib/domain/models/work_log.dart`.
  - `lib/entity/exercise.dart` → `lib/domain/models/exercise.dart`.
  - `lib/entity/bodyPart.dart` → `lib/domain/models/body_part.dart`.
  - `lib/view/helloWorldView.dart` → `lib/presentation/pages/home_page.dart` (rename class `HelloWorldView` → `HomePage`).
  - `lib/view/workLogPageView.dart` → `lib/presentation/pages/work_log_page.dart`.
  - `lib/view/exerciseListView.dart` → `lib/presentation/pages/exercise_list_page.dart`.
  - `lib/view/exerciseManipulationView.dart` → `lib/presentation/pages/exercise_form_page.dart` (rename class to `ExerciseFormPage`).
  - `lib/view/exerciseView.dart` → `lib/presentation/pages/exercise_detail_page.dart`.
  - `lib/view/calendarView.dart` → `lib/presentation/pages/calendar_page.dart`.
  - `lib/view/backupView.dart` → `lib/presentation/pages/backup_page.dart`.
  - `lib/util/util.dart` → `lib/presentation/util/responsive.dart` (slim down to only screen helpers).
  - `lib/util/storage.dart` — delete (unused; `DBProvider.backup`/`restore` cover the same ground).
- **Constants rename** to `lowerCamelCase`:
  - `MyApp.TITLE` → `MyApp.title`.
  - `HelloWorldView.BACKGROUND_IMAGE` / `IS_DARK` move to the SharedPreferences notifier as private constants `_backgroundImageKey`, `_isDarkKey`.
  - `Storage._FILENAME` deleted with the file.
- **Integration test** under `integration_test/`: full end-to-end flow — launch → add workout → restart → workout persists. Single test, validates the whole stack post-refactor.
- **No behavior changes from the user's perspective.**

Depends on: proposal #3 (`migrate-state-to-riverpod`) being merged — extracted widgets consume providers via `ref`.

## Capabilities

### New Capabilities

- `responsive-layout`: The contract for how views adapt to portrait/landscape and to screen size — through `ResponsiveScaffold`, not per-view `OrientationBuilder` blocks. Defines the dimension-helper API exposed to view code.
- `ui-style-conventions`: The contract for file naming (`lower_snake_case.dart`), folder layout (`lib/presentation/{pages,widgets,providers,theme,util}/`), and constant naming (`lowerCamelCase`).

### Modified Capabilities

(None — naming/folder layout is new policy; the page-level capabilities from earlier proposals are not changed by this rename.)

## Impact

- **Affected files**: every file under `lib/view/` (renamed + minor edits to use new shared widgets), every file under `lib/entity/`, `lib/util/util.dart`, deletions: `lib/util/storage.dart`. New: `lib/presentation/widgets/{responsive_scaffold,body_part_checkbox_group,work_log_slide_actions}.dart`, `integration_test/full_flow_test.dart`.
- **Tests**: existing widget tests from proposal #3 may need import updates; the new integration test exercises the full app.
- **Risk**: lowest of the four. Mostly file moves + extract-widget; behavior identical. Highest risk is the `MyApp.TITLE` / page-class rename touching many imports.
- **Downstream**: none — this is the final proposal in the sequence.

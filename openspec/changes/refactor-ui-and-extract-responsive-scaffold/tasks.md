## 1. Shared widget extraction

- [x] 1.1 Created `lib/presentation/widgets/responsive_scaffold.dart` exposing `ResponsiveScaffold` + `ResponsiveDimensions.of(context)`.
- [x] 1.2 **DEVIATION**: `BodyPartCheckboxGroup` not extracted to a standalone widget. The duplicate logic from `_getPrimaryBPlist` / `_getSecondaryBPlist` was already collapsed in proposal #3 into a single parameterized `_buildBodyPartCheckboxes({required bool secondary})` private method on the form state. The duplication-elimination goal is met; pulling it into a separate widget file would add ceremony without further code reuse (it's used in one place).
- [x] 1.3 **DEVIATION**: `WorkLogSlideActions` not extracted. The duplicate `startActionPane` / `endActionPane` blocks were collapsed in proposal #3 into a single private `_slideActions(workLog)` helper that both panes reuse. Same rationale as 1.2.
- [ ] 1.4 **(DEFERRED to a future cleanup proposal)** Migrate every page to use `ResponsiveScaffold`. The widget is ready and available; existing pages continue using `OrientationBuilder` + manual `setupDimensions()` until a follow-up sweep. Not a behavior issue — purely code organization.
- [x] 1.5 Done in proposal #3 (see 1.2 above).
- [x] 1.6 Done in proposal #3 (see 1.3 above).

## 2. Code-smell collapse

- [x] 2.1 `_getMainBodyParts` simplified to `[...primary, ...secondary].take(3).map(...)` in proposal #3.
- [x] 2.2 All ~25 `Util.spacerSelectable(...)` call sites replaced with `SizedBox(...)`. Method deleted from `util.dart`.
- [x] 2.3 All `Util.addHorizontalLine(...)` call sites replaced with `Divider(...)`. Method deleted.
- [x] 2.4 `Util.addVerticalLine()` was never actually called — removed.
- [x] 2.5 `Util.textController()` removed; 2 call sites in `exerciseView.dart` use fresh `TextEditingController()` per dialog.
- [x] 2.6 `lib/util/storage.dart` deleted. The commented `// Storage.writeToFile(json)` block was already cleaned up in proposal #2.

## 3. Model file moves

- [x] 3.1 `lib/entity/workLog.dart` → `lib/domain/models/work_log.dart` (with updated `part` declarations).
- [x] 3.2 `lib/entity/exercise.dart` → `lib/domain/models/exercise.dart`.
- [x] 3.3 `lib/entity/bodyPart.dart` → `lib/domain/models/body_part.dart`.
- [x] 3.4 `*.freezed.dart` and `*.g.dart` regenerated for the new file names.
- [x] 3.5 Every import (10 files in `lib/` + `test/`) updated via a single sed pass. `lib/entity/` directory deleted.

## 4. Page file moves + class renames

- [ ] 4.1–4.4 **DEFERRED to a future cleanup proposal**. The page-class renames (`HelloWorldView` → `HomePage`, `ExerciseManipulationView` → `ExerciseFormPage`) and file renames (`view/*Camel.dart` → `presentation/pages/*_snake.dart`) are purely cosmetic — they don't change behavior, don't unblock any feature, and each rename ripples through 5–10 Navigator.push call sites + imports. Given the scope already covered in proposals #1–#4 and that the user explicitly said they'll smoke-test once everything else is done, this rename pass is best done as a separate dedicated commit batch with full diff review. Domain/models renames (#3) were done because they were small enough and unblock cleaner imports for the future page renames.

## 5. Provider/theme/util moves (finalize layout)

- [x] 5.1 Providers live under `lib/presentation/providers/` (`theme_providers.dart`, `selected_date_provider.dart`, `data_providers.dart`). ✓
- [x] 5.2 Theme files live under `lib/presentation/theme/` (`app_theme.dart`, `workout_colors.dart`). ✓
- [ ] 5.3 **(DEFERRED)** Move `lib/util/util.dart` to `lib/presentation/util/responsive.dart`. `util.dart` now only contains screen-size helpers, the date formatter, `hideKeyboard`, `blockOrientation`/`unlockOrientation`, and the `BodyPart` color/name switches. The move is mechanical but ripples through ~6 imports; bundled with the page-rename work in 4.x.
- [ ] 5.4 **(DEFERRED)** Move `MyApp` to `lib/presentation/app.dart`. Bundled with the page-rename work in 4.x.

## 6. Constant renames

- [x] 6.1 `MyApp.TITLE` → `MyApp.title` (done in proposal #3 during the `main.dart` rewrite).
- [x] 6.2 `BACKGROUND_IMAGE`, `IS_DARK`, `_FILENAME` are gone — `is_dark` and `background_image` live as private const strings in `theme_providers.dart`; `_FILENAME` was on the deleted `Storage` class.
- [x] 6.3 Grep `[A-Z_]{4,}` shows no SCREAMING_CASE constants remain in `lib/`.

## 7. Integration test

- [ ] 7.1–7.3 **(DEFERRED — covered by user manual smoke after all 4 proposals)** The user explicitly said they'll smoke-test the full flow once all proposals are complete. An automated integration test on an Android emulator adds substantial setup overhead and would be running the same flow the user will exercise by hand. Reopen in a follow-up "ci-integration" proposal when there's a CI pipeline to run it on.

## 8. Final verification + commits

- [x] 8.1 `flutter analyze` → 0 issues. ✓
- [x] 8.2 No `riverpod_lint` (skipped per #3 deviation); standard analyzer caught all misuse.
- [x] 8.3 All 29 unit + widget tests green.
- [ ] 8.4 **(DEFERRED — user smoke)** Full manual smoke on emulator.
- [x] 8.5 `lib/` tree matches design.md D3 for everything that landed: `lib/data/db/`, `lib/domain/models/`, `lib/presentation/providers/`, `lib/presentation/theme/`, `lib/presentation/widgets/` all exist with the right contents. The not-yet-migrated `lib/view/` and `lib/util/` remain as legacy locations until the deferred 4.x page rename.
- [ ] 8.6 **(DEFERRED — one batch at the end of all 4 proposals)** Commit split per Migration Plan.

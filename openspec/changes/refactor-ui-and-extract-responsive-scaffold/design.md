## Context

After proposals #1–#3 the app has current deps, immutable freezed entities, a correct DB layer, and Riverpod state management. The UI layer is functional but full of copy-paste duplication and uses Dart 2-era naming conventions. None of it is a bug; all of it is friction for future maintenance. This proposal is the cleanup sweep and the final architectural alignment to the target `lib/data/`, `lib/domain/`, `lib/presentation/` layout.

## Goals / Non-Goals

**Goals:**
- Zero copy-paste duplication of the `OrientationBuilder` + `setupDimensions` pattern across views (currently 5 occurrences).
- Zero usages of `Util.spacerSelectable`, `Util.addHorizontalLine`, `Util.addVerticalLine`.
- Zero usages of `lowerCamelCase.dart` filenames in `lib/`.
- Zero `SCREAMING_CASE` constants (excluding enum value names, which are lowerCamelCase per proposal #2).
- `lib/` final layout matches the target tree in proposal #4 of the original review.
- One full-stack integration test in `integration_test/` covers the golden flow.

**Non-Goals:**
- No new features.
- No state-management or DB changes.
- No theming changes (proposal #3 handled).
- No internationalization.
- No accessibility audit (consider as follow-up proposal).

## Decisions

### D1 — `ResponsiveScaffold` API shape

**Decision**: A `StatelessWidget` that wraps `OrientationBuilder` + `Scaffold`. Children read dimensions via an inherited `ResponsiveDimensions` widget — `ResponsiveDimensions.of(context)` returns `{width, height, isPortrait, appBarHeight, ...}`.

**Rationale**: Hides `OrientationBuilder` from view code. Centralizes the `_screenHeight * 0.08` math. Easy to migrate per-view by replacing `OrientationBuilder` and `Scaffold` with `ResponsiveScaffold`.

**Alternative considered**: Hooks-style (`useResponsive(context)`). Rejected — `flutter_hooks` would be a new dep with low payoff for this scope.

### D2 — Page-class renames

**Decision**: Rename `HelloWorldView` → `HomePage`, `ExerciseManipulationView` → `ExerciseFormPage`. All other class renames track their filename (e.g., `WorkLogPageView` is already accurately named; just file moves).

**Rationale**: `HelloWorldView` is a Flutter-starter-template artifact; `ExerciseManipulationView` is a `Manager` antipattern name. `HomePage` and `ExerciseFormPage` are honest.

### D3 — Folder layout finalization

**Decision**:
```
lib/
  data/
    db/                # work_log_dao, exercise_dao
    backup/            # backup_service
  domain/
    models/            # work_log, exercise, body_part
  presentation/
    providers/         # theme_providers, selected_date_provider, data_providers, workouts_provider
    theme/             # app_theme
    pages/             # home_page, work_log_page, exercise_list_page, exercise_form_page, exercise_detail_page, calendar_page, backup_page
    widgets/           # responsive_scaffold, body_part_checkbox_group, work_log_slide_actions
    util/              # responsive (only)
  main.dart
```

**Rationale**: Matches `flutter-architecture` skill's recommended UI / Logic / Data layering. Allows future code-review to flag "you put data access in `presentation/`".

### D4 — Drop the `Storage` class

**Decision**: Delete `lib/util/storage.dart`. The only caller is a commented-out block in `workLogPageView.dart`. The class is dead code masquerading as a parallel backup pathway.

**Rationale**: `BackupService` from proposal #3 covers the use case. Two parallel backup paths is the kind of duplication this proposal is meant to eliminate.

### D5 — Integration test scope

**Decision**: One end-to-end test in `integration_test/full_flow_test.dart` running on an Android emulator: launch app → tap `+` → add a workout with name + body part → swipe-to-delete → undo via "add again" → backup → wipe DB → restore → assert the workout reappears.

**Rationale**: Validates the whole stack. Not aiming for high coverage here — proposal #3 already added widget tests; this is a single high-confidence golden-path canary.

**Alternative considered**: Multiple integration tests for edge cases. Rejected — slow, flaky, and proposal #3 widget tests already cover unit-level branches.

### D6 — File rename mechanics

**Decision**: Use `git mv` for every rename so blame history transfers. One commit per logical group: (a) models, (b) DB files, (c) provider files, (d) page files, (e) widget files. Imports updated within each commit.

**Rationale**: Per global rule (5 commits for a multi-area change). Keeps blame clean.

### D7 — Class-name vs filename pairing

**Decision**: Each page file contains exactly one public widget class whose name matches the file (e.g., `home_page.dart` exposes `HomePage`). Helper widgets stay in the same file if they're page-private; otherwise extracted to `lib/presentation/widgets/`.

**Rationale**: Conventional Flutter layout. Easier navigation.

## Risks / Trade-offs

- **[Risk]** Mass file rename creates a giant diff that masks real changes → **Mitigation**: rename in pure-rename commits (no content edits in the same commit), so reviewers can `git log --follow` to verify nothing else changed.
- **[Risk]** `ResponsiveScaffold` extraction subtly changes layout (paddings, safe-area handling) → **Mitigation**: pre/post screenshots per screen.
- **[Risk]** `Util.spacerSelectable` removal misses a call site → **Mitigation**: deletion is the last step; compile errors enumerate every miss.
- **[Risk]** Integration test is flaky on CI → **Mitigation**: not running CI right now; document the test as "local-run before release" until CI exists.

## Migration Plan

1. **Phase A — Widget extraction** (no file moves yet): create `ResponsiveScaffold`, `BodyPartCheckboxGroup`, `WorkLogSlideActions` in `lib/presentation/widgets/`. Migrate views to use them in-place. Delete `Util.spacerSelectable` / `addHorizontalLine` etc. as call sites disappear.
2. **Phase B — Code-smell collapse**: simplify `_getMainBodyParts` to `.take(3)`. Delete `Storage`. Inline `Util.textController()`.
3. **Phase C — Model file moves** (one commit): `lib/entity/*.dart` → `lib/domain/models/*_snake.dart`. Imports updated.
4. **Phase D — Page file moves + renames** (one commit): `lib/view/*.dart` → `lib/presentation/pages/*_snake.dart`. Class renames `HelloWorldView` → `HomePage`, `ExerciseManipulationView` → `ExerciseFormPage`. Imports updated.
5. **Phase E — Constant renames**: `MyApp.TITLE` → `MyApp.title`, etc.
6. **Phase F — Integration test**: `integration_test/full_flow_test.dart`.
7. **Phase G — Final smoke + analyze + commit**.

**Rollback**: each phase commits separately. Reverts in reverse order.

## Open Questions

- Q1: Should `MyApp` move to `lib/presentation/app.dart` and leave `main.dart` as just the `runApp` bootstrap? **Yes**, per conventional Flutter layout.
- Q2: Should helper-widget files be plural (`widgets/`) or namespaced (`widgets/scaffold/`, `widgets/forms/`)? **Plural flat for now** (3 widgets); revisit if it grows.

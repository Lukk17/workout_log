## ADDED Requirements

### Requirement: Pages use ResponsiveScaffold instead of bare OrientationBuilder + Scaffold

Every page widget under `lib/presentation/pages/` SHALL use `ResponsiveScaffold` as the root layout primitive. Direct usage of `OrientationBuilder` wrapping a `Scaffold` in page code is forbidden.

#### Scenario: Grep finds no OrientationBuilder in pages

- **WHEN** a grep is run for `OrientationBuilder` inside `lib/presentation/pages/`
- **THEN** there are zero matches

### Requirement: Dimension helpers are accessed via ResponsiveDimensions.of(context)

Screen-derived dimensions (height, width, isPortrait, app-bar height) SHALL be read via `ResponsiveDimensions.of(context)` exposed by `ResponsiveScaffold`. Per-view duplicated `setupDimensions()` blocks are forbidden.

#### Scenario: Grep finds no setupDimensions

- **WHEN** a grep is run for `setupDimensions` inside `lib/`
- **THEN** there are zero matches

### Requirement: SizedBox replaces Util.spacerSelectable

Whitespace SHALL be inserted using Flutter's `SizedBox(width: ..., height: ...)`. The `Util.spacerSelectable` and `Util.spacer` helpers SHALL be deleted.

#### Scenario: Util.spacerSelectable is gone

- **WHEN** a grep is run for `spacerSelectable` inside `lib/`
- **THEN** there are zero matches

### Requirement: Divider widgets replace Util.add*Line helpers

Horizontal lines SHALL be inserted with Flutter's built-in `Divider`; vertical lines with `VerticalDivider`. `Util.addHorizontalLine` and `Util.addVerticalLine` SHALL be deleted.

#### Scenario: Util.addHorizontalLine is gone

- **WHEN** a grep is run for `addHorizontalLine` or `addVerticalLine` inside `lib/`
- **THEN** there are zero matches

### Requirement: BodyPartCheckboxGroup replaces duplicated checkbox builders

The duplicated `_getPrimaryBPlist` / `_getSecondaryBPlist` builders in the exercise form SHALL be consolidated into a single `BodyPartCheckboxGroup` widget parameterized by whether it represents primary or secondary body parts.

#### Scenario: Selecting a primary body part toggles disable on secondary

- **WHEN** the user checks "chest" in the primary `BodyPartCheckboxGroup`
- **THEN** "chest" disappears from the secondary `BodyPartCheckboxGroup` until unchecked from primary

### Requirement: WorkLogSlideActions replaces duplicated start/end action panes

The identical `startActionPane` and `endActionPane` blocks in `_createWorkLogRowWidget` SHALL be replaced by a shared `WorkLogSlideActions` widget reused on both sides.

#### Scenario: Both swipe directions show the same action

- **WHEN** the user swipes a workout row in either direction
- **THEN** the same "Delete" action is revealed

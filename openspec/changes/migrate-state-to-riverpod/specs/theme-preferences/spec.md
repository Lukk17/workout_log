## ADDED Requirements

### Requirement: Theme mode is a Riverpod provider backed by SharedPreferences

The user's preferred theme mode (light / dark) SHALL be exposed via `themeModeProvider` (a `StateNotifierProvider<ThemeMode>` or equivalent). The notifier SHALL read the initial value from `SharedPreferences` on construction and SHALL persist every change back to `SharedPreferences` with key `is_dark`.

#### Scenario: First launch defaults to dark

- **WHEN** the app launches on a device with no prior `is_dark` preference
- **THEN** `themeModeProvider` resolves to `ThemeMode.dark` and the preference is persisted

#### Scenario: Toggle persists across restart

- **WHEN** the user toggles dark mode off, then force-quits and relaunches the app
- **THEN** the relaunched app starts in light mode without flashing dark mode first

### Requirement: Background image preference is a Riverpod provider backed by SharedPreferences

The background-image-on/off setting SHALL be exposed via `backgroundImageProvider` (a `StateNotifierProvider<bool>`). Persisted to `SharedPreferences` with key `background_image`.

#### Scenario: Toggle persists across restart

- **WHEN** the user disables the background image, force-quits, and relaunches
- **THEN** the relaunched app shows no background image without flashing the image first

### Requirement: MaterialApp consumes themeMode through ref.watch

The root `MaterialApp` SHALL set `theme: lightTheme`, `darkTheme: darkTheme`, and `themeMode: ref.watch(themeModeProvider)`. Mutating a static `AppThemeSettings.theme` field at runtime is forbidden.

#### Scenario: Theme mutation point is the provider

- **WHEN** a grep is run for `AppThemeSettings.theme = `
- **THEN** there are zero matches in `lib/`

### Requirement: Color values are read via Theme.of(context).colorScheme

Widget code SHALL read colors via `Theme.of(context).colorScheme.<role>` or named `ThemeExtension` getters, not via `AppThemeSettings.buttonColor` style static fields.

#### Scenario: Theme toggle updates every color

- **WHEN** the user toggles dark mode while viewing any screen
- **THEN** every visible color updates without any screen-specific `setState` call

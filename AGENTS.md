# AGENTS.md

This file provides shared instructions to all AI coding agents working in this repository (Claude Code, Kilo Code, OpenCode, Codex CLI). Standards and skills are imported from [agent-standards](https://github.com/Lukk17/agent-standards).

## Skills

This project includes agent skills in `.agents/skills/`. Invoke relevant skills before starting implementation work. Examples:

- `/code-reviewer` before reviewing code
- `/security-review` before auditing for vulnerabilities
- `/coding-standards` before writing new code
- `/tdd-workflow` before adding features or fixing bugs

Slash commands may appear as `/name` or `/name.md` in your agent's autocomplete — use whichever your agent shows.

## Working With Agents

All supported agents read this `AGENTS.md` from the project root and auto-discover skills from `.agents/skills/`. Start your agent from the project root:

- **Claude Code** — run `claude`. Reads `.claude/CLAUDE.md`, which imports this file.
- **Kilo Code** — reads `AGENTS.md` automatically. Optional `kilo.jsonc` for extra config.
- **OpenCode** — reads `AGENTS.md` automatically. Optional `opencode.json` at project root.
- **Codex CLI** — run `codex`. Reads `AGENTS.md` automatically. Global settings in `~/.codex/config.toml`.

## OpenSpec Workflow

This project uses [OpenSpec](https://github.com/Fission-AI/OpenSpec) for spec-driven development. Specs and changes live under `openspec/`.

The full lifecycle (run inside your agent shell):

1. **Propose a change** — agent generates proposal, design, and `tasks.md` under `openspec/changes/`:
   ```text
   /opsx:propose add dark mode support
   ```
2. **Apply the code** — after reviewing/editing `tasks.md`, agent implements and checks off tasks:
   ```text
   /opsx:apply
   ```
3. **Verify and refine** — pass back logs or bug reports to refine:
   ```text
   /opsx:verify The toggle button is invisible on mobile. Fix it.
   ```
4. **Archive** — once tested, merge delta specs into `openspec/specs/` and archive the change folder:
   ```text
   /opsx:archive
   ```

Some agents render commands as `/opsx-propose.md` instead of `/opsx:propose` — both work; use what appears in your autocomplete.

Use multiline prompts when you need to include logs or detailed context with a command.

## What This Repo Is

`workout_log` is a Flutter mobile application (Android-first, iOS-capable) for logging gym workouts — exercises, body parts, sets, reps, and dates. It is published on the Google Play Store (`com.lukk.workoutlog`). Single-app repo, owned by Łukasz Sarna. Current version `1.2.3+8` (see `pubspec.yaml`).

## Architecture

- **Framework**: Flutter (Dart SDK `>=3.8.0 <4.0.0`), Material Design.
- **State management**: Riverpod (`flutter_riverpod` 3.x). `ProviderScope` at the root; pages are `ConsumerWidget` / `ConsumerStatefulWidget`. Static mutable shared state is forbidden — themes, the selected date, and async data flow through providers.
- **Layout under `lib/`**:
  - `data/db/` — `DBProvider` (sqflite DAO).
  - `domain/models/` — freezed immutable value types (`Exercise`, `WorkLog`, `BodyPart`) with generated `*.freezed.dart` + `*.g.dart`.
  - `presentation/providers/` — Riverpod providers (`theme_providers`, `selected_date_provider`, `data_providers`).
  - `presentation/theme/` — `WorkoutColors` `ThemeExtension`, `lightTheme` / `darkTheme`.
  - `presentation/widgets/` — shared widgets (`ResponsiveScaffold`, `ResponsiveDimensions`).
  - `view/` — page widgets (kept at `view/` for now; pending a rename pass to `presentation/pages/*_snake.dart`).
  - `util/util.dart` — screen-size + orientation + date-formatter helpers.
  - `main.dart` — bootstrap (`runApp(ProviderScope(child: MyApp()))`).
- **Persistence**: local-only — `sqflite` for workouts, `shared_preferences` for theme + background-image prefs, `path_provider` for backup file paths. No backend; no network deps.
- **Codegen**: `build_runner` 2.15 driving `freezed` 3.x + `json_serializable` 6.14. Regenerate with `dart run build_runner build`.
- **Key packages**: `flutter_riverpod`, `freezed_annotation`, `table_calendar`, `flutter_slidable`, `intl`, `uuid`, `logging`. Test: `sqflite_common_ffi` for on-host DB tests.
- **Deploy target**: Android (signed AAB to Play Store). iOS configured but not actively published.
- **Constraints**: offline-first (no network layer), single-developer project, conventions enforced via skills in `.agents/skills/` and the OpenSpec workflow for non-trivial changes.
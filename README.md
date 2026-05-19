# workout_log

*Android-first Flutter app for logging gym workouts. Track exercises,
body parts worked, sets and reps per session, dated. Offline-only,
SQLite-backed, no account, no network.*

[Get it on Google Play](https://play.google.com/store/apps/details?id=com.lukk.workoutlog)

## Architecture

```mermaid
graph TB
    subgraph Presentation
        Pages[Pages]
        Widgets[Shared widgets]
        Providers[Riverpod providers]
    end
    subgraph Domain
        Models[Freezed value types]
    end
    subgraph Data
        DAOs[sqflite DAOs]
        Backup[BackupService]
        Alarm[AlarmService]
    end

    Pages --> Providers
    Widgets --> Providers
    Providers --> DAOs
    Providers --> Backup
    Providers --> Alarm
    DAOs --> SQLite[(SQLite on device)]
    Backup --> File[(backup.json on external storage)]
    Alarm --> FLN[flutter_local_notifications]
```

`lib/` follows the standard three-layer split. Pages and widgets read
and write through Riverpod providers; the providers wrap DAOs and
services. Nothing in the presentation layer talks to SQLite or the
notification plugin directly. The domain models in `lib/domain/` are
all `freezed` value types with generated equality and JSON.

## Quick start

Clone the repo, then from the project root run the standard Flutter
bring-up:

```bash
flutter pub get
```

Generate the `freezed` and `json_serializable` outputs (one-time, and
again whenever a model changes):

```bash
dart run build_runner build
```

If a regen fails because stale generated files conflict, wipe them
first:

```bash
dart run build_runner clean
```

(The old `--delete-conflicting-outputs` flag was removed in
`build_runner` 2.15+.)

List attached devices / emulators:

```bash
flutter devices
```

Run on a specific device, where `<deviceId>` is the id printed by the
previous command (e.g. `emulator-5554`):

```bash
flutter run -d <deviceId>
```

Add `-v` for verbose output or `--release` for a release-mode build.

If you hit weird build-cache issues:

```bash
flutter clean
```

## Deployment

Release builds ship to the Google Play Store via a manual GitHub
Actions workflow. See [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md) for
the full procedure: how to trigger a release, the five GitHub secrets
you need to configure (upload keystore + Google Play API service
account), what the workflow actually does step-by-step, common failure
modes and their fixes, and the manual `flutter build appbundle` path
for when CI is unavailable. The first-time keystore-signing setup is
in there too.

## Docs

| File | Covers |
|---|---|
| [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md) | Release process, signing model, GitHub secrets |
| [docs/AGENT_TOOLING.md](./docs/AGENT_TOOLING.md) | How the project is set up for AI coding agents (Claude Code, Codex, etc.) |
| [AGENTS.md](./AGENTS.md) | Agent-facing instructions and skill references |
| [.agents/skills/](./.agents/skills/) | Project-scoped skills (code-formatter, openspec workflow, etc.) |

## License

Personal project, all rights reserved by Łukasz Sarna. No public
license. The source is published for portfolio / agent-tooling
demonstration; not intended for redistribution or repackaging.

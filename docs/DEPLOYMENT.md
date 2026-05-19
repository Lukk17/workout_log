# Deployment

This project ships to the Google Play Store via a manual GitHub Actions
workflow. There are two workflows under `.github/workflows/`:

- **`ci.yml`** — runs automatically on every push to `master` and on every
  PR. Resolves deps, runs `flutter analyze`, runs the test suite with
  coverage, uploads the lcov report as a workflow artifact (14-day
  retention). No `dart format` gate — the project uses a hand-curated
  style the default formatter would revert; see the `code-formatter`
  skill in `.agents/skills/` for the rules. Pinned to Flutter 3.41.9
  + Java 21 (Temurin).
- **`release.yml`** — **manual-only**. Builds a signed AAB and uploads it
  to a chosen Play Store track (internal / alpha / beta / production).
  Never fires on a tag push or a commit — only from the Actions tab.
  Same pinned Flutter + Java versions as CI. Serialised via a
  `concurrency` group so two simultaneous triggers can't race.

## Signing model: upload key vs app signing key

This is the most-misunderstood part of Play publishing, worth
internalising before you touch the secrets.

The app is enrolled in **Play App Signing** with the **app signing key
managed by Google** (the current default for new apps). Two keys exist:

- **App signing key** — held by Google. Signs the APKs delivered to
  users. You never see it; Google doesn't expose it. *This is what
  "Google is signing my app" means.*
- **Upload key** — held by you (`android/workout_log-keystore.jks`).
  Signs the AAB before it gets uploaded to Play. Play verifies the
  upload-key signature, strips it, and re-signs with the Google-held
  app signing key. The upload key is how Play knows the upload
  actually came from you, not someone who stole the service-account
  JSON.

Both keys are required. The `ANDROID_KEYSTORE_BASE64` GitHub secret
is the **upload key** — keep it, back it up, treat it like the
production secret it is. Losing it means going through Play
Console's "Reset upload key" flow, which works but takes a few
business days for Google to action.

## Triggering a release

1. Bump the `version:` line in `pubspec.yaml` (e.g. `2.0.0+9` → `2.0.0+10`).
   The build number after `+` must be **strictly greater** than the last
   one uploaded to Play; Play rejects equal or lower codes.
2. Commit and push to `master`. The CI workflow will run; wait for it to
   go green.
3. Open the repo on GitHub → **Actions** tab → **Release to Play Store**
   on the left → **Run workflow** on the right.
4. Pick a track from the dropdown:
   - `internal` — fastest review, only the testers you've listed in Play
     Console. Default; use it for every dry run.
   - `alpha` / `beta` — closed and open testing tracks.
   - `production` — public release; goes through Play's normal review.
5. Click the green **Run workflow** button.

The job takes ~5–8 minutes. When it finishes:
- The AAB lands in Play Console under the selected track.
- A copy of the AAB is uploaded as a GitHub workflow artifact (kept 30
  days) — handy for sideloading on a test device without going through
  Play.

## Required GitHub secrets

All five secrets live under **Settings → Secrets and variables → Actions
→ New repository secret**. Add them once; they persist across runs.

**Important**: GitHub secrets only store strings, not files. Don't paste
the contents of `android/key.properties` into one big secret — the
workflow rebuilds that file from three discrete secrets so you can
rotate one password without touching the rest. Each password secret
holds the **value only**, no `key=` prefix.

| Secret | What it is | How to produce it |
|---|---|---|
| `ANDROID_KEYSTORE_BASE64` | The **upload-key** keystore, base64-encoded as a one-line string. | See "Encoding the keystore" below. |
| `ANDROID_KEYSTORE_PASSWORD` | The `storePassword` value from your local `android/key.properties` — value only, no `storePassword=` prefix. | You set this when you originally generated the keystore. |
| `ANDROID_KEY_PASSWORD` | The `keyPassword` value from `android/key.properties` — value only. | Often identical to the store password. |
| `ANDROID_KEY_ALIAS` | The alias the upload key is stored under — value only. | Currently `key`. Check `android/key.properties`. |
| `PLAY_SERVICE_ACCOUNT_JSON` | Full JSON of a Google Cloud service account that has been granted upload permission in Play Console. | See "Service account for Play Store API" below. |

### Encoding the keystore

The keystore is a binary `.jks` file. GitHub secrets are text, so it has
to be base64-encoded first.

**Linux / macOS / Git Bash:**

```bash
base64 -w 0 android/workout_log-keystore.jks
```

**PowerShell:**

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes('android/workout_log-keystore.jks'))
```

Copy the entire one-line output and paste it into the
`ANDROID_KEYSTORE_BASE64` secret value field. No quoting, no line breaks.

> The keystore file itself is gitignored (`*.jks` in `.gitignore`) and
> must never be committed.

### Service account for Play Store API

This is the only new piece if you've only ever published manually before.
Play Console will not accept anonymous uploads — every API call has to
be authenticated as a Google account that you've explicitly given
upload permission. A "service account" is a robot Google account meant
exactly for this.

One-time setup, ~10 minutes:

1. **Google Cloud Console** — <https://console.cloud.google.com/>
   1. Create a project (any name; "workout-log-ci" is fine) if you
      don't already have one to bind to.
   2. Navigate to **IAM & Admin → Service Accounts**.
   3. Click **Create service account**. Name it something like
      `play-publisher`. Skip the optional role grant (Play Console
      assigns the permissions, not Cloud IAM).
   4. Click the newly-created service account → **Keys** tab → **Add
      key → Create new key → JSON**. A `.json` file downloads.

2. **Google Play Console** — <https://play.google.com/console>
   1. Open your developer account → **Users and permissions** (left
      sidebar).
   2. Click **Invite new users**.
   3. **Email**: paste the service-account email from step 1 (it looks
      like `play-publisher@your-project.iam.gserviceaccount.com`).
   4. **Permissions → App permissions**: add this app (`Private
      WorkoutLog`).
   5. **Account permissions**: grant **Release manager** (or any role
      that includes "Release apps"). The minimum is "Release apps",
      "View app information", and "Manage testing tracks".
   6. **Send invite**. The service account auto-accepts; no email
      back-and-forth needed.

3. **GitHub secret**
   - Open the JSON file from step 1.4 in a text editor.
   - Copy the entire contents.
   - Paste into the `PLAY_SERVICE_ACCOUNT_JSON` secret value field.

Once that's done, every run of `release.yml` will authenticate as the
service account and push the AAB to the chosen track.

## What `release.yml` actually does

Step-by-step, in case you need to debug a failed run:

1. **Checkout** the repo at the commit you ran from.
2. **Set up Java 21** (Temurin distribution) — matches the
   `JavaVersion.VERSION_21` setting in `android/app/build.gradle`.
3. **Set up Flutter** pinned to `3.41.9` (the version `pubspec.lock`
   was resolved against), with caching so re-runs start in ~30 s
   instead of 3 min.
4. **`flutter pub get`** — resolves dependencies.
5. **`flutter analyze`** — fails fast on any analyzer warning.
6. **`flutter test`** — fails fast on any failing unit/widget test.
7. **Decode keystore**: `printf '%s' "$ANDROID_KEYSTORE_BASE64" | base64
   --decode` writes the upload key to
   `android/workout_log-keystore.jks` (recreating exactly what you
   have locally). `printf` is binary-safe; `echo` can mangle
   backslashes on some shells.
8. **Write `key.properties`** from the three discrete `ANDROID_*`
   password secrets via per-line `printf 'key=%s\n' "$VAL"`. The
   per-line approach beats a heredoc because heredoc variable
   expansion would mangle any password containing `$`, backticks, or
   double quotes.
9. **`flutter build appbundle --release`** — produces an AAB at
   `build/app/outputs/bundle/release/app-release.aab`, signed with
   the upload key. Play will strip this signature and re-sign with
   the app signing key after upload.
10. **Resolve upload status** — the production track is uploaded with
    `status: draft` so a human in Play Console makes the final
    go-live decision. Internal / alpha / beta upload with
    `status: completed` and roll out immediately to that track.
11. **Upload to Play Store** via the `r0adkll/upload-google-play@v1`
    action, using `PLAY_SERVICE_ACCOUNT_JSON` to authenticate. The
    `track` input from the manual trigger picks the destination.
12. **Archive the AAB** as a workflow artifact for 30 days.

## Common failures

**"versionCode … has already been used"** — you didn't bump the build
number. Increment the `+N` part of `version:` in `pubspec.yaml`.

**"The caller does not have permission" from the upload step** — the
service account isn't invited to the Play Console app, or doesn't have
the "Release apps" permission. Re-check step 2 of "Service account for
Play Store API".

**"Package not found: com.lukk.workoutlog"** — the service account is
invited to the Play Console developer account but not granted access to
this specific app. In Play Console → Users and permissions → click the
service account → App permissions → add this app.

**Keystore-related errors during signing** — usually a wrong password
or alias. Easy way to verify the secrets locally: decode
`ANDROID_KEYSTORE_BASE64` to a file, then run
`keytool -list -v -keystore that-file.jks -alias <ANDROID_KEY_ALIAS>`
and enter the password. If `keytool` accepts it, the secrets are
correct; the failure is somewhere else.

## Release notes

The `r0adkll/upload-google-play` action picks up release notes from
`fastlane/metadata/android/<language>/changelogs/<versionCode>.txt` if
that file exists. For example, after bumping to `2.0.0+10`:

```
fastlane/metadata/android/en-US/changelogs/10.txt
```

That tree is optional — if absent, Play Console leaves the "What's new"
field blank and you can fill it in manually before promoting from
internal → production.

## Rolling back

There's no automated rollback in this setup. If a release on production
turns out to be broken:

1. In Play Console → Production track → halt the rollout.
2. Promote the previous build (still in the release history) back to
   100 %.
3. Investigate, fix, and ship a new build with an incremented
   `versionCode` — Play never lets you re-use a code.

## Bypassing the workflow — manual build + upload

If GitHub Actions is down, or you want to ship from a branch the
workflow won't touch, the manual path still works.

### Prerequisite — local signing config

The first time you build a release on a fresh machine, you need the
keystore + `key.properties` on disk. Copy the keystore (`*.jks`) into
`android/`, then create `android/key.properties` next to it:

```
storePassword=<store password>
keyPassword=<key password>
keyAlias=key
storeFile=workout_log-keystore.jks
```

Both files are gitignored. The Gradle build reads `key.properties`
and uses the credentials to sign the release AAB.

### Build the AAB

1. Bump the `version:` line in `pubspec.yaml` (must increase the build
   number after `+`).
2. Run from the repo root:

   ```
   flutter build appbundle --release
   ```

3. The signed bundle lands at:

   ```
   build/app/outputs/bundle/release/app-release.aab
   ```

   Rename it to `workout_log-X.Y.Z.aab` if you want — Play Console
   doesn't care about the filename.

### Upload via Play Console

1. Open <https://play.google.com/console>.
2. Pick the app → **Release** → choose a track (Internal testing is
   the safest first stop).
3. **Create new release** → upload the `.aab`.
4. Add release notes; click **Review release**, then **Start rollout**.

Internal testing reaches your listed testers in ~minutes; promoting
through alpha → beta → production triggers Play's normal review.

## First-time signing setup

If you've cloned the repo on a brand-new machine and don't have a
keystore yet, generate one once and never lose it — every future
release **must** be signed by the same keystore or Play refuses the
upload:

```
keytool -genkey -v -keystore workout_log-keystore.jks \
        -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

Move the resulting `workout_log-keystore.jks` into the `android/`
folder, then create `android/key.properties` as described above.

Back it up somewhere safe (password manager, encrypted cloud backup) —
losing the keystore means the app can never be updated under the same
package name on Play.

# Deployment

This project ships to the Google Play Store via a manual GitHub Actions
workflow. Two workflows live under `.github/workflows/`:

- **`ci.yml`** runs automatically on every push to `master` and on every
  PR. It resolves deps, runs `flutter analyze`, runs the test suite
  with coverage, and uploads the lcov report as a workflow artifact
  (14-day retention). There's no `dart format` gate: the project uses
  a hand-curated style the default formatter would revert. See the
  `code-formatter` skill in `.agents/skills/` for the rules. Pinned to
  Flutter 3.41.9 and Java 21 (Temurin).
- **`release.yml`** is **manual-only**. Five jobs in sequence with
  two manual approval gates: `verify-version` → `verify` → `build` →
  *(gate)* → `play-store-release` → *(gate)* → `github-release`. The
  AAB is built once and consumed by both the Play upload and the
  GitHub Release. Each gate is a GitHub Environment (see "Environment
  gates" below). It never fires on a tag push or a commit; only from
  the Actions tab. Same pinned Flutter + Java versions as CI.
  Serialised via a `concurrency` group so two simultaneous triggers
  can't race, and `cancel-in-progress: false` so a run paused at a
  gate isn't killed by a fresh trigger.

## Signing model: upload key vs app signing key

Worth getting clear before you touch the secrets.

The app is enrolled in **Play App Signing** with the **app signing key
managed by Google** (the current default for new apps). Two keys exist:

- **App signing key**. Held by Google, signs the APKs delivered to
  users. You never see it; Google doesn't expose it. *This is what
  "Google is signing my app" means.*
- **Upload key**. Held by you in `android/workout_log-keystore.jks`.
  Signs the AAB before it gets uploaded to Play. Play verifies the
  upload-key signature, strips it, and re-signs with the Google-held
  app signing key. The upload key is how Play knows the upload
  actually came from you, not someone who stole the service-account
  JSON.

Both keys are required. The `ANDROID_KEYSTORE_BASE64` GitHub secret is
the **upload key** — keep it, back it up, treat it like production.
Losing it means going through Play Console's "Reset upload key" flow,
which works but takes a few business days for Google to action.

## Environment gates

The two manual gates are GitHub Environments with a required reviewer.
They exist once per repo, not per release. One-time setup:

1. Repo **Settings → Environments → New environment**.
2. Create `play-store`. Enable **Required reviewers**, add yourself.
3. Create `github-release`. Enable **Required reviewers**, add yourself.

The job YAML references these names verbatim (`environment: play-store`
and `environment: github-release` in `release.yml`). If you rename one
in the UI you must rename it in the YAML too, or the gated job will
sit in "waiting" with no reviewer queue to satisfy it.

Protected environments are free on **public** repos for all accounts.
On private repos they require GitHub Pro / Team / Enterprise.

## Triggering a release

1. Bump the `version:` line in `pubspec.yaml` (e.g. `2.0.0+9` → `2.0.0+10`).
   The build number after `+` must be **strictly greater** than the last
   one uploaded to Play; Play rejects equal or lower codes. The semver
   prefix (`2.0.0`) becomes the GitHub Release tag (`v2.0.0`), so if a
   release with that tag already exists, also bump the semver.
2. Commit and push to `master`. The CI workflow runs; wait for it to
   go green.
3. Open the repo on GitHub → **Actions** tab → **Release** on the left
   → **Run workflow** on the right.
4. Pick a track from the dropdown:
   - `internal`: fastest review, only the testers you've listed in
     Play Console. Default; use it for every dry run.
   - `alpha` / `beta`: closed and open testing tracks.
   - `production`: public release; goes through Play's normal review.
5. Click the green **Run workflow** button. The first three jobs
   (`verify-version`, `verify`, `build`) run automatically; ~5 min.
6. **First gate.** When `build` finishes, the run pauses on
   `play-store-release` with a "Review deployments" button. Glance at
   Play Console to confirm you're ready to ship, then click **Approve
   and deploy**. The upload to Play runs (~1 min).
7. **Second gate.** When Play upload finishes, the run pauses on
   `github-release`. Open Play Console and confirm the draft / release
   landed correctly on the chosen track. Approve the gate. The
   GitHub Release is created with the AAB attached (~10 s).

End-to-end with prompt approvals: ~7–9 minutes. If you walk away
between gates the run waits up to 30 days for approval (idle runs
don't burn CI minutes).

When it finishes:

- The AAB lands in Play Console under the selected track.
- A copy of the AAB is uploaded as a GitHub workflow artifact (kept 30
  days), handy for sideloading on a test device without going through
  Play.
- A **GitHub Release** is published at
  `https://github.com/<owner>/<repo>/releases/tag/v<semver>`, with the
  AAB attached as a downloadable asset (renamed to
  `workout_log-<version>.aab` on the release page) and auto-generated
  release notes drawn from commits and PR titles since the previous
  tag.

## Enrolling testers (internal and closed tracks)

Internal testing and closed testing tracks are gated by an opt-in URL
per testers list. Adding a tester's email in Play Console is **not
enough** — the tester must open the per-list opt-in URL while signed
into Google as the listed email, click **Become a tester**, and
accept. Only then will the Play Store on their device show the new
track's build.

This is **distinct from the public open-testing (beta) program**,
which has its own join link on the app's Play Store page. Joining the
public beta does *not* enroll you in internal testing.

### Where to find the opt-in URL

Play Console → your app → **Testing → Internal testing** → **Testers**
tab → scroll to **"How testers join your test"** → there's a **Copy
link** button for each list. The URL looks like
`https://play.google.com/apps/internaltest/<numeric-id>`.

Closed testing tracks have the same flow under **Testing → Closed
testing**, with a different URL per list.

### Per-tester one-time setup

1. On the tester's device, confirm Play Store is signed in with the
   exact email that's on the testers list. Play Store → top-right
   avatar → check the active account; switch if needed.
2. Open the opt-in URL on that device (or in a browser signed into
   Google as the tester account).
3. Tap **Become a tester**. You'll get a confirmation page.
4. Open the app's Play Store listing. If production was already
   installed, you'll see an **Update** button for the internal-track
   build. Otherwise, **Install**.
5. If the update doesn't appear within 5–10 minutes, force-stop Play
   Store and re-open the app page. First-time enrollment can take up
   to an hour to propagate.

### Confirming enrollment from Play Console

Play Console → Testing → Internal testing → **Testers** tab → each
list shows the count of testers who have **accepted** the invite, not
just been added. If the counter doesn't tick up after the tester taps
"Become a tester", something went wrong — wrong Google account on the
device, typo in the testers list email, or the URL was opened in a
browser signed into a different account than the device's Play Store.

## Required GitHub secrets

All five secrets live under **Settings → Secrets and variables → Actions
→ New repository secret**. Add them once; they persist across runs.

**Important**: GitHub secrets only store strings, not files. Don't paste
the contents of `android/key.properties` into one big secret. The
workflow rebuilds that file from three discrete secrets so you can
rotate one password without touching the rest. Each password secret
holds the **value only**, no `key=` prefix.

| Secret | What it is | How to produce it |
|---|---|---|
| `ANDROID_KEYSTORE_BASE64` | The **upload-key** keystore, base64-encoded as a one-line string. | See "Encoding the keystore" below. |
| `ANDROID_KEYSTORE_PASSWORD` | The `storePassword` value from your local `android/key.properties`. Value only, no `storePassword=` prefix. | You set this when you originally generated the keystore. |
| `ANDROID_KEY_PASSWORD` | The `keyPassword` value from `android/key.properties`. Value only. | Often identical to the store password. |
| `ANDROID_KEY_ALIAS` | The alias the upload key is stored under. Value only. | Currently `key`. Check `android/key.properties`. |
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
`ANDROID_KEYSTORE_BASE64` secret value field. No quoting, no line
breaks.

> The keystore file itself is gitignored (`*.jks` in `.gitignore`) and
> must never be committed.

### Service account for Play Store API

This is the only new piece if you've only ever published manually
before. Play Console will not accept anonymous uploads; every API call
has to be authenticated as a Google account that you've explicitly
given upload permission. A "service account" is a robot Google account
meant exactly for this.

One-time setup, about 10 minutes:

1. **Google Cloud Console** at <https://console.cloud.google.com/>
   1. Create a project (any name; "workout-log-ci" is fine) if you
      don't already have one to bind to.
   2. **Enable the Google Play Android Developer API** for this
      project. Open
      <https://console.cloud.google.com/apis/library/androidpublisher.googleapis.com>
      (the URL pre-selects the API; pick your project in the
      top-bar selector if it isn't already), then click **Enable**.
      Wait 2–3 minutes after enabling before the first release-
      workflow run; the enablement takes a moment to propagate and
      uploads in the meantime fail with "Google Play Android
      Developer API has not been used in project N before or it is
      disabled" (see Common failures below).
   3. Navigate to **IAM & Admin → Service Accounts**.
   4. Click **Create service account**. Name it something like
      `play-publisher`. Skip the optional role grant (Play Console
      assigns the permissions, not Cloud IAM).
   5. Click the newly-created service account → **Keys** tab → **Add
      key → Create new key → JSON**. A `.json` file downloads.

2. **Google Play Console** at <https://play.google.com/console>
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
   - Open the JSON file from step 1.5 in a text editor.
   - Copy the entire contents.
   - Paste into the `PLAY_SERVICE_ACCOUNT_JSON` secret value field.

Once that's done, every run of `release.yml` will authenticate as the
service account and push the AAB to the chosen track.

## What `release.yml` actually does

Step-by-step per job, in case you need to debug a failed run.

### Job 1: `verify-version` (~10 s)

1. Checkout.
2. **Parse `version:` from `pubspec.yaml`**, e.g. `2.0.0+9`. Strip the
   `+<build>` suffix to derive the semver (`2.0.0`) and the tag
   (`v2.0.0`). Both values are exposed as job outputs for downstream
   jobs.
3. **Check GitHub Releases for the tag**: `gh release view v<semver>`.
   If a release with that tag already exists, fail the job - the
   `github-release` step at the end of the pipeline would collide on
   `gh release create`. Fix is to bump the semver in `pubspec.yaml`.

### Job 2: `verify` (~2 min)

1. Checkout.
2. **Set up Java 21** (Temurin distribution). Matches the
   `JavaVersion.VERSION_21` setting in `android/app/build.gradle`.
3. **Set up Flutter** pinned to `3.41.9`, with caching.
4. **`flutter pub get`** resolves dependencies.
5. **`flutter analyze`** fails fast on any analyzer warning.
6. **`flutter test`** fails fast on any failing unit/widget test.

Keystore secrets are deliberately out of scope here - this job
shouldn't see them.

### Job 3: `build` (~3 min)

1. Checkout, set up Java + Flutter, `flutter pub get` (same as
   `verify`; the duplicated setup is the cost of isolating
   failure modes).
2. **Decode keystore**: `printf '%s' "$ANDROID_KEYSTORE_BASE64" | base64
   --decode` writes the upload key to
   `android/workout_log-keystore.jks` (recreating exactly what you
   have locally). `printf` is binary-safe; `echo` can mangle
   backslashes on some shells.
3. **Write `key.properties`** from the three discrete `ANDROID_*`
   password secrets via per-line `printf 'key=%s\n' "$VAL"`. The
   per-line approach beats a heredoc because heredoc variable
   expansion would mangle any password containing `$`, backticks, or
   double quotes.
4. **`flutter build appbundle --release`** produces an AAB at
   `build/app/outputs/bundle/release/app-release.aab`, signed with
   the upload key. Play strips this signature and re-signs with the
   app signing key after upload.
5. **Upload the AAB as a workflow artifact** (`app-release-aab`,
   30-day retention). Downstream jobs download from here rather
   than re-building.

### Gate: `play-store` environment approval

The run pauses. Reviewer (you) clicks "Review deployments" → approve
in the GitHub UI. No CI minutes consumed while paused.

### Job 4: `play-store-release` (~1 min)

1. **Download the AAB** from the `app-release-aab` artifact into
   `build/app/outputs/bundle/release/`.
2. **Resolve upload status**: the production track is uploaded with
   `status: draft` so a human in Play Console makes the final
   go-live decision. Internal / alpha / beta upload with
   `status: completed` and roll out immediately to that track.
3. **Upload to Play Store** via the `r0adkll/upload-google-play@v1`
   action, using `PLAY_SERVICE_ACCOUNT_JSON` to authenticate. The
   `track` input from the manual trigger picks the destination.

The keystore is *not* re-decoded here - the AAB is already signed,
and this job has no business touching the upload key.

### Gate: `github-release` environment approval

Second pause. Confirm Play upload landed correctly in Play Console
before approving. If something went wrong on the Play side, *don't*
approve - debug Play first, re-run the `play-store-release` job if
needed, then resume.

### Job 5: `github-release` (~10 s)

1. Checkout (at the same commit `verify-version` ran on).
2. **Download the AAB** from the `app-release-aab` artifact into
   `dist/`.
3. **`gh release create`** with the tag from `verify-version`'s
   outputs (`v<semver>`), the AAB attached and renamed on the release
   page to `workout_log-<full-version>.aab`, and `--generate-notes`
   to auto-build release notes from PRs and commits since the
   previous tag. Tag is created against the commit that triggered
   the workflow run.

This job needs `contents: write` permission to push the tag and
attach assets; the top-level `permissions: contents: read` is
overridden at the job level.

## Common failures

**"GitHub Release 'vX.Y.Z' already exists"** from `verify-version`:
the semver in `pubspec.yaml` matches an existing tagged release. Bump
the semver (e.g. `2.0.0` → `2.0.1`) and re-trigger. This is the
fail-fast gate that exists specifically to stop you from doing a
3-minute build that can't land.

**"versionCode … has already been used"**: you didn't bump the build
number. Increment the `+N` part of `version:` in `pubspec.yaml`.

**"Google Play Android Developer API has not been used in project N
before or it is disabled"**: the Cloud Console project that owns your
service account doesn't have the Android Publisher API enabled yet.
Open
<https://console.cloud.google.com/apis/library/androidpublisher.googleapis.com>,
make sure the top-bar project selector matches the project number from
the error message, click **Enable**, wait 2–3 minutes for propagation,
then re-run the failed job in Actions (the **"Re-run failed jobs"**
button on the failed run's page; uses the same workflow run id, so
the same versionCode applies — no `pubspec.yaml` bump needed).

**"The caller does not have permission" from the upload step**: the
service account isn't invited to the Play Console app, or doesn't have
the "Release apps" permission. Re-check step 2 of "Service account for
Play Store API".

**"Package not found: com.lukk.workoutlog"**: the service account is
invited to the Play Console developer account but not granted access to
this specific app. In Play Console → Users and permissions → click the
service account → App permissions → add this app.

**Keystore-related errors during signing**: usually a wrong password or
alias. Easy way to verify the secrets locally: decode
`ANDROID_KEYSTORE_BASE64` to a file, then run
`keytool -list -v -keystore that-file.jks -alias <ANDROID_KEY_ALIAS>`
and enter the password. If `keytool` accepts it, the secrets are
correct; the failure is somewhere else.

**"I'm on the testers list but the internal-track build isn't showing
up in my Play Store"**: the tester hasn't opted in via the per-list
URL, or opted in while signed into the wrong Google account. See
"Enrolling testers (internal and closed tracks)" above. Joining the
public open-beta program is *not* the same as opting into internal
testing.

## Release notes

The `r0adkll/upload-google-play` action picks up release notes from
`fastlane/metadata/android/<language>/changelogs/<versionCode>.txt` if
that file exists. For example, after bumping to `2.0.0+10`:

```
fastlane/metadata/android/en-US/changelogs/10.txt
```

That tree is optional. If absent, Play Console leaves the "What's new"
field blank and you can fill it in manually before promoting from
internal to production.

## Rolling back

There's no automated rollback in this setup. If a release on production
turns out to be broken:

1. In Play Console → Production track → halt the rollout.
2. Promote the previous build (still in the release history) back to
   100 %.
3. Investigate, fix, and ship a new build with an incremented
   `versionCode`. Play never lets you re-use a code.

## Bypassing the workflow: manual build + upload

If GitHub Actions is down, or you want to ship from a branch the
workflow won't touch, the manual path still works.

### Prerequisite: local signing config

The first time you build a release on a fresh machine, you need the
keystore and `key.properties` on disk. Copy the keystore (`*.jks`) into
`android/`, then create `android/key.properties` next to it:

```
storePassword=<store password>
keyPassword=<key password>
keyAlias=key
storeFile=workout_log-keystore.jks
```

Both files are gitignored. The Gradle build reads `key.properties` and
uses the credentials to sign the release AAB.

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

   Rename it to `workout_log-X.Y.Z.aab` if you want; Play Console
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
keystore yet, generate one once and never lose it. Every future release
**must** be signed by the same keystore or Play refuses the upload:

```
keytool -genkey -v -keystore workout_log-keystore.jks \
        -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

Move the resulting `workout_log-keystore.jks` into the `android/`
folder, then create `android/key.properties` as described above.

Back it up somewhere safe (password manager, encrypted cloud backup).
Losing the keystore means the app can never be updated under the same
package name on Play.

## Convention note: shell snippets in this doc

Pure-CLI commands that work identically on bash and PowerShell
(`flutter ...`, `keytool ...`, `git ...`) ship in a single fence. Only
shell-specific syntax (variable expansion, redirection idioms, base64
with `-w 0`) gets a bash + PowerShell pair. If you're auditing this
doc against the project's `markdown-writer` convention, the absent
PowerShell pairs are intentional under this carve-out, not an
oversight.

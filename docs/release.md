# Release Guide

QuizForge releases must be reproducible, tested, and based on a clean repository state.

The maintained release candidate is **2.7.4+1** and its public Git tag, after verification, is **`v2.7.4`**. The in-app public version displayed by `AppConstants.version` is **2.7.4**.

## Release prerequisites

Before creating or promoting a release candidate:

- `main` is up to date and clean;
- the version in `pubspec.yaml` is intentional;
- `AppConstants.version` matches the public package version shown to users;
- `tool/check_release_metadata.py` confirms that package, in-app, changelog, and versioning metadata agree;
- the reviewed application `pubspec.lock` is tracked and matches `pubspec.yaml` after locked dependency resolution;
- `CHANGELOG.md`, `ROADMAP.md`, and `what_changed.md` are current;
- repository/tool regression tests pass;
- repository-local Markdown links pass `tool/check_markdown_links.py`;
- localization catalogs pass `tool/check_arb_catalogs.py` and `flutter gen-l10n`;
- all six Flutter platform runners can be generated from documented commands;
- the Web runner contains compatible Drift SQLite WASM/worker assets;
- no credentials, signing secrets, real backup archives, or private user data are tracked;
- CI is green on the exact final head;
- dependency/security checks have been reviewed on the exact final head;
- applicable local-backup restore, manual accessibility, platform interaction, and real-screenshot checks in `docs/verification.md` are complete.

See [`platform-support.md`](platform-support.md) for the six-platform runtime contract.

## Clean verification

From a fresh clone:

```bash
flutter create . --platforms=android,ios,web,windows,macos,linux
python3 tool/prepare_web_assets.py --destination web
python3 tool/test_check_markdown_links.py
python3 tool/test_check_arb_catalogs.py
python3 tool/test_check_release_metadata.py
python3 tool/test_prepare_web_assets.py
python3 tool/check_markdown_links.py
python3 tool/check_arb_catalogs.py
python3 tool/check_release_metadata.py
flutter pub get --enforce-lockfile
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

On Windows, use `python` instead of `python3` when that is the configured launcher.

The release workflow intentionally fails when `pubspec.lock` is missing, empty, incompatible with `pubspec.yaml`, or rewritten by locked dependency resolution. A queued, pending, cancelled, or superseded remote check is not evidence of a passing release candidate.

## Release metadata gate

`tool/check_release_metadata.py` is the early, Flutter-independent release identity gate. For 2.7.4 it verifies:

- exactly one canonical package version with the `MAJOR.MINOR.PATCH+BUILD` form, no leading-zero SemVer components, and a positive build number;
- exactly one semantic `AppConstants.version` that matches public version `2.7.4`;
- a dated `CHANGELOG.md` entry matching public version `2.7.4`;
- valid ISO calendar dates in recognized changelog release headings;
- unique release headings in descending version order, including historical zero-major entries;
- no stale pre-1.0 compatibility policy while the package is on a stable major version;
- maintained package identity `2.7.4+1` and tag identity `v2.7.4` in `docs/versioning.md`.

Its regression suite is `tool/test_check_release_metadata.py`.

## Cross-platform database/runtime preparation

Native Android, iOS, Windows, macOS, and Linux use the native `drift_flutter` database path.

Web uses explicit `DriftWebOptions` and requires `sqlite3.wasm` plus a compatible worker. The maintained preparation command is:

```bash
python3 tool/prepare_web_assets.py --destination web
```

The script is pinned to the maintained Drift 2.34.3 line and validates the asset shape before writing it. After a Web release build, verify those files actually reached the output:

```bash
python3 tool/prepare_web_assets.py --destination build/web --check
```

A successful Web compile without these runtime files is not sufficient release evidence. Deployment must also serve `.wasm` using the WebAssembly MIME type and a real-browser smoke test must verify database creation, persistence, refresh/reload behavior, and backup restore.

## Local backup/restore verification

A release that includes the local-backup feature must perform a smoke restore with fictional data on the exact release candidate rather than relying only on source-level unit tests.

Create a fixture state containing at least:

- one custom question;
- at least two local profiles;
- a bookmark;
- a completed attempt with submitted-answer history;
- non-default settings;
- a non-default active profile.

Then:

1. export a complete local backup;
2. save the archive in a location controlled by the tester;
3. mutate/reset the current app state;
4. paste and restore the saved archive;
5. verify questions, profiles, active-profile selection, bookmark, progress/history, and settings return;
6. verify restore requires the destructive-replacement confirmation;
7. verify a malformed/unsupported archive fails safely without exposing raw archive content;
8. repeat on Android and Web release builds;
9. perform a native-desktop restore smoke check on at least one desktop target and expand that coverage for platforms actually distributed.

Do not use real user backup archives as public release evidence. `docs/local-backup.md` defines the format/limitations, including schema-version-1 answer-order semantics.

## Android

Release packaging:

```bash
flutter build apk --release
flutter build appbundle --release
```

The tagged workflow publishes both APK and AAB artifacts after the shared verification job passes.

A store release requires separate signing configuration. Never commit keystores, passwords, service-account credentials, or `key.properties` values containing secrets.

## Web

```bash
python3 tool/prepare_web_assets.py --destination web
flutter build web --release
python3 tool/prepare_web_assets.py --destination build/web --check
```

Before publishing a Web build, verify database creation, refresh/reload persistence, question-bank import/export, complete local-backup restore, browser storage behavior, clipboard behavior, and correct WebAssembly serving.

## Linux

On a supported Linux host:

```bash
flutter config --enable-linux-desktop
flutter build linux --release
```

The tagged workflow packages the x64 release bundle as a `.tar.gz` artifact.

## Windows

On a supported Windows host:

```powershell
flutter config --enable-windows-desktop
flutter build windows --release
```

The tagged workflow packages the x64 release output as a `.zip` artifact.

## macOS

On macOS/Xcode:

```bash
flutter config --enable-macos-desktop
flutter build macos --release
```

The tagged workflow packages the generated release output. Distribution signing/notarization remains a separate maintainer activity and must not expose credentials in the public repository.

## iOS

On macOS/Xcode, compile verification without signing uses:

```bash
flutter build ios --release --no-codesign
```

The tagged workflow can publish an artifact explicitly named `ios-unsigned` as compile evidence. **That artifact is not represented as an App Store/device-signed distribution build.** Real iOS distribution requires certificates/profiles and signing outside the public repository.

## Tagged cross-platform release pipeline

`.github/workflows/release.yml` uses a gated multi-job design.

### 1. Verify source once

Before any platform packaging starts, the workflow:

- verifies the Git tag matches the public package version;
- requires the committed application lockfile;
- runs all repository/tool regression tests and validators;
- enforces locked dependency resolution;
- generates localizations;
- checks formatting;
- runs Flutter analysis and tests with coverage.

### 2. Build/package all supported targets

After verification, host-specific jobs produce:

- Android APK;
- Android AAB;
- Web release bundle with validated WASM/worker assets;
- Linux x64 bundle;
- Windows x64 bundle;
- macOS release output;
- unsigned iOS release compile output.

Each job independently uses `flutter pub get --enforce-lockfile` and verifies that dependency resolution does not rewrite `pubspec.lock`.

### 3. Publish only after all platform jobs pass

The final publication job depends on every platform job. It downloads the immutable workflow artifacts, creates SHA-256 checksums, and then creates the GitHub release. Only this final job has `contents: write` permission.

This means a failed Windows/macOS/Linux/iOS/Android/Web packaging job prevents publication instead of creating a knowingly partial cross-platform release.

## Versioning

Use Semantic Versioning:

- patch: compatible fixes;
- minor: compatible functionality;
- major: incompatible public data/API behavior that cannot be handled through a reasonable migration/compatibility path.

The local-backup `format`/`version` contract is independent from the app package version. QuizForge 2.7.4 continues to use local-backup format version 1. A breaking backup-format change must use a new backup version and document migration/compatibility behavior rather than silently reinterpreting version 1.

Flutter's build number follows the `+N` suffix in `pubspec.yaml` and should increase for store submissions as required by the target store. A build-number-only store rebuild of 2.7.4 still uses the public tag/version `v2.7.4` when no SemVer-visible behavior changes. `AppConstants.version` remains the public SemVer without the build suffix.

## Tagging 2.7.4

Only tag after the exact 2.7.4 release commit passes all required checks and manual release blockers are recorded as complete:

```bash
git tag -s v2.7.4 -m "QuizForge v2.7.4"
git push origin v2.7.4
```

For later releases, substitute the matching `vX.Y.Z` value.

If signed tags are not available in the execution environment, do not falsely claim a signed release.

## Release notes

Release notes should include:

- user-visible additions and changes;
- fixes;
- security/privacy changes;
- known limitations;
- migration or data-format notes;
- local-backup compatibility notes when applicable;
- verified platforms and exact build scope;
- signing/provisioning state for mobile/desktop artifacts where relevant.

The maintained 2.7.4 notes are in [`release-notes-2.7.4.md`](release-notes-2.7.4.md).

Do not describe an unverified build as supported by that release merely because source code contains a target runner or an older head passed compilation.

## Post-release

After publication:

1. verify downloadable artifacts/checksums where provided;
2. ensure `CHANGELOG.md` reflects the published release version/date and has a fresh Unreleased section;
3. confirm the installed/About version still matches the published public version;
4. update `what_changed.md` and `docs/verification.md` with the exact tag and release commit;
5. record actual verified platform scope and any remaining limitations in the release notes;
6. complete distribution signing/notarization/provisioning separately where required;
7. record any store/distribution-specific follow-up separately from open-source source control.

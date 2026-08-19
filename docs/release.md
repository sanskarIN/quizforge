# Release Guide

QuizForge releases must be reproducible, tested, and based on a clean repository state.

The maintained release candidate is **2.7.4+1** and its public Git tag, after verification, is **`v2.7.4`**.

## Release prerequisites

Before creating or promoting a release candidate:

- `main` is up to date and clean;
- the version in `pubspec.yaml` is intentional;
- `tool/check_release_metadata.py` confirms that package, changelog, and versioning metadata agree;
- the reviewed application `pubspec.lock` is tracked and matches `pubspec.yaml` after locked dependency resolution;
- `CHANGELOG.md`, `ROADMAP.md`, and `what_changed.md` are current;
- repository-validator regression tests pass;
- repository-local Markdown links pass `tool/check_markdown_links.py`;
- localization catalogs pass `tool/check_arb_catalogs.py` and `flutter gen-l10n`;
- all required platform runner files can be generated from documented commands;
- no credentials, signing secrets, real backup archives, or private user data are tracked;
- CI is green on the exact final head;
- dependency/security checks have been reviewed on the exact final head;
- applicable local-backup restore, manual accessibility, platform interaction, and real-screenshot checks in `docs/verification.md` are complete.

## Clean verification

From a fresh clone:

```bash
flutter create . --platforms=android,ios,web,windows,macos,linux
python3 tool/test_check_markdown_links.py
python3 tool/test_check_arb_catalogs.py
python3 tool/test_check_release_metadata.py
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

- exactly one package version with the `MAJOR.MINOR.PATCH+BUILD` form and a positive build number;
- a dated `CHANGELOG.md` entry matching public version `2.7.4`;
- unique release headings in descending version order, including historical zero-major entries;
- no stale pre-1.0 compatibility policy while the package is on a stable major version;
- maintained package identity `2.7.4+1` and tag identity `v2.7.4` in `docs/versioning.md`.

Its regression suite is `tool/test_check_release_metadata.py`. Both the validator and its tests run in pull-request CI and the tag release workflow.

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
8. repeat on Android and Web release builds when those targets are released;
9. perform a native-desktop restore smoke check on an applicable host when a desktop target is included.

Do not use real user backup archives as public release evidence. `docs/local-backup.md` defines the format/limitations, including schema-version-1 answer-order semantics.

## Android

Debug verification:

```bash
flutter build apk --debug
```

Release packaging:

```bash
flutter build apk --release
flutter build appbundle --release
```

A store release requires separate signing configuration. Never commit keystores, passwords, service-account credentials, or `key.properties` values containing secrets.

## Web

```bash
flutter build web --release
```

Before publishing a web build, verify Drift's web runtime assets for the exact dependency/toolchain version and test database creation, refresh/reload, persistence, question-bank import/export, complete local-backup restore, and browser storage behavior in the built artifact.

## Desktop

Desktop release builds must be produced on the corresponding supported host where Flutter requires it:

```bash
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

Do not claim a desktop artifact was verified when it was not built on an appropriate host. The pull-request platform matrix supplies compile/build evidence on GitHub-hosted runners; it does not replace installer and interaction testing on representative devices.

## iOS

On macOS with a valid Xcode environment:

```bash
flutter build ios --release
```

The pull-request matrix performs an iOS release compile with `--no-codesign`. Distribution signing/provisioning is external to the open-source repository and must not expose private certificates or profiles.

## Versioning

Use Semantic Versioning:

- patch: compatible fixes;
- minor: compatible functionality;
- major: incompatible public data/API behavior that cannot be handled through a reasonable migration/compatibility path.

The local-backup `format`/`version` contract is independent from the app package version. QuizForge 2.7.4 continues to use local-backup format version 1. A breaking backup-format change must use a new backup version and document migration/compatibility behavior rather than silently reinterpreting version 1.

Flutter's build number follows the `+N` suffix in `pubspec.yaml` and should increase for store submissions as required by the target store. A build-number-only store rebuild of 2.7.4 still uses the public tag/version `v2.7.4` when no SemVer-visible behavior changes.

## Tagging 2.7.4

Only tag after the exact 2.7.4 release commit passes all required checks and manual release blockers are recorded as complete:

```bash
git tag -s v2.7.4 -m "QuizForge v2.7.4"
git push origin v2.7.4
```

For later releases, substitute the matching `vX.Y.Z` value.

If signed tags are not available in the execution environment, do not falsely claim a signed release.

The tag-triggered GitHub Actions release workflow independently verifies the tag/version relationship, requires the committed lockfile, reruns Markdown/ARB/release-metadata validator tests and validators, resolves dependencies with `--enforce-lockfile`, verifies the lockfile was not rewritten, generates localizations, reruns formatting/analysis/test gates, builds Android/Web release artifacts, creates SHA-256 checksums, uploads workflow artifacts, and publishes the GitHub release.

A future release-workflow edit should keep all repository validator/test sequences aligned with CI/local scripts rather than allowing release automation to bypass a pull-request gate.

## Release notes

Release notes should include:

- user-visible additions and changes;
- fixes;
- security/privacy changes;
- known limitations;
- migration or data-format notes;
- local-backup compatibility notes when applicable;
- verified platforms and exact build scope.

The maintained 2.7.4 notes are in [`release-notes-2.7.4.md`](release-notes-2.7.4.md).

Do not describe an unverified build as supported by that release merely because source code contains a target runner.

## Post-release

After publication:

1. verify downloadable artifacts/checksums where provided;
2. ensure `CHANGELOG.md` reflects the published release version/date and has a fresh Unreleased section;
3. update `what_changed.md` and `docs/verification.md` with the exact tag and release commit;
4. record actual verified platform scope and any remaining limitations in the release notes;
5. record any store/distribution-specific follow-up separately from open-source source control.

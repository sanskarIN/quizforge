# Release Guide

QuizForge releases must be reproducible, tested, and based on a clean repository state.

## Release prerequisites

Before creating a release candidate:

- `main` is up to date and clean;
- the version in `pubspec.yaml` is intentional;
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
python3 tool/check_markdown_links.py
python3 tool/check_arb_catalogs.py
flutter pub get --enforce-lockfile
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

On Windows, use `python` instead of `python3` when that is the configured launcher.

The release workflow intentionally fails when `pubspec.lock` is missing, empty, incompatible with `pubspec.yaml`, or rewritten by locked dependency resolution. A queued, pending, cancelled, or superseded remote check is not evidence of a passing release candidate.

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

Use Semantic Versioning where practical:

- patch: compatible fixes;
- minor: compatible functionality;
- major: incompatible public data/API behavior.

The local-backup `format`/`version` contract is independent from the app package version. A breaking backup-format change must use a new backup version and document migration/compatibility behavior rather than silently reinterpreting version 1.

Flutter's build number follows the `+N` suffix in `pubspec.yaml` and should increase for store submissions as required by the target store.

## Tagging

Only tag after the release commit passes required checks:

```bash
git tag -s vX.Y.Z -m "QuizForge vX.Y.Z"
git push origin vX.Y.Z
```

If signed tags are not available in the execution environment, do not falsely claim a signed release.

The tag-triggered GitHub Actions release workflow independently verifies the tag/version relationship, requires the committed lockfile, resolves dependencies with `--enforce-lockfile`, verifies the lockfile was not rewritten, generates localizations, reruns formatting/documentation-link/analysis/test gates, builds Android/Web release artifacts, creates SHA-256 checksums, uploads workflow artifacts, and publishes the GitHub release.

A future release-workflow edit should keep the ARB validation/tool-test sequence aligned with CI/local scripts rather than allowing release automation to bypass repository-input validation.

## Release notes

Release notes should include:

- user-visible additions and changes;
- fixes;
- security/privacy changes;
- known limitations;
- migration or data-format notes;
- local-backup compatibility notes when applicable;
- verified platforms and exact build scope.

Do not describe an unverified build as supported by that release merely because source code contains a target runner.

## Post-release

After publication:

1. verify downloadable artifacts/checksums where provided;
2. update `CHANGELOG.md` from Unreleased to the release version/date;
3. update `what_changed.md` with tag and release commit;
4. create the next Unreleased section;
5. record any store/distribution-specific follow-up separately from open-source source control.

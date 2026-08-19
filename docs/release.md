# Release Guide

QuizForge releases must be reproducible, tested, and based on a clean repository state.

## Release prerequisites

Before creating a release candidate:

- `main` is up to date and clean;
- the version in `pubspec.yaml` is intentional;
- the reviewed application `pubspec.lock` is tracked and matches `pubspec.yaml` after locked dependency resolution;
- `CHANGELOG.md`, `ROADMAP.md`, and `what_changed.md` are current;
- repository-local Markdown links pass `tool/check_markdown_links.py`;
- all required platform runner files can be generated from documented commands;
- no credentials, signing secrets, or private data are tracked;
- CI is green;
- dependency/security checks have been reviewed;
- applicable manual accessibility and real-screenshot checks in `docs/verification.md` are complete.

## Clean verification

From a fresh clone:

```bash
flutter create . --platforms=android,ios,web,windows,macos,linux
flutter pub get --enforce-lockfile
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
python3 tool/check_markdown_links.py
flutter analyze
flutter test --coverage
```

On Windows, use `python tool/check_markdown_links.py` when `python` is the configured launcher.

The release workflow intentionally fails when `pubspec.lock` is missing, empty, incompatible with `pubspec.yaml`, or rewritten by locked dependency resolution. A queued or pending remote check is not evidence of a passing release candidate.

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

Before publishing a web build, verify Drift's web runtime assets for the exact dependency/toolchain version and test database creation, refresh/reload, persistence, import/export, and browser storage behavior in the built artifact.

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

Flutter's build number follows the `+N` suffix in `pubspec.yaml` and should increase for store submissions as required by the target store.

## Tagging

Only tag after the release commit passes required checks:

```bash
git tag -s vX.Y.Z -m "QuizForge vX.Y.Z"
git push origin vX.Y.Z
```

If signed tags are not available in the execution environment, do not falsely claim a signed release.

The tag-triggered GitHub Actions release workflow independently verifies the tag/version relationship, requires the committed lockfile, resolves dependencies with `--enforce-lockfile`, verifies the lockfile was not rewritten, generates localizations, reruns formatting/documentation-link/analysis/test gates, builds Android/Web release artifacts, creates SHA-256 checksums, uploads workflow artifacts, and publishes the GitHub release.

## Release notes

Release notes should include:

- user-visible additions and changes;
- fixes;
- security/privacy changes;
- known limitations;
- migration or data-format notes;
- verified platforms and exact build scope.

Do not describe an unverified build as supported by that release merely because source code contains a target runner.

## Post-release

After publication:

1. verify downloadable artifacts/checksums where provided;
2. update `CHANGELOG.md` from Unreleased to the release version/date;
3. update `what_changed.md` with tag and release commit;
4. create the next Unreleased section;
5. record any store/distribution-specific follow-up separately from open-source source control.

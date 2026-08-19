# Setup

## Prerequisites

Install the Flutter stable channel and the platform tooling required for the targets you want to build. Run:

```bash
flutter doctor -v
```

Resolve errors for the target platform before treating a platform build failure as a QuizForge defect.

Typical platform requirements include:

- Android: Android Studio/SDK, a configured SDK toolchain, and an emulator or device.
- iOS/macOS: macOS with Xcode and CocoaPods where required by Flutter.
- Windows: Windows with the Visual Studio desktop C++ workload required by Flutter.
- Linux: a supported Linux desktop toolchain and Flutter's documented native dependencies.
- Web: a supported browser and Flutter web tooling.

Git is required for source checkout.

## Clone

```bash
git clone https://github.com/sanskarIN/quizforge.git
cd quizforge
```

If you are creating commits for the repository locally, configure your identity intentionally. The maintainer commit email requested for this project is:

```bash
git config user.email "sanskarin@outlook.in"
```

Set `user.name` to the identity you want Git to record.

## Materialize platform runners

The repository keeps platform shells reproducible. Generate the normal Flutter runner files from the package metadata:

```bash
flutter create . --platforms=android,ios,web,windows,macos,linux
```

Run the command from the repository root. Review generated diffs before committing platform files; generated local paths, signing material, and machine-specific configuration must remain untracked.

## Install packages and generate localizations

```bash
flutter pub get
flutter gen-l10n
```

`pubspec.yaml` keeps `intl: any` alongside the Flutter localization SDK so the installed Flutter stable SDK selects its compatible `intl` version. Do not replace that with an arbitrary manually pinned version unless the complete Flutter dependency graph has been verified.

Do not manually edit generated dependency caches. Commit the normal Flutter application lockfile when generated in a verified Flutter environment so CI and release builds can resolve the reviewed dependency graph reproducibly.

## Verify the checkout

```bash
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

The `tool/` directory is part of the formatting gate because it contains the deterministic benchmark utility.

If the platform runners are present, also verify the primary build appropriate to your host, for example:

```bash
flutter build apk --debug
flutter build web --release
```

Desktop and Apple-platform release builds require their corresponding supported host environments. The pull-request platform-build workflow provides additional cross-platform evidence on GitHub-hosted runners.

## Run the app

List devices:

```bash
flutter devices
```

Then run on a selected device:

```bash
flutter run -d <device-id>
```

Without `-d`, Flutter can prompt for a target when multiple devices are available.

## Local data

QuizForge creates its SQLite database in application-managed storage. Do not rely on a database path being identical across platforms. Removing app data or uninstalling the app removes local QuizForge state unless it has been exported separately.

## Environment file

Core offline functionality currently requires no secret environment values. `.env.example` documents reserved non-secret configuration names. Never commit a real `.env`, API key, signing secret, private endpoint credential, or production token.

## Common first-run behavior

On the first successful startup QuizForge:

1. loads settings;
2. opens/creates the local database;
3. seeds a fictional starter question bank if the bank is empty;
4. creates a default `Local Player` profile if no profile exists;
5. restores the last active local profile when possible.

For errors, continue with `docs/troubleshooting.md`.

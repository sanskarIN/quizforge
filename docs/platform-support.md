# Cross-Platform Support

QuizForge 2.7.4 targets one Flutter/Dart codebase across **Android, iOS, Web, Windows, macOS, and Linux**.

This document distinguishes product support from release verification. A target can be intentionally supported by the source architecture while still requiring a successful build/smoke test on the exact release-candidate head before that particular release is called verified.

## Supported targets

| Target | UI/application | Local settings | Quiz database | Import/export | CI build path |
| --- | --- | --- | --- | --- | --- |
| Android | Flutter Material UI | local preferences | native Drift/SQLite | clipboard JSON/CSV + local backup | Android release APK |
| iOS | Flutter Material UI | local preferences | native Drift/SQLite | clipboard JSON/CSV + local backup | no-codesign release compile |
| Web | Flutter Web | browser-local preferences | Drift Web + SQLite WASM/worker | browser clipboard JSON/CSV + local backup | Web release bundle |
| Windows | Flutter desktop | local preferences | native Drift/SQLite | desktop clipboard JSON/CSV + local backup | Windows release build |
| macOS | Flutter desktop | local preferences | native Drift/SQLite | desktop clipboard JSON/CSV + local backup | macOS release build |
| Linux | Flutter desktop | local preferences | native Drift/SQLite | desktop clipboard JSON/CSV + local backup | Linux release build |

The application does not require an account or a network service for core quiz, profile, progress, question-bank, or local-backup workflows.

## Platform-independent application boundary

Core quiz rules, scoring, validation, selection, codecs, backup validation, and controller behavior are shared Dart code. The maintained application code does not use `dart:io` or `Platform.*` to fork core behavior by operating system.

Platform integration is kept behind Flutter-compatible packages and framework APIs:

- Drift/SQLite for persisted questions, profiles, attempts, and bookmarks;
- `shared_preferences` for small application preferences;
- Flutter clipboard services for the current portable-data UI;
- `url_launcher` for external project/support links.

## Database behavior

`AppDatabase.defaults()` uses `driftDatabase(...)` from `drift_flutter`.

On Android, iOS, Windows, macOS, and Linux, Drift uses its native Flutter database path.

On Web, QuizForge explicitly supplies:

- `sqlite3.wasm`;
- `drift_worker.js`.

These assets are required for persistent Drift Web database startup. `tool/prepare_web_assets.py` obtains the pinned Drift 2.34.3 release assets and validates the WASM magic header, worker encoding/identity, and bounded file sizes before accepting them.

The Android/Web build gate and tagged release workflow verify that the Web assets are present in the final `build/web` output, preventing a Web build from passing merely because Dart compilation succeeded while runtime database assets were absent.

## Materialize all Flutter runners

QuizForge keeps standard platform runners reproducible instead of hand-editing generated shells. From the repository root:

```bash
flutter create . --platforms=android,ios,web,windows,macos,linux
```

For Web, then prepare the database runtime assets:

```bash
python3 tool/prepare_web_assets.py --destination web
```

On Windows, use `python` if that is the configured Python launcher.

The preparation command is idempotent for already-valid files. To verify without downloading:

```bash
python3 tool/prepare_web_assets.py --destination web --check
```

## Platform build commands

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

Store distribution signing remains separate from the public repository. Do not commit keystores, passwords, service-account credentials, or signing configuration containing secrets.

### iOS

Requires macOS/Xcode:

```bash
flutter build ios --release --no-codesign
```

Distribution builds require the maintainer's own signing/provisioning configuration outside source control.

### Web

```bash
python3 tool/prepare_web_assets.py --destination web
flutter build web --release
python3 tool/prepare_web_assets.py --destination build/web --check
```

A deployed server must serve the generated WebAssembly asset with the correct WebAssembly MIME type. Release verification must also exercise database creation, write/read persistence, refresh/reload behavior, and local backup restore in a real browser build.

### Windows

Requires a Windows Flutter desktop toolchain:

```powershell
flutter config --enable-windows-desktop
flutter build windows --release
```

### macOS

Requires macOS/Xcode:

```bash
flutter config --enable-macos-desktop
flutter build macos --release
```

### Linux

Requires the normal Flutter Linux desktop build dependencies:

```bash
flutter config --enable-linux-desktop
flutter build linux --release
```

## Automated build coverage

The maintained GitHub Actions paths are intentionally split:

- `.github/workflows/build.yml` — Android release + Web release, including Web database runtime assets;
- `.github/workflows/platform-builds.yml` — Linux, Windows, macOS, and iOS no-codesign release builds;
- `.github/workflows/ci.yml` — repository validators, Flutter dependency/localization/format/analyzer/tests;
- dependency review, OSV, and secret scanning remain separate focused gates.

An earlier 2.7.4 candidate head successfully completed the Android/Web build gate and Linux/Windows/macOS/iOS build matrix. Because the cross-platform hardening changes create a newer head, those older green runs are historical evidence only; the newer head must pass again before release verification is updated.

## Manual cross-platform release checks

Compilation is necessary but not sufficient. Before describing a 2.7.4 target as release-verified, exercise the applicable target with fictional data and verify:

- app startup and local database creation;
- starter questions and profile creation;
- quiz play, scoring, completion, review, and recent history;
- settings persistence across restart/reload;
- question-bank clipboard import/export;
- complete local backup export, mutation/reset, and restore;
- bookmark/profile isolation and progress persistence;
- external project/support links;
- keyboard/focus behavior on desktop/Web;
- large text, reduced motion, semantics, and contrast;
- Web refresh/reload persistence where applicable.

See `docs/verification.md`, `docs/release.md`, and `docs/local-backup.md` for the release evidence rules.

## Support policy

A platform remains in the supported set only while its maintained Flutter runner can be generated from the documented command and its applicable CI build path remains part of the release-candidate gate. Removing a target is therefore a documented compatibility decision, not an incidental build-script edit.

**Made by the Sanskar**

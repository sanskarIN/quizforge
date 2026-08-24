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

## Deterministic platform branding

`assets/branding/quizforge_logo.svg` and `assets/branding/quizforge_splash.svg` remain the editable brand references. Generated Flutter runner shells must not ship the default Flutter launcher artwork.

`tool/generate_platform_branding.py` uses only the Python standard library to render deterministic QuizForge raster artwork and place it into the generated runner layout. It currently covers:

- Android launcher density assets plus branded launch-background artwork;
- iOS AppIcon sizes plus launch-image assets;
- Web favicon, 192/512 icons, and maskable icons;
- Windows `.ico` application icon;
- macOS AppIcon sizes;
- a Linux 256px packaging/icon resource.

Opaque icon PNGs are encoded as RGB, including the iOS 1024px App Store icon, while splash artwork uses RGBA transparency. The generator also supports a non-mutating `--check` mode that validates expected file presence, PNG dimensions, Android splash references, and Windows ICO structure.

After materializing runners, generate branding for all targets:

```bash
python3 tool/generate_platform_branding.py --platforms=android,ios,web,windows,macos,linux
python3 tool/generate_platform_branding.py --platforms=android,ios,web,windows,macos,linux --check
```

On Windows, use `python` if that is the configured launcher.

The Android/Web build gate, desktop/iOS build matrix, local validation scripts, and tagged release workflow test or apply this branding tooling as appropriate. Platform-specific visual inspection is still required before release sign-off; deterministic generation is not a substitute for checking launcher masks, splash scaling, store presentation, or OS-specific appearance on representative devices.

## Materialize all Flutter runners

QuizForge keeps standard platform runners reproducible instead of hand-editing generated shells. From the repository root, generate runner files without invoking an implicit package-resolution pass:

```bash
flutter create . --platforms=android,ios,web,windows,macos,linux --no-pub
```

Then apply QuizForge branding:

```bash
python3 tool/generate_platform_branding.py --platforms=android,ios,web,windows,macos,linux
python3 tool/generate_platform_branding.py --platforms=android,ios,web,windows,macos,linux --check
```

Resolve the reviewed application dependency graph explicitly after runner materialization:

```bash
flutter pub get --enforce-lockfile
git diff --exit-code -- pubspec.lock analysis_options.yaml
```

The `--no-pub` step is intentional. Runner generation is scaffolding; it must not silently replace the reviewed application lockfile before the explicit locked-resolution gate runs.

For Web, also prepare the database runtime assets:

```bash
python3 tool/prepare_web_assets.py --destination web
```

The Web preparation command is idempotent for already-valid files. To verify without downloading:

```bash
python3 tool/prepare_web_assets.py --destination web --check
```

## Platform build commands

### Android

```bash
python3 tool/generate_platform_branding.py --platforms=android
flutter build apk --release
flutter build appbundle --release
```

Store distribution signing remains separate from the public repository. Do not commit keystores, passwords, service-account credentials, or signing configuration containing secrets.

### iOS

Requires macOS/Xcode:

```bash
python3 tool/generate_platform_branding.py --platforms=ios
flutter build ios --release --no-codesign
```

Distribution builds require the maintainer's own signing/provisioning configuration outside source control.

### Web

```bash
python3 tool/generate_platform_branding.py --platforms=web
python3 tool/prepare_web_assets.py --destination web
flutter build web --release
python3 tool/prepare_web_assets.py --destination build/web --check
```

A deployed server must serve the generated WebAssembly asset with the correct WebAssembly MIME type. Release verification must also exercise database creation, write/read persistence, refresh/reload behavior, and local backup restore in a real browser build.

### Windows

Requires a Windows Flutter desktop toolchain:

```powershell
flutter config --enable-windows-desktop
python tool/generate_platform_branding.py --platforms=windows
flutter build windows --release
```

### macOS

Requires macOS/Xcode:

```bash
flutter config --enable-macos-desktop
python3 tool/generate_platform_branding.py --platforms=macos
flutter build macos --release
```

### Linux

Requires the normal Flutter Linux desktop build dependencies:

```bash
flutter config --enable-linux-desktop
python3 tool/generate_platform_branding.py --platforms=linux
flutter build linux --release
```

Linux desktop environments generally consume application icons through packaging metadata rather than a Flutter runner resource alone. The generated `linux/runner/resources/quizforge.png` is therefore a deterministic packaging source; final `.desktop`/distribution-package integration depends on the chosen Linux distribution format.

## Automated build coverage

The maintained GitHub Actions paths are intentionally split:

- `.github/workflows/build.yml` — Android release + Web release, including lockfile-safe runner materialization, generated QuizForge branding, and Web database runtime assets;
- `.github/workflows/platform-builds.yml` — branded Linux, Windows, macOS, and iOS no-codesign release builds with lockfile-safe runner materialization and enforced lockfile resolution;
- `.github/workflows/ci.yml` — repository validators, branding-tool regression tests, Flutter dependency/localization/format/analyzer/tests;
- dependency review, OSV, and secret scanning remain separate focused gates.

The tagged release workflow uses the same `--no-pub` runner strategy, applies the branding generator to every platform runner, and performs explicit locked resolution before packaging.

An earlier 2.7.4 candidate head successfully completed the Android/Web build gate and Linux/Windows/macOS/iOS build matrix. Because later cross-platform, test, branding, and runner-generation changes create a newer head, those older green runs are historical evidence only; the newer head must pass again before release verification is updated.

## Manual cross-platform release checks

Compilation is necessary but not sufficient. Before describing a 2.7.4 target as release-verified, exercise the applicable target with fictional data and verify:

- branded launcher/app icon uses the expected mask/crop and remains recognizable;
- splash/launch artwork is centered and scales without clipping;
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
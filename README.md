# QuizForge

> A polished, offline-first, cross-platform quiz game and quiz-authoring toolkit built with Flutter and Dart.

<p align="center">
  <img src="assets/branding/quizforge_logo.svg" alt="QuizForge logo" width="180" />
</p>

<p align="center">
  <img alt="Version 2.7.4" src="https://img.shields.io/badge/version-2.7.4-blue" />
  <a href="https://buymeacoffee.com/sanskarIN"><img alt="Buy Me a Coffee" src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-sanskarIN-FFDD00?logo=buy-me-a-coffee&logoColor=000000" /></a>
  <a href="LICENSE"><img alt="MIT License" src="https://img.shields.io/badge/license-MIT-blue.svg" /></a>
</p>

QuizForge is a production-minded **Simple Quiz Game** that supports multiple-choice, true/false, multi-select, and short-answer questions; categories, tags and difficulty; timed and untimed play; local profiles; statistics; bookmarks; review mode; daily quizzes; randomized practice; JSON/CSV question-bank exchange; complete local backup/restore; and accessibility-oriented settings.

The maintained release-candidate line is **2.7.4+1**. Tag `v2.7.4` is reserved for the exact verified release head; a version declaration is not itself a claim that platform/build/manual verification has completed.

## Highlights

- One Flutter/Dart application codebase targeting Android, iOS, Web, Windows, macOS, and Linux.
- Four question types with explanations and deterministic scoring.
- Quiz creator with validation, preview-ready domain models, duplicate detection, and import/export codecs.
- Offline-first local persistence architecture using SQLite through Drift.
- Native Drift/SQLite persistence on Android, iOS, Windows, macOS, and Linux plus explicit Drift Web WASM/worker runtime support.
- Daily quiz and seeded random practice sets.
- Streaks, bookmarks, recent attempt history, progress summaries, and a local leaderboard.
- Versioned full local backup/restore with pre-restore validation, confirmation, and cross-store rollback handling.
- Light, dark, and system themes plus large-text and reduced-motion preferences.
- Keyboard-friendly responsive UI foundations for mobile, desktop, and Web.
- Persistence-ordering safeguards for settings and local-profile changes, with rollback regression coverage.
- Repository-local Markdown-link, ARB-localization, release-metadata, and Web-runtime tooling tests before Flutter CI work begins.
- Host-specific release build gates for all six targets.
- No sign-in requirement and no donation gating.
- Private-room multiplayer is represented by a clean local protocol/architecture boundary so a transport can be added without coupling it to quiz logic.

## Screenshots

Real screenshots are intentionally not fabricated. The release-candidate capture checklist and README gallery placeholders are maintained in [`docs/screenshots/README.md`](docs/screenshots/README.md). Verified captures will be added only from an actually built release candidate and will use fictional/demo quiz data.

Planned gallery slots:

- Home dashboard — compact/mobile, light theme.
- Quiz play and answer review.
- Question bank search/filter and creator preview.
- Progress/local leaderboard.
- Settings/About — dark theme with accessibility controls.

## Supported targets

QuizForge 2.7.4 targets:

- **Android**
- **iOS**
- **Web**
- **Windows**
- **macOS**
- **Linux**

Standard Flutter runner shells are regenerated from the repository metadata rather than maintained as hand-edited platform forks. The Web target additionally requires compatible Drift `sqlite3.wasm` and worker assets, which the repository prepares and validates automatically in its Web build/release workflows.

See [`docs/platform-support.md`](docs/platform-support.md) for the complete runtime, build, packaging, and verification contract for every target.

## Tech stack

- Flutter + Dart
- Drift + SQLite / Drift Web WASM persistence
- Flutter SDK state primitives (`ChangeNotifier` / `ListenableBuilder`)
- Deterministic pure-Dart quiz engine and codecs
- Python-stdlib repository documentation/localization/release/Web-runtime tooling
- GitHub Actions for formatting, analysis, tests, six-platform builds, documentation integrity, localization integrity, release metadata, dependency/security checks, and cross-platform release packaging

## Quick start

```bash
git clone https://github.com/sanskarIN/quizforge.git
cd quizforge
flutter create . --platforms=android,ios,web,windows,macos,linux
python3 tool/prepare_web_assets.py --destination web
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

On Windows, use `python` instead of `python3` if that is the configured launcher. The Web asset preparation command is harmless for developers targeting another platform and ensures the generated Web runner is ready when Web is selected.

The `flutter create .` step is idempotent for standard runner scaffolding and is documented because generated platform shells are intentionally kept reproducible rather than hand-edited.

## Development setup

1. Install the current Flutter stable channel and ensure `flutter doctor` is healthy for the platform you plan to build.
2. Clone the repository.
3. Run `flutter create . --platforms=android,ios,web,windows,macos,linux` to materialize platform runners.
4. Run `python3 tool/prepare_web_assets.py --destination web` when preparing the Web target.
5. Run the repository/tool regression tests: `python3 tool/test_check_markdown_links.py`, `python3 tool/test_check_arb_catalogs.py`, `python3 tool/test_check_release_metadata.py`, and `python3 tool/test_prepare_web_assets.py`.
6. Run `python3 tool/check_markdown_links.py`, `python3 tool/check_arb_catalogs.py`, and `python3 tool/check_release_metadata.py`.
7. Run `flutter pub get` and `flutter gen-l10n`.
8. Run `dart format --output=none --set-exit-if-changed lib test tool`.
9. Run `flutter analyze` and `flutter test`.

Or use `tool/check.sh` / `tool/check.ps1` to run the supported local source-quality sequence.

See [`docs/setup.md`](docs/setup.md), [`docs/development.md`](docs/development.md), and [`docs/platform-support.md`](docs/platform-support.md) for details.

## Testing

```bash
python3 tool/test_check_markdown_links.py
python3 tool/test_check_arb_catalogs.py
python3 tool/test_check_release_metadata.py
python3 tool/test_prepare_web_assets.py
python3 tool/check_markdown_links.py
python3 tool/check_arb_catalogs.py
python3 tool/check_release_metadata.py
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

The test suite covers scoring, answer normalization, duplicate detection, deterministic selection, JSON/CSV codecs and fuzz cases, local persistence, local backup validation/round trips/restoration, recent-attempt ordering/rendering, controller persistence/rollback ordering, validation, accessibility semantics, settings, and the primary quiz-completion journey. Repository tooling tests cover Markdown, ARB catalogs, release metadata, and Web database runtime asset validation. See [`docs/testing.md`](docs/testing.md).

Recent-attempt storage, refresh behavior, deletion semantics, and privacy boundaries are documented in [`docs/progress-history.md`](docs/progress-history.md). Whole-app local backup semantics are documented in [`docs/local-backup.md`](docs/local-backup.md).

## Local backup versus question-bank export

JSON/CSV question-bank export is for moving or sharing quiz content. **Local backup** is for preserving the complete offline state and can contain profile names, bookmarks, quiz history, submitted answers, settings, and the active profile in addition to questions.

Treat local backup archives as private user data. Restore validates the archive and requires destructive-replacement confirmation. See [`docs/local-backup.md`](docs/local-backup.md) and [`PRIVACY.md`](PRIVACY.md).

## Build and release

Android/Web on a compatible host:

```bash
flutter build apk --release
flutter build appbundle --release
python3 tool/prepare_web_assets.py --destination web
flutter build web --release
python3 tool/prepare_web_assets.py --destination build/web --check
```

Desktop and Apple targets use their required host operating systems:

```text
Windows: flutter build windows --release
Linux:   flutter build linux --release
macOS:   flutter build macos --release
iOS:     flutter build ios --release --no-codesign   # CI compile evidence only
```

The tagged release pipeline is gated across all six targets and publishes Android APK/AAB, Web, Linux, Windows, macOS, and an explicitly unsigned iOS compile artifact only after its shared source-quality gate and all platform jobs succeed. Mobile/desktop distribution signing or notarization remains separate from public source control.

Release, signing, platform runner generation, locked dependency resolution, version 2.7.4 metadata, and verification are documented in [`docs/release.md`](docs/release.md), [`docs/versioning.md`](docs/versioning.md), [`docs/platform-support.md`](docs/platform-support.md), and [`docs/verification.md`](docs/verification.md).

## Architecture

QuizForge is organized as a modular monolith:

- `lib/src/domain/` — immutable models, validation, scoring, selection, duplicate rules.
- `lib/src/data/` — Drift-backed persistence, deterministic demo data, question-bank/local-backup codecs.
- `lib/src/application/` — use-case orchestration and app state.
- `lib/src/presentation/` — adaptive Flutter UI.
- `lib/src/core/` — design tokens, theme, constants, logging helpers, shared utilities.

Read [`docs/architecture.md`](docs/architecture.md) and the ADRs in [`docs/adr/`](docs/adr/).

## Security and privacy

QuizForge is offline-first. It does not require an account, does not embed production credentials, and is designed to keep quiz/profile data on the user's device unless the user explicitly exports or copies it. Imported question banks and restored local-backup archives are treated as untrusted input and validated before persistence. Read [`SECURITY.md`](SECURITY.md) and [`PRIVACY.md`](PRIVACY.md).

## Contributing

Contributions are welcome. Please read [`CONTRIBUTING.md`](CONTRIBUTING.md), follow the code of conduct, and include tests for behavioral changes.

## License

MIT — see [`LICENSE`](LICENSE).

## Contact and support

- Business: `sanskarin@outlook.in`
- Business: `sanskarin.business@gmail.com`
- Support: `supportramsandesh@gmail.com`
- GitHub: https://github.com/sanskarIN
- Buy Me a Coffee: https://buymeacoffee.com/sanskarIN

## Funding

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-sanskarIN-FFDD00?logo=buy-me-a-coffee&logoColor=000000)](https://buymeacoffee.com/sanskarIN)

Funding is optional and never changes product functionality.

---

**Made by the Sanskar**

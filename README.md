# QuizForge

> A polished, offline-first quiz game and quiz-authoring toolkit built with Flutter and Dart.

<p align="center">
  <img src="assets/branding/quizforge_logo.svg" alt="QuizForge logo" width="180" />
</p>

<p align="center">
  <a href="https://buymeacoffee.com/sanskarIN"><img alt="Buy Me a Coffee" src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-sanskarIN-FFDD00?logo=buy-me-a-coffee&logoColor=000000" /></a>
  <a href="LICENSE"><img alt="MIT License" src="https://img.shields.io/badge/license-MIT-blue.svg" /></a>
</p>

QuizForge is a production-minded **Simple Quiz Game** that supports multiple-choice, true/false, multi-select, and short-answer questions; categories, tags and difficulty; timed and untimed play; local profiles; statistics; bookmarks; review mode; daily quizzes; randomized practice; JSON/CSV question-bank exchange; and accessibility-oriented settings.

## Highlights

- Four question types with explanations and deterministic scoring.
- Quiz creator with validation, preview-ready domain models, duplicate detection, and import/export codecs.
- Offline-first local persistence architecture using SQLite through Drift.
- Daily quiz and seeded random practice sets.
- Streaks, bookmarks, recent attempt history, progress summaries, and a local leaderboard.
- Light, dark, and system themes plus large-text and reduced-motion preferences.
- Keyboard-friendly responsive UI foundations for mobile, desktop, and web.
- Persistence-ordering safeguards for settings and local-profile changes, with rollback regression coverage.
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

The codebase is designed for Android, iOS, Windows, macOS, Linux, and Web. Flutter platform runner files can be regenerated safely with the documented setup command when needed.

## Tech stack

- Flutter + Dart
- Drift + SQLite
- Flutter SDK state primitives (`ChangeNotifier` / `ListenableBuilder`)
- Deterministic pure-Dart quiz engine and codecs
- GitHub Actions for formatting, analysis, tests, builds, documentation integrity, and security checks

## Quick start

```bash
git clone https://github.com/sanskarIN/quizforge.git
cd quizforge
flutter create . --platforms=android,ios,web,windows,macos,linux
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

The `flutter create .` step is idempotent for standard runner scaffolding and is documented because generated platform shells are intentionally kept reproducible rather than hand-edited.

## Development setup

1. Install the current Flutter stable channel and ensure `flutter doctor` is healthy for the platform you plan to build.
2. Clone the repository.
3. Run `flutter create . --platforms=android,ios,web,windows,macos,linux` to materialize platform runners.
4. Run `flutter pub get` and `flutter gen-l10n`.
5. Run `dart format --output=none --set-exit-if-changed lib test tool`.
6. Run `python3 tool/check_markdown_links.py` (`python` may be the Windows launcher).
7. Run `flutter analyze` and `flutter test`.

See [`docs/setup.md`](docs/setup.md) and [`docs/development.md`](docs/development.md) for details.

## Testing

```bash
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
python3 tool/check_markdown_links.py
flutter analyze
flutter test --coverage
```

The test suite covers scoring, answer normalization, duplicate detection, deterministic selection, JSON/CSV codecs and fuzz cases, local persistence, recent-attempt ordering/rendering, controller persistence/rollback ordering, validation, accessibility semantics, settings, and the primary quiz-completion journey. See [`docs/testing.md`](docs/testing.md).

Recent-attempt storage, refresh behavior, deletion semantics, and privacy boundaries are documented in [`docs/progress-history.md`](docs/progress-history.md).

## Build and release

```bash
flutter build apk --release
flutter build appbundle --release
flutter build web --release
# Desktop builds require the corresponding host OS.
```

Release, signing, platform runner generation, locked dependency resolution, and verification are documented in [`docs/release.md`](docs/release.md).

## Architecture

QuizForge is organized as a modular monolith:

- `lib/src/domain/` — immutable models, validation, scoring, selection, duplicate rules.
- `lib/src/data/` — Drift-backed persistence, deterministic demo data, import/export codecs.
- `lib/src/application/` — use-case orchestration and app state.
- `lib/src/presentation/` — adaptive Flutter UI.
- `lib/src/core/` — design tokens, theme, constants, logging helpers, shared utilities.

Read [`docs/architecture.md`](docs/architecture.md) and the ADRs in [`docs/adr/`](docs/adr/).

## Security and privacy

QuizForge is offline-first. It does not require an account, does not embed production credentials, and is designed to keep quiz/profile data on the user's device unless the user explicitly exports it. Imported content is validated before persistence. Read [`SECURITY.md`](SECURITY.md) and [`PRIVACY.md`](PRIVACY.md).

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

# Changelog

All notable changes to QuizForge are documented in this file.

The project follows Semantic Versioning where practical.

## [Unreleased]

### Added

- Flutter/Dart application foundation and adaptive Material 3 navigation.
- Offline-first SQLite persistence through Drift.
- Multiple-choice, true/false, multi-select, and short-answer question models.
- Deterministic quiz selection, daily quizzes, random practice, and timed sprints.
- Exact-set scoring, normalized short-answer scoring, streak calculations, explanations, and review mode.
- Local profiles, bookmarks, progress statistics, and device-local leaderboard.
- Search by prompt/category/tag plus category, difficulty, and bookmark filters.
- Question creator with validation and live preview.
- JSON and CSV question-bank import/export with duplicate protection.
- Light/dark/system themes plus large-text, reduced-motion, and screen-reader-oriented settings.
- Disabled-by-default private-room multiplayer architecture boundary.
- Editable QuizForge SVG logo source.
- Domain, codec, database integration, and widget tests.
- GitHub Actions quality workflow.
- Repository documentation, community policies, support, privacy, and security foundations.

### Security

- Imported question-bank data is validated before persistence.
- Database foreign keys are enabled at open time.
- Core application requires no production credentials or remote account.
- Secret and local signing files are excluded from version control.

## [0.1.0] - 2026-08-19

Initial development milestone. This version is a development baseline rather than a production-store release. Release-candidate status requires clean CI/build verification and completion of the remaining release audit documented in `what_changed.md`.

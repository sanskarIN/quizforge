# Changelog

All notable changes to QuizForge are documented in this file.

The project follows Semantic Versioning where practical.

## [Unreleased]

### Added

- Flutter/Dart application foundation and adaptive Material 3 navigation.
- Offline-first SQLite persistence through Drift.
- Multiple-choice, true/false, multi-select, and short-answer question models.
- Deterministic quiz selection, daily quizzes, random practice, timed sprints, and configurable custom quiz sets.
- Exact-set scoring, normalized short-answer scoring, streak calculations, explanations, and review mode.
- Local profiles, profile rename/delete, bookmarks, progress statistics, activity reset, and device-local leaderboard.
- Search by prompt/category/tag plus category, difficulty, and bookmark filters.
- Question creator with validation and live preview.
- JSON and CSV question-bank import/export with duplicate protection and bounded import resources.
- Light/dark/system themes plus large-text, reduced-motion, and screen-reader-oriented settings.
- English localization resources for primary navigation, quiz, creator, question-bank, import/export, statistics, settings, and accessibility workflows.
- Disabled-by-default private-room multiplayer architecture boundary.
- Editable QuizForge SVG logo source.
- Structured application logging with event validation and sensitive-field/content redaction.
- Domain, codec, deterministic fuzz-style, database integration, application/controller, widget, accessibility, private-room, starter-bank, app-shell, restart-boundary, and primary quiz-journey tests.
- Deterministic quiz-selection and codec benchmark harness.
- Deterministic repository-local Markdown link validation integrated into CI and local quality scripts.
- CI artifact capture for the Flutter-resolved `pubspec.lock` so lockfile review can use generated evidence instead of hand-authored dependency state.
- GitHub Actions quality, Android/Web build, platform build-matrix, dependency-review, OSV vulnerability, secret-scan, and tag-release workflows.
- Repository documentation, ADRs, community policies, support, privacy, security, CI, accessibility, performance, screenshot-capture, and release foundations.
- Phase 6 verification evidence ledger and release-candidate audit branch.

### Changed

- Local quality scripts now resolve dependencies, generate localizations, check formatting across `lib`, `test`, and `tool`, validate repository-local documentation links, analyze, and run tests with coverage.
- Tagged releases require a committed application lockfile, use enforced locked dependency resolution, verify the lockfile is not rewritten, validate documentation links, and rerun formatting/analysis/tests before Android/Web artifacts and checksums are published.
- Platform build workflows cancel superseded runs to avoid wasting runner capacity.
- Settings are applied to in-memory state only after persistence succeeds.
- Local-profile selection loads target profile state and persists the selected profile id before mutating visible controller state.
- Profile creation/deletion use rollback-aware ordering around database and active-profile preference persistence.
- Cross-store local-data reset attempts all managed stores, clears stale memory, reloads durable state, and only then reports the first reset failure.
- Successful primary persistence operations are no longer reported as failed solely because a later progress/leaderboard refresh fails.
- Noncritical settings/profile preference and derived-statistics startup failures fall back safely while core database initialization remains a startup blocker.
- CSV parsing now enforces quoted-field structure instead of silently accepting quote characters in invalid positions.
- Accepted-answer parsing rejects normalized duplicates before JSON/CSV arrays are converted to sets.
- Quiz shuffle uses an explicit Park-Miller deterministic generator so the same seed/input ordering is stable across Dart VM and Dart-compiled Web rather than depending on SDK `Random` implementation details.
- Large-text mode clamps the existing system `TextScaler` to a minimum factor instead of replacing nonlinear system scaling with a fixed linear scaler.
- Review UI listens for controller changes so bookmark state refreshes after toggles.
- Onboarding persistence is abstracted behind an injectable store so root application routing can be tested without platform preference channels.
- Question-creator validation updates with draft edits, preserves raw duplicate accepted-answer detection, and rejects nonnumeric optional time limits instead of silently treating them as absent.
- User-facing startup, import, creator, settings, statistics, and quiz messages were moved toward externalized localization resources.
- Flutter localization dependency handling now lets the Flutter SDK select its compatible `intl` version.
- Setup, architecture, data-lifecycle, accessibility, development, testing, CI, release, question-bank-format, repository-settings, roadmap, and screenshot documentation were synchronized with current repository behavior.

### Fixed

- Replaced localization message identifiers that conflicted with Dart language keywords.
- Corrected widget tests to use localization delegates and explicitly enabled semantics for accessibility assertions.
- Updated settings widget coverage to remain stable across viewport heights.
- Added canonical true/false scoring coverage.
- Hardened user-visible persistence failures so raw exception/user content is not shown or logged.
- Prevented inconsistent settings state when local preference persistence fails.
- Prevented failed active-profile preference writes from partially switching the in-memory profile.
- Added rollback behavior when new-profile activation fails after its database insert.
- Prevented active-profile deletion from removing the database profile before replacement-profile preference persistence succeeds.
- Preserved original stack traces when rollback-aware profile operations rethrow persistence failures.
- Recovered controller state after partial reset failure rather than leaving stale pre-reset data visible.
- Handled clipboard read/write failures in question-bank exchange without logging clipboard contents.
- Prevented onboarding preference-load failures from trapping startup.
- Rejected normalized duplicate accepted answers during JSON and CSV parsing before set conversion could hide them.
- Rejected unexpected quotes in unquoted CSV fields and trailing characters after a closing quoted field.
- Preserved stronger/nonlinear operating-system text scaling when QuizForge large text is enabled.

### Security

- Imported question-bank data is validated before persistence.
- JSON/CSV imports reject payloads larger than the documented in-process limit and reject excessive question counts.
- CSV imports reject malformed quote structure rather than attempting ambiguous reinterpretation.
- Question validation bounds ids, prompts, categories, choices, accepted answers, tags, explanations, and time limits.
- Accepted answers and tags reject blank or normalized-duplicate entries; true/false questions reject custom choice lists.
- Database foreign keys are enabled at open time and multi-step persistence uses transactions where required.
- Integration tests verify question-batch and attempt rollback when later writes fail.
- Core application requires no production credentials or remote account.
- Secret and local signing files are excluded from version control.
- Structured logs redact secret/authentication fields and user-authored sensitive content.
- Clipboard failures are logged by error type only, never by clipboard payload.
- Obsolete self-mutating bootstrap workflows with broad write permissions were removed from the maintained audit branch.
- Recurring pull-request workflows use focused permissions and hardened checkouts; full-history secret scanning remains isolated to its dedicated job.

### Verification status

- Phase 6 release-candidate verification remains open until final-head GitHub Actions checks, clean build evidence, the reviewed application lockfile, platform/database checks, manual accessibility review, and real screenshots are complete.
- Repository-local Markdown link validation is now an automated gate, but it is not counted as passed until it completes on the final release-candidate head.
- CI-generated lockfile artifacts are evidence inputs only; the application lockfile still must be generated, reviewed, and committed before a release candidate can be tagged.
- A queued, cancelled because of a newer commit, or pending workflow is not treated as a successful verification result.

## [0.1.0] - 2026-08-19

Initial development milestone. This version is a development baseline rather than a production-store release. Release-candidate status requires clean CI/build verification and completion of the remaining release audit documented in `what_changed.md` and `docs/verification.md`.

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
- Local profiles, profile rename/delete, bookmarks, progress statistics, recent per-profile attempt history, activity reset, and device-local leaderboard.
- Bounded newest-first recent-attempt queries with persisted score, duration, streak, question count, and accuracy projection.
- Search by prompt/category/tag plus category, difficulty, and bookmark filters.
- Question creator with validation and live preview.
- JSON and CSV question-bank import/export with duplicate protection and bounded import resources.
- Versioned full local backup format covering questions, profiles, bookmarks, quiz attempts/submitted answers, settings, and active-profile selection.
- Transactional logical database backup restore plus controller-level cross-store rollback for database/settings/profile-preference failures.
- Local backup/restore UI with clipboard export, destructive-replacement confirmation, localized messaging, and privacy guidance.
- Light/dark/system themes plus large-text, reduced-motion, and screen-reader-oriented settings.
- English localization resources for primary navigation, quiz, creator, question-bank, import/export, local backup, statistics, settings, and accessibility workflows.
- Disabled-by-default private-room multiplayer architecture boundary.
- Editable QuizForge SVG logo source.
- Structured application logging with event validation and sensitive-field/content redaction.
- Domain, codec, deterministic fuzz-style, database integration, application/controller, widget, accessibility, private-room, recent-history, local-backup, and primary quiz-journey tests.
- Deterministic quiz-selection and codec benchmark harness.
- Deterministic repository-local Markdown link validation integrated into CI and local quality scripts.
- Deterministic ARB localization-catalog validation with regression tests, integrated before Flutter setup/localization generation.
- Regression tests for the repository-local Markdown validation tool itself.
- CI artifact capture for the Flutter-resolved `pubspec.lock` so lockfile review can use generated evidence instead of hand-authored dependency state.
- GitHub Actions quality, Android/Web build, platform build-matrix, dependency-review, OSV vulnerability, secret-scan, and tag-release workflows.
- Repository documentation, ADRs, community policies, support, privacy, security, CI, accessibility, performance, progress-history, local-backup, screenshot-capture, and release foundations.
- Phase 6 verification evidence ledger and consolidated final-audit branch.

### Changed

- Local quality scripts now test the repository validators, validate Markdown/ARB inputs, resolve dependencies, generate localizations, check formatting across `lib`, `test`, and `tool`, analyze, and run tests with coverage.
- CI now exercises stdlib-only repository validators before Flutter setup so malformed documentation/localization inputs fail early.
- Tagged releases now run Markdown/ARB validator regression tests and repository input validation before Flutter setup, then require a committed application lockfile, use enforced locked dependency resolution, verify the lockfile is not rewritten, and rerun formatting/analysis/tests before Android/Web artifacts and checksums are published.
- Platform build workflows cancel superseded runs to avoid wasting runner capacity.
- Settings are applied to in-memory state only after persistence succeeds.
- Local-profile selection loads target profile state and persists the selected profile id before mutating visible controller state.
- Profile creation/deletion use rollback-aware ordering around database and active-profile preference persistence.
- CSV parsing now enforces quoted-field structure instead of silently accepting quote characters in invalid positions.
- Large-text mode preserves a larger operating-system text scale instead of reducing it.
- Review UI listens for controller changes so bookmark state refreshes after toggles.
- Statistics now surfaces recent completed attempts without duplicating attempt storage or exposing submitted answer content.
- Local backup restore preserves the stored attempt-level streak summary while validating only order-independent streak bounds because schema version 1 does not persist original per-answer sequence.
- Local-backup version 1 now defines a minimum directly restorable initialized state: at least one question, at least one local profile, and a non-null active-profile reference.
- User-facing startup, import, creator, settings, statistics, backup, and quiz messages were moved toward externalized localization resources.
- Flutter localization dependency handling now lets the Flutter SDK select its compatible `intl` version.
- Setup, development, testing, CI, release, question-bank-format, roadmap, progress-history, backup, privacy, screenshot, and verification documentation were synchronized with the maintained repository behavior.

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
- Rejected unexpected quotes in unquoted CSV fields and trailing characters after a closing quoted field.
- Rejected local-backup snapshots with dangling references, invalid/non-finite aggregate values, impossible streak bounds, inconsistent answer/count totals, duplicate content, invalid active-profile references, missing questions, or missing profiles.
- Rejected version-1 local-backup archives with no active-profile selection instead of silently selecting a different profile during application reload.
- Prevented local backup export from intentionally emitting an archive larger than the same version's restore limit.
- Avoided incorrectly recomputing historical best streak from backup answer rows after database export reordered rows by question id; schema version 1 has no stored answer-position column.
- Added the previously missing Markdown-validator regression-test helper before wiring it into CI/local check scripts.
- Corrected privacy documentation that still described the already-implemented in-app reset flow as future work.

### Security

- Imported question-bank data is validated before persistence.
- JSON/CSV imports reject payloads larger than the documented in-process limit and reject excessive question counts.
- CSV imports reject malformed quote structure rather than attempting ambiguous reinterpretation.
- Local backup restore rejects archives above the supported size limit and validates format version, minimum restorable state, object references, domain records, aggregates, bookmarks, and active-profile selection before replacement.
- Local backup export enforces the supported restore-size boundary so an intentionally generated archive is not knowingly unusable by the same application version.
- Local backup restore snapshots current local state first and attempts rollback if a later cross-store restore/reload step fails.
- Backup archives are documented as private user data because they can contain profile names, authored questions, bookmarks, quiz history, and submitted answers.
- Question validation bounds ids, prompts, categories, choices, accepted answers, tags, explanations, and time limits.
- Accepted answers and tags reject blank or normalized-duplicate entries; true/false questions reject custom choice lists.
- Database foreign keys are enabled at open time and multi-step persistence uses transactions where required.
- Recent history reads only attempt summary metadata and does not expose submitted answer payloads.
- Core application requires no production credentials or remote account.
- Secret and local signing files are excluded from version control.
- Structured logs redact secret/authentication fields and user-authored sensitive content.
- Obsolete self-mutating bootstrap workflows with broad write permissions were removed from the maintained audit branch.
- Recurring pull-request workflows use focused permissions and hardened checkouts; full-history secret scanning remains isolated to its dedicated job.

### Verification status

- Phase 6/final release-candidate verification remains open until final-head GitHub Actions checks, clean build evidence, the reviewed application lockfile, platform/database/backup checks, manual accessibility review, and real screenshots are complete.
- Repository-local Markdown and ARB validation are automated gates, but neither is counted as passed until it completes on the final release-candidate head.
- Local backup has source-level regression coverage, but release-host clipboard/persistence restore smoke checks remain required before it is described as release-verified.
- A queued, cancelled because of a newer commit, or pending workflow is not treated as a successful verification result.

## [0.1.0] - 2026-08-19

Initial development milestone. This version is a development baseline rather than a production-store release. Release-candidate status requires clean CI/build verification and completion of the remaining release audit documented in `what_changed.md` and `docs/verification.md`.

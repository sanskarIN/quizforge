# QuizForge — What Changed / Continuation Ledger

Last updated: 2026-08-19 (Asia/Kolkata)

This is the primary handoff file for continuing QuizForge in another chat/session. It records what has actually been implemented, what has actually been verified, and what must happen next. Do not replace verified facts with assumptions.

## Current milestone

- Package version: `0.1.0+1`
- Repository: `https://github.com/sanskarIN/quizforge`
- Visibility/source model: public / open source
- License: MIT
- Primary stack: Flutter + Dart + Drift/SQLite
- Intended targets: Android, iOS-ready, Web, Windows, macOS, Linux
- Current development milestone: Phases 0–4 substantially implemented; Phase 5 release engineering/documentation substantially implemented; Phase 6 clean-build/release-candidate verification is still required before any production-ready claim.
- Required product credit: **Made by the Sanskar**

## Git author / commit-email note

The requested maintainer commit email is `sanskarin@outlook.in`.

The GitHub connector used in this session exposes repository content/commit mutation operations but does **not** expose a commit-author/commit-email argument for `create_file` / `update_file`. Therefore the connector-created GitHub commits cannot be forced to use a supplied author email from this interface. This limitation is documented rather than hidden.

For normal local Git commits, the setup documentation instructs the maintainer to configure:

```bash
git config user.email "sanskarin@outlook.in"
```

## Completed product work

### Application foundation

- Created Flutter/Dart application package metadata.
- Added strict analyzer/lint configuration.
- Added reusable Material 3 design tokens for spacing, breakpoints, theme, and adaptive layouts.
- Added light, dark, and system theme support.
- Added adaptive phone/tablet/desktop navigation using `NavigationBar` and `NavigationRail`.
- Added persistent first-run onboarding.
- Added reduced-motion integration through theme/media-query animation settings.
- Added large-text setting while preserving system text scaling behavior.
- Added generated Flutter localization architecture and an externalized English ARB catalog.

### Question model and quiz engine

Implemented:

- multiple-choice questions;
- true/false questions;
- multi-select questions;
- short-answer questions;
- categories;
- difficulty levels;
- tags;
- optional per-question time limits;
- timed and untimed quiz configurations;
- deterministic seeded selection;
- deterministic daily quiz seed derived from the local date;
- normalized answer matching;
- exact-set multi-select scoring;
- quiz score and percentage calculation;
- streak/best-streak calculation;
- quiz duration tracking;
- validation rules for authored/imported questions.

### Question-bank duplicate protection

Implemented duplicate partitioning by:

1. stable question id; and
2. normalized content fingerprint derived from question category/type/prompt.

Whitespace/casing-only prompt/category changes therefore do not silently create duplicate accepted questions.

### Quiz play and review

Implemented:

- daily quiz;
- random practice;
- five-question timed sprint;
- custom quiz builder;
- category/difficulty/tag filters;
- configurable question count;
- configurable default timer duration;
- question progress indicator;
- timer countdown with semantic/live-region behavior near expiry;
- skip action;
- in-progress exit protection controlled by a setting;
- result persistence;
- result summary;
- correct/incorrect state with text/icon cues rather than color alone;
- submitted-answer and correct-answer review;
- explanations;
- bookmarks from review.

### Question creator

Implemented a responsive authoring workspace with:

- type selection;
- prompt;
- category;
- difficulty;
- choices;
- accepted answers;
- tags;
- explanation;
- optional timer;
- live preview;
- domain validation before save;
- duplicate rejection;
- user-safe persistence failure behavior.

### JSON / CSV import and export

Implemented:

- deterministic JSON export;
- deterministic CSV export;
- clipboard copy/paste workflow;
- JSON import;
- CSV import;
- row/entry validation;
- malformed-input reporting;
- duplicate reporting/skipping;
- support for quoted CSV fields including commas/quotes;
- import report;
- user-safe storage failure behavior.

The canonical interchange format is documented in `docs/question-bank-format.md`.

### Offline profiles and data

Implemented:

- default local profile creation;
- multiple local profiles;
- active-profile persistence;
- add profile;
- rename active profile;
- delete active profile while keeping at least one profile;
- profile-specific bookmarks;
- profile-specific quiz history/progress;
- clear active profile activity;
- reset all local application data with explicit confirmation and starter-data restoration.

### Statistics and leaderboard

Implemented:

- quiz count;
- answered-question count;
- correct-answer count;
- accuracy;
- best streak;
- accumulated play time;
- bookmark count;
- category-level answered/correct/accuracy aggregation;
- device-local leaderboard across local profiles.

No online leaderboard/account is required.

### Persistence

Implemented SQLite persistence through Drift infrastructure with explicit schema version 1.

Schema tables:

- `questions`
- `profiles`
- `attempts`
- `attempt_answers`
- `bookmarks`

Reliability work includes:

- foreign keys enabled on database open;
- transactions for multi-row question writes;
- transactions for attempt + attempt-answer writes;
- transactions for maintenance/reset operations;
- explicit indexes for current query patterns;
- schema version field;
- documented rule that released schema changes require migrations rather than editing an old schema in place.

### Starter fixtures

Added a deterministic fictional starter question bank covering multiple categories and all supported question types. It contains no real personal data and does not require internet access.

### Accessibility

Implemented or documented:

- scalable text;
- large-text preference;
- light/dark/system theme;
- reduced-motion preference wired into application media/theme behavior;
- screen-reader hints preference;
- semantic progress/timer labels;
- non-color-only correct/incorrect cues;
- standard keyboard/focus-capable Material controls;
- adaptive layouts;
- untimed quiz availability;
- manual release accessibility checklist in `docs/accessibility.md`.

### Internationalization readiness

Added:

- `flutter_localizations` dependency;
- `intl` dependency;
- `flutter.generate: true`;
- `l10n.yaml`;
- `lib/l10n/app_en.arb`;
- generated-localization delegates wired into `QuizForgeApp`;
- externalized English copy across the app root, onboarding, navigation shell, dashboard, quiz builder, quiz play, review, question creator, import/export, question bank, statistics, and settings/about flows;
- localization workflow documentation in `docs/localization.md`.

User-authored/imported question content remains data and is intentionally not translated by the UI localization layer.

### Structured logging and privacy hardening

Added a structured JSON application logger that:

- supports log levels;
- permits sink injection for tests;
- rejects unsafe event-name shapes;
- redacts sensitive keys such as password/token/secret/authorization/API key/credential/cookie/email;
- redacts user-content keys such as prompt/answer/content/profile display names/import/export data;
- redacts long and multiline string values;
- logs error *types* instead of dumping raw exceptions/user data in key persistence paths.

Initialization and UI operation errors use user-safe messages rather than raw internal details in major flows.

### Optional private-room multiplayer boundary

Added a transport-neutral `PrivateRoomTransport` architecture boundary and a disabled-by-default implementation that performs no networking and fails closed.

Real network multiplayer has **not** been deceptively claimed as implemented. A future transport must first satisfy the security/privacy requirements in ADR 0003.

### Branding

Added editable source branding artwork:

- `assets/branding/quizforge_logo.svg`

The logo is an editable SVG source and the product credit remains **Made by the Sanskar**.

## Automated tests added

### Domain tests

- question validation;
- answer normalization;
- question fingerprint behavior;
- multiple-choice scoring;
- exact-set multi-select scoring;
- short-answer accepted variants;
- deterministic seeded question selection;
- category/difficulty/tag filtering;
- result percentage;
- result duration;
- best-streak calculation;
- duplicate id/content handling.

### Import/export tests

- JSON round trip;
- CSV round trip;
- commas/quotes in CSV content;
- duplicate import reporting;
- malformed JSON reporting;
- malformed CSV quote reporting.

### Deterministic fuzz-style parser tests

- 500 deterministic random malformed JSON samples;
- 500 deterministic random malformed CSV samples;
- invariant: parser entry points should report malformed input rather than let parser exceptions escape the public decode call.

### Database integration tests

Using in-memory SQLite:

- question persistence;
- profile persistence;
- bookmark persistence;
- transactional attempt persistence;
- progress aggregation;
- category progress aggregation;
- leaderboard aggregation;
- clear-profile-activity behavior;
- profile rename;
- profile delete;
- full local-data reset.

### Widget tests

- localized widget-test harness;
- quiz question/choice/progress rendering;
- onboarding step navigation/completion;
- custom quiz builder empty/no-match state.

## GitHub repository engineering completed

Added:

- structured bug-report template;
- structured feature-request template;
- issue intake config;
- pull-request template;
- `CODEOWNERS`;
- Dependabot configuration for Dart/Flutter and GitHub Actions;
- BMC funding configuration;
- CI workflow for dependency install, localization generation, format, analysis, and tests;
- dependency-review workflow;
- scheduled/push OSV dependency vulnerability scan;
- tagged Android/web release workflow;
- artifact checksums in release workflow;
- repository governance/branch-protection/security-setting guidance.

## Build and developer tooling added

- `tool/bootstrap.sh`
- `tool/bootstrap.ps1`
- `tool/check.sh`
- `tool/check.ps1`

The bootstrap scripts run Flutter diagnostics, materialize platform runners, install dependencies, and generate localizations.

The quality scripts generate localizations, verify formatting, run analysis, and run tests with coverage.

## Documentation completed

Root documentation/policies:

- `README.md`
- `LICENSE`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SECURITY.md`
- `SUPPORT.md`
- `PRIVACY.md`
- `CHANGELOG.md`
- `ROADMAP.md`
- `what_changed.md`

Development/release documentation:

- `docs/architecture.md`
- `docs/setup.md`
- `docs/development.md`
- `docs/testing.md`
- `docs/release.md`
- `docs/troubleshooting.md`
- `docs/accessibility.md`
- `docs/performance.md`
- `docs/localization.md`
- `docs/question-bank-format.md`
- `docs/repository-settings.md`
- `docs/screenshots/README.md`

Architecture decisions:

- `docs/adr/0001-modular-monolith.md`
- `docs/adr/0002-drift-explicit-sql.md`
- `docs/adr/0003-offline-first-multiplayer-boundary.md`

## Commands / checks that have actually been run in this session

### Repository inspection

The GitHub repository and existing files/commits were inspected before continuing work.

### Local toolchain availability

The execution container available to this chat does not provide a usable Flutter/Dart SDK, so a trustworthy local `flutter analyze`, `flutter test`, or cross-platform build could not be executed from the chat container.

No passing-build claim is being made on the basis of source inspection alone.

### GitHub Actions

A verification pull request was created earlier to trigger CI/dependency-review checks. Its early run state was queued when last explicitly inspected. Because substantial additional work has since landed on `main`, a **new final audit branch/PR against the latest main state is still required** after the remaining source audit below.

The main CI workflow also triggers on pushes to `main`; final release-candidate status must use completed workflow evidence from the latest commit, not an older run.

## Known limitations / not-yet-verified items

These are intentionally explicit:

1. **Clean Flutter verification is pending.** Source has not yet been proven by a completed latest-commit `flutter analyze` + `flutter test` run in this chat.
2. **Production platform builds are pending.** Android/web/desktop/iOS release builds must be executed on supported hosts before they can be called release-verified.
3. **Platform runner directories are reproducibly generated by documented `flutter create . --platforms=...` commands rather than currently being treated as hand-maintained source.** Final release audit must verify this clean-checkout path.
4. **`pubspec.lock` should be generated/validated by Flutter in the final clean-build environment and committed for the application if the final repository policy keeps application lockfiles.** It must not be fabricated manually.
5. **Real private-room networking is intentionally not implemented/enabled.** Only the safe architecture boundary exists.
6. **Real screenshots are not committed yet.** `docs/screenshots/README.md` defines the required real-capture set. Fake screenshots are intentionally avoided.
7. **Performance budgets are documented, but measured benchmark evidence still needs a verified Flutter profile/release environment.**
8. **A manual accessibility pass with representative screen readers/keyboard/platform text scaling is still required before release-candidate status.**
9. **Store signing/provisioning credentials are intentionally absent from the public repository.**
10. **GitHub repository settings such as branch rulesets/secret scanning must be enabled in GitHub settings where available; tracked guidance exists in `docs/repository-settings.md`.**

## Exact next tasks

Execute these in order; do not skip directly to a release tag:

1. Finish a source-level analyzer-risk audit for recently changed localization/widget code.
2. Create a fresh audit branch from the latest `main`.
3. Add/update a small verification-evidence file on that branch so a pull request has an actual diff.
4. Open a fresh PR into `main` to trigger the current CI + dependency-review workflows.
5. Wait only through tool execution in the active session; inspect completed workflow status/jobs/logs using GitHub tooling.
6. If CI fails, fix every source/test/config defect with regression coverage where appropriate and rerun the failed/current workflow.
7. Obtain a clean Flutter-generated dependency lockfile in the verified toolchain; commit it if normal Flutter application policy is retained.
8. Run/build Android and Web from a clean checkout; verify Drift persistence behavior on both.
9. On the correct native hosts, verify Windows/macOS/Linux and iOS builds as applicable.
10. Record exact command output/evidence in `docs/verification.md` / this file.
11. Capture real release-build screenshots listed in `docs/screenshots/README.md`.
12. Perform manual accessibility review.
13. Update `CHANGELOG.md`, `ROADMAP.md`, and this file based on *actual* verification results.
14. Only then create a release-candidate/version tag and let `.github/workflows/release.yml` package verified Android/web artifacts.

## Migration notes

- Current database schema version: **1**.
- There are no prior public database-schema migrations in this repository baseline.
- Future schema changes must increment `schemaVersion`, implement an explicit migration path, and add migration tests.
- Question-bank format changes that rename/remove fields or enum identifiers are release-format changes and require compatibility notes/tests.
- Localization values are presentation-only and must not replace stable serialized domain enum identifiers.

## Release notes draft — 0.1.0 development baseline

QuizForge 0.1.0 establishes an offline-first cross-platform quiz-game and quiz-authoring foundation with four question types, deterministic daily/random/custom practice, timed quizzes, review/explanations/bookmarks, local profiles, SQLite progress tracking, category statistics, a local leaderboard, JSON/CSV question-bank interchange, a validated quiz creator, accessibility preferences, adaptive Material 3 UI, first-run onboarding, externalized English UI strings, privacy-first structured logging, public documentation, automated tests, and GitHub CI/security/release automation.

This draft must not be promoted to a production-release claim until the Phase 6 verification tasks above are completed.

## Recent meaningful commit themes

The repository history contains many small atomic commits as requested. Recent meaningful commit groups include:

- `feat: localize settings privacy profiles and about`
- `feat: localize progress and leaderboard views`
- `feat: localize question creator and preview`
- `feat: localize quiz result review experience`
- `feat: localize quiz play and exit protection copy`
- `feat: localize custom quiz setup controls`
- `feat: localize dashboard and practice actions`
- `feat: localize adaptive navigation shell`
- `feat: wire generated localization delegates into app root`
- `feat: add externalized English application strings`
- `build: enable Flutter localization generation`
- `fix: keep custom quiz count calculations strongly typed`
- `fix: use a valid typed result for protected route pops`
- `feat: add polished first-run onboarding experience`
- `feat: add profile maintenance detailed stats and data reset`
- `feat: protect in-progress quizzes and improve semantics`
- `feat: add structured redacting application logger`
- `test: fuzz question bank parsers with deterministic malformed input`
- `test: cover category statistics and local data maintenance`
- `ci: verify localization generation in quality gate`
- `ci: add tagged Android and web release workflow`
- `ci: add scheduled OSV dependency vulnerability scan`
- `ci: block vulnerable dependency changes in pull requests`
- documentation commits for architecture/setup/testing/release/security/privacy/accessibility/performance/localization/question-bank format/community/repository settings.

Use `git log --oneline` or GitHub commit history for exact current hashes; this file should be updated with final release/audit hashes after completed CI evidence exists.

## Handoff rule

When continuing QuizForge:

1. read this file first;
2. inspect latest `main` tree and recent commits;
3. inspect open PRs/issues and latest workflow results;
4. continue from the first unfinished item in **Exact next tasks**;
5. do not rewrite completed work unnecessarily;
6. do not claim a clean/broken state without running or inspecting the relevant verification;
7. update this file after every meaningful verification/milestone.

**Made by the Sanskar**

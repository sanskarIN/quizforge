# QuizForge — What Changed / Continuation Ledger

Last updated: 2026-08-19 (Asia/Kolkata)

This is the primary continuation handoff for QuizForge. It records implemented code, verification evidence, active branches/PRs, known limitations, and exact next work. Never convert a queued, pending, skipped, cancelled, or unobserved check into a passing claim.

## Current milestone

- Package version: `0.1.0+1`
- Repository: `https://github.com/sanskarIN/quizforge`
- Main release-audit branch: `audit/phase-6-verification-2026-08-19`
- Main release-audit PR: `#9` — `ci: complete Phase 6 hardening and release-candidate audit`
- Current continuation branch: `feature/phase-7-attempt-history-2026-08-19`
- Current continuation PR: `#10` — `feat: add recent local quiz attempt history`
- PR #10 base: `audit/phase-6-verification-2026-08-19`
- Visibility/source model: public / open source
- License: MIT
- Stack: Flutter + Dart + Drift/SQLite
- Intended targets: Android, iOS-ready, Web, Windows, macOS, Linux
- Required credit: **Made by the Sanskar**
- Requested Git commit email: `sanskarin@outlook.in`
- Status: Phases 0–5 remain substantially implemented. Phase 6 hardening/audit remains open. This continuation adds a Phase 7-style recent local attempt-history feature and also improves PR verification so nested feature PRs targeting the audit branch receive the maintained CI/build/security gates. Release-candidate status is still blocked by actual final-head verification evidence, a reviewed Flutter-generated `pubspec.lock`, platform/database runtime checks, manual accessibility review, real screenshots, and other release checks documented below.

## Repository continuity

- Existing repository history was inspected and continued rather than replaced.
- PR #9 remains the release-audit path from the audit branch into `main`.
- PR #10 is intentionally layered on the audit branch so the new product feature can be reviewed without bypassing the release-audit work.
- The continuation feature branch was originally cut from audit head `35b1a15e2e7581ba796b38063c4533daa51ecef2`.
- The audit branch advanced independently while this continuation was being implemented.
- The feature branch was synchronized with audit head `96c6fec11c12ca3e9bcd804226150c3a27400da5` using a two-parent merge commit while retaining the feature commits.
- After the audit workflow-trigger improvements, the feature branch was synchronized again with audit head `4282c6fd5380a1ac90969c27fff71044733d180c`.
- PR #10 is currently reported mergeable after those synchronizations.
- Work remains split into granular Conventional-Commit-style changes rather than a single monolithic commit.
- Older superseded PRs #6, #7, and #8 remain closed.
- `docs/verification.md` remains the Phase 6 evidence ledger.
- `docs/attempt-history-verification.md` is the verification checklist for the new recent-history feature.

## Product baseline retained

QuizForge retains the previously implemented core product capabilities:

- multiple-choice, true/false, multi-select, and short-answer questions;
- categories, difficulty, tags, timed and untimed quiz modes;
- daily quiz, randomized practice, timed sprint, and configurable custom sets;
- deterministic quiz selection/scoring fixtures;
- exact-set and normalized-answer scoring behavior;
- explanations and post-quiz review;
- local bookmarks;
- offline local profiles;
- aggregate progress statistics;
- category statistics;
- device-local leaderboard;
- JSON/CSV question-bank import/export;
- creator with validation and preview;
- duplicate id/content handling;
- Drift/SQLite persistence;
- local profile activity/data reset controls;
- onboarding and adaptive Material 3 shell;
- light, dark, and system themes;
- large-text, reduced-motion, and screen-reader-oriented settings;
- offline-first architecture;
- disabled-by-default/fail-closed private-room multiplayer boundary;
- support/funding/project identity UI;
- dedicated About experience;
- editable branding SVG assets;
- deterministic tests and benchmark tooling;
- maintained CI/build/security/release workflows.

## Phase 6 localization and UI hardening retained

The continuation preserves the Phase 6 localization architecture and fixes:

- Flutter-generated localization resources remain the UI-copy source of truth.
- `flutter_localizations` remains enabled.
- `intl: any` remains in place so Flutter stable selects its compatible `intl` dependency.
- Localization identifiers that conflicted with Dart keywords were replaced.
- `lib/l10n/app_en.arb` covers primary product workflows.
- Dashboard, quiz setup, quiz progress/timer semantics, true/false choices, review, question bank, creator, import/export, statistics, settings, privacy/data, profile management, updates, support, and About copy use localization resources where implemented.
- Custom quiz timer labels use localized `secondsShort(...)` output.
- Difficulty/question-type labels do not expose raw enum names as product UI labels.
- User-created/imported question content remains domain data rather than being falsely presented as translated framework copy.

## Phase 6 accessibility/responsive hardening retained

- App large-text mode never reduces an operating-system text scale that is already larger.
- System `disableAnimations` is preserved while the app reduced-motion preference can request stricter motion reduction.
- Quiz progress/timer semantics are localized and covered by semantics-enabled widget tests.
- Correct/incorrect review states use icon/semantic information rather than color alone.
- Review UI listens to controller state so bookmark icons can refresh after persisted changes.
- Dashboard action cards use adaptive wrapping/natural heights rather than a rigid fixed-aspect grid that could overflow on narrow screens/large text.
- Statistics cards use the same large-text-safe adaptive layout approach.
- Question-bank heading/actions use wrapping layout rather than a rigid row.
- Creator/section status layouts were hardened for long/scaled text.
- Narrow 360px / 2x-text regression coverage exists for dashboard/statistics layouts.

## Phase 6 persistence/error/privacy hardening retained

- Startup UI avoids rendering arbitrary raw initialization exception details.
- Creator/import/settings persistence failures use user-safe localized messages.
- Asynchronous settings/profile-selection failures are awaited/caught by safe wrappers.
- Bookmark persistence failures in question-bank and review flows are caught, safely logged, and surfaced without exposing raw user content.
- Structured logging uses stable event names and safe metadata such as exception runtime type.
- Sensitive/user-authored values are not intended to be serialized into normal diagnostic logs.
- `QuizForgeController.updateSettings()` persists before replacing visible in-memory settings.
- Active-profile persistence ordering and rollback-aware create/delete behavior remain covered by controller tests.

## Settings persistence architecture retained

The single-payload settings persistence work remains present:

- `AppSettings.toJson()` and `AppSettings.fromJson(...)`;
- safe fallback for unknown future theme values and invalid setting types;
- unified preference payload key `settings.v1`;
- unified payload preferred on load;
- malformed/missing unified payload can fall back to legacy individual keys;
- reset removes unified and legacy settings keys;
- domain tests cover settings serialization and fallback behavior.

This avoids a partial multi-key application-level settings write while maintaining backward compatibility with older local preference state.

## Import/resource and question validation hardening retained

`QuestionBankCodec` continues to enforce bounded local processing:

- maximum source size: `5 * 1024 * 1024` characters;
- maximum imported question count: `10000`;
- oversized JSON/CSV input rejected before expensive item-level parsing;
- excessive JSON question arrays rejected before per-item parsing;
- CSV parsing stops/reports when row limits are exceeded;
- malformed quote structure is rejected instead of ambiguously reinterpreted.

Question-domain validation continues to bound authored/imported content:

- id: max 120 characters;
- prompt: max 2000 characters;
- category: max 120 characters;
- choices: max 20;
- each choice: max 500 characters;
- correct/accepted answers: max 20;
- each answer: max 500 characters;
- tags: max 20;
- each tag: max 80 characters;
- explanation: max 5000 characters;
- timer: max 3600 seconds.

Canonical validation continues to reject blank accepted answers, normalized duplicate accepted answers, blank tags, normalized duplicate tags, and custom choice lists on true/false questions.

## Creator/About hardening retained

- Non-empty non-numeric creator time-limit input is not silently converted into “no limit”; it reaches the validation path as invalid input.
- Widget regression coverage verifies invalid timer input blocks creation.
- A standalone `AboutPage` exists in addition to quick settings information.
- About/project identity includes the repository, MIT/open-source identity, security policy, Buy Me a Coffee, business/support contact information, and required **Made by the Sanskar** credit.

## New continuation: recent local attempt history

This continuation adds a privacy-preserving recent-history experience without changing the database schema.

### Domain projection

`lib/src/domain/profile.dart` now defines `AttemptSummary`, a read-only summary projection containing:

- local attempt row id;
- start timestamp;
- completion timestamp;
- correct-answer count;
- question count;
- best streak;
- persisted earned score;
- computed accuracy;
- computed duration.

The projection intentionally does not contain submitted answer content.

### Database query

`lib/src/data/app_database_progress.dart` now exposes:

```dart
Future<List<AttemptSummary>> loadRecentAttempts(
  String profileId, {
  int limit = 10,
})
```

Behavior:

- limits must be between 1 and 100;
- rows are scoped to the active profile id supplied by the caller;
- newest completion time is returned first;
- `id DESC` is the deterministic tie-breaker for equal completion timestamps;
- the query reads the existing `attempts` table and does not create a duplicate history table;
- no schema-version increment or migration is required for this read-only projection.

The ordering contract is:

```sql
ORDER BY completed_at DESC, id DESC
LIMIT ?
```

### Application boundary

New file `lib/src/application/quizforge_controller_progress.dart` adds `QuizForgeControllerProgress` as an extension on the main controller.

`loadRecentAttempts({int limit = 10})`:

- returns an empty list if there is no active profile;
- otherwise delegates to the database query for the active profile;
- leaves the main controller class from the current audit baseline intact.

### Statistics UI

`lib/src/presentation/stats_page.dart` now includes a recent-attempt panel.

The panel:

- loads recent attempts for the active profile;
- uses a cached future rather than creating a new database future on every Flutter build;
- uses a refresh token combining active-profile id and aggregate quiz count;
- reloads when the active profile changes or the completed quiz count changes;
- uses `MaterialLocalizations.formatShortDate` and `TimeOfDay.format` for date/time presentation;
- displays correct/question count, best streak, elapsed time, and accuracy;
- uses existing localized strings rather than adding ad-hoc untranslated English status labels;
- displays a safe existing failure message when loading fails;
- does not display submitted answer text/choices.

### Deletion semantics

The feature follows existing lifecycle behavior:

- clearing active-profile activity deletes that profile's attempts, so recent history becomes empty;
- deleting a profile removes attempts through existing foreign-key cleanup;
- resetting all local data removes attempts before starter state is recreated.

### Recent-history automated coverage

`test/data/app_database_test.dart` now covers:

- `AttemptSummary` projection fields;
- computed duration;
- computed accuracy;
- newest-first ordering;
- explicit result limit;
- invalid limit rejection;
- history removal after clearing profile activity.

`test/widget/recent_attempt_history_test.dart` now covers:

- in-memory SQLite initialization;
- memory-only settings/profile adapters so the widget test does not rely on platform SharedPreferences behavior;
- persistence of a completed attempt;
- rendering of the history icon;
- correct/question count rendering;
- percentage rendering;
- elapsed-time rendering.

## New continuation documentation

Added:

- `docs/progress-history.md` — architecture, data source, refresh behavior, deletion semantics, privacy boundary, and verification expectations;
- `docs/attempt-history-verification.md` — exact automated commands plus manual profile/history checks;
- `docs/progress-history-data-contract.md` — projection field/source contract, SQL ordering/bounds, compatibility, and privacy details.

Updated:

- `README.md` — recent-history product/testing documentation and progress-history link;
- `ROADMAP.md` — marks recent per-profile attempt history plus database/rendering coverage as implemented;
- `CHANGELOG.md` — records the new projection/query/UI/privacy behavior;
- `what_changed.md` — this continuation ledger.

## Pull-request verification coverage improvement

A verification gap was found after PR #10 was created: the maintained workflows used `pull_request.branches: [main]`, so a legitimate stacked feature PR targeting the Phase 6 audit branch did not receive PR-triggered checks.

The audit branch was updated in separate commits so maintained PR verification applies to every pull request rather than only PRs whose base is `main`:

- `.github/workflows/ci.yml` — Flutter quality gate now listens to every PR;
- `.github/workflows/build.yml` — Android/Web build gate now listens to every PR;
- `.github/workflows/platform-builds.yml` — relevant platform matrix runs can trigger for any PR while retaining path filters;
- `.github/workflows/dependency-review.yml` — dependency review listens to every PR;
- `.github/workflows/osv-scan.yml` — relevant dependency/workflow changes can trigger on any PR while retaining path filters;
- `.github/workflows/secret-scan.yml` — full-history Gitleaks scan listens to every PR.

Push behavior remains scoped to `main` where it was previously scoped to `main`.

The feature branch was then synchronized with those updated audit workflows. This caused GitHub to create actual PR #10 verification runs on feature head `9b681d295485d326d4bf4e4ff582a44d6a2c2845`.

Observed immediately after synchronization:

- CI — run `32223411766` — queued;
- Platform Build Matrix — run `32223411773` — queued;
- Dependency Review — run `32223411787` — queued;
- Build Gate — run `32223411826` — queued;
- Secret Scan — run `32223411811` — queued.

OSV was not listed for that exact snapshot because the feature-head synchronization itself did not contain a dependency/OSV-path change relative to the current PR base. The OSV workflow remains path-filtered by design.

These queued states are evidence that PR #10 is now connected to the verification system; they are **not** passing results.

## Automated test coverage already present across the project

### Domain

Coverage includes question validation, answer normalization, duplicate fingerprint normalization, multiple-choice scoring, exact-set multi-select scoring, canonical true/false scoring, accepted short-answer variants, deterministic filtering/selection, result percentage/duration/streaks, disabled private-room transport fail-closed behavior, content/time bounds, settings serialization/fallbacks, and recent-attempt projection behavior through database integration coverage.

### Codec/parser

Coverage includes JSON/CSV round trips, commas/quotes in CSV, duplicate reporting, malformed JSON, malformed CSV quoting, oversized input rejection, question-count limits, and deterministic malformed-input/fuzz-style tests.

### Database/application

Coverage includes question/profile/bookmark/attempt persistence, aggregate progress, category statistics, leaderboard aggregation, maintenance/reset, rename/delete, foreign-key behavior, controller persistence/rollback ordering, and recent-attempt history ordering/limits/cleanup.

### Widget/journey

Coverage includes localization-aware test harnesses, quiz metadata/choices/progress, timer/progress semantics, creator validation, invalid creator timers, import reporting, settings/project credit, dedicated About content, onboarding/custom quiz setup, narrow large-text dashboard/statistics layouts, primary play → finish → review journey, and recent-attempt statistics rendering.

## CI/security/release automation retained

Maintained workflows cover:

- Flutter quality gate;
- Android/Web build gate;
- Linux/Windows/macOS/iOS platform build matrix;
- dependency review;
- OSV vulnerability scanning;
- full-history Gitleaks secret scanning;
- tagged Android/Web release packaging.

Phase 6 workflow hardening retained includes concurrency cancellation, credential-disabled checkouts where writes are unnecessary, localization generation before relevant analysis/build work, formatting scope over `lib`, `test`, and `tool`, repository-local Markdown link validation, and tag-release verification/checksum packaging.

Obsolete source-mutating/bootstrap workflows removed earlier remain removed.

## Local quality command contract

The maintained local quality flow remains:

```text
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
python3 tool/check_markdown_links.py
flutter analyze
flutter test --coverage
```

The available chat execution environment still does not provide a usable local Flutter/Dart SDK. This continuation therefore does not fabricate local Flutter command output. GitHub Actions and a verified developer Flutter environment remain the sources of executable verification evidence.

## `pubspec.lock` status

A hand-authored lockfile is prohibited.

A verified Flutter stable environment must generate `pubspec.lock` through normal dependency resolution. The resolved graph must be reviewed and the normal Flutter application lockfile committed before a release candidate can be treated as reproducible. CI can preserve generated lockfile evidence as an artifact, but an artifact alone is not a committed/reviewed application lockfile.

This remains a release blocker.

## Database/migration status

- Schema version remains `1`.
- Foreign keys are enabled at database open.
- Existing multi-step writes use transactions where required.
- In-memory SQLite creation/persistence tests exist.
- Recent attempt history is a read-only query over schema version 1 and requires no migration.
- No historical migration exists yet because no schema version greater than 1 has been released.
- The first future schema increment must include a real migration plus old-version-to-new-version tests.
- Release-build database behavior still requires actual target-platform verification.

## Known release blockers

1. PR #10's final-head checks have not yet completed successfully.
2. After PR #10 is merged into the audit branch, PR #9 must be re-evaluated on its new exact final head.
3. `pubspec.lock` still needs verified Flutter generation, review, and commit.
4. Clean-checkout localization/format/document-link/analyzer/full-test evidence remains required on the final release head.
5. Android release-build evidence remains required.
6. Web release build plus Drift creation/persistence/reload evidence remains required.
7. Windows/Linux/macOS host build evidence remains required on the final release head.
8. iOS no-codesign compile evidence remains required; signing/device distribution validation is external to public source control.
9. Real private-room networking remains intentionally unimplemented; only the disabled/fail-closed architecture boundary exists.
10. Production/store icon and splash generation/visual verification remains pending.
11. Real release-candidate screenshots remain pending; fabricated screenshots must not be used.
12. Manual keyboard/focus/screen-reader/large-text/reduced-motion/contrast review remains pending.
13. Representative performance measurements on documented hardware/toolchains remain pending.
14. Final documentation-link checking remains required on the final release head even though the checker is automated.
15. Final repository/history secret review remains required on the exact release head.
16. Store signing/provisioning credentials remain intentionally absent from the public repository.

## Exact next tasks

Continue in this order:

1. Read this file, `docs/verification.md`, and `docs/attempt-history-verification.md` first.
2. Fetch PR #10 and record its exact newest head SHA.
3. Fetch the PR #10 CI, Build Gate, Platform Build Matrix, Dependency Review, Secret Scan, and any applicable OSV run for that exact head.
4. If any workflow fails, fetch the failing jobs/steps/logs, make a focused defect fix, add regression coverage when applicable, and rerun/trigger the affected checks.
5. Do not merge PR #10 while required checks are queued, pending, or failing.
6. Perform the manual recent-history verification checklist on a real built target when an executable environment is available.
7. Merge PR #10 into `audit/phase-6-verification-2026-08-19` only after its applicable checks are acceptable.
8. Fetch PR #9 again after that merge and treat its new audit head as the only relevant release-audit head.
9. Generate/review/commit `pubspec.lock` from verified Flutter stable dependency resolution using the requested Git identity.
10. Run the full clean-checkout quality contract on the exact audit head.
11. Verify Android and Web builds, including Drift database creation/persistence/import-export and Web refresh/reload behavior.
12. Verify Windows/Linux/macOS on appropriate hosts and iOS no-codesign compile on macOS.
13. Run manual keyboard/focus/screen-reader/large-text/reduced-motion/contrast review.
14. Generate and visually verify production platform icon/splash treatment.
15. Capture real release-candidate screenshots with fictional/demo data.
16. Record representative performance measurements using documented hardware/toolchain information.
17. Perform final documentation-link and repository/history secret review on the exact release head.
18. Update `docs/verification.md`, `CHANGELOG.md`, `ROADMAP.md`, and this file with actual final evidence.
19. Merge PR #9 into `main` only after applicable blockers are cleared and repository policy allows it.
20. Only after final evidence is green, create the release/version tag and allow the release workflow to package verified Android/Web artifacts.

## Recent meaningful continuation commits

Recent attempt-history work:

- `8e8f31f4` — `feat: model recent quiz attempts`
- `1c848f0a` — `feat: query recent quiz attempts`
- `177c33c5` — `feat: expose recent attempt history`
- `c9c07d4b` — `feat: show recent quiz history in statistics`
- `0b34ef4f` — `test: cover recent attempt history queries`
- `d6795992` — `test: verify recent quiz history rendering`
- `60fd8dc7` — `test: await invalid recent-attempt limits`
- `c9b94c12` — `test: isolate attempt history from platform preferences`
- `310a961f` — `docs: document local attempt history`
- `d40a35f8` — `docs: link local attempt history architecture`
- `858e5a6d` — `docs: track recent attempt history milestone`
- `7d56cba5` — `docs: record recent attempt history feature`
- `1f77311a` — `docs: add attempt history verification checklist`
- `0cd0bed6` — `docs: define attempt history data contract`
- `d311af0f` — `merge: sync latest phase 6 audit changes`
- `9b681d29` — `merge: inherit all-pull-request verification gates`

Recent audit-branch verification-trigger improvements:

- `45b523d9` — `ci: run quality checks for every pull request`
- `00b6252c` — `ci: run build gate for every pull request`
- `dcf1005b` — `ci: run platform matrix for every relevant pull request`
- `db4d0d70` — `ci: review dependencies for every pull request`
- `1949d615` — `ci: scan dependencies for every relevant pull request`
- `4282c6fd` — `ci: scan secrets for every pull request`

Earlier Phase 6 commits include localization, accessibility, responsive-layout, profile/settings persistence ordering, import bounds, question-domain bounds, CSV parsing, dedicated About UI, logging/privacy hardening, workflow cleanup, link validation, tests, and release documentation. Inspect the complete Git history/PR timelines for the exhaustive ordered record rather than treating this list as a replacement for Git history.

## Release-notes draft

QuizForge now has a broad offline-first cross-platform quiz-game and authoring foundation with four question types, deterministic daily/random/custom practice, timed play, explanations/review/bookmarks, local profiles, SQLite progress/category tracking, a local leaderboard, recent per-profile attempt history, bounded JSON/CSV question-bank interchange, validated authoring, adaptive Material 3 UI, onboarding, externalized English UI strings, accessibility preferences, a dedicated About/contact/funding experience, privacy-aware structured logging, deterministic fuzz-style tests, primary journey automation, platform/security workflows, and extensive documentation.

The newest continuation adds a bounded newest-first local attempt-history projection and Statistics UI while deliberately omitting submitted-answer content from the history summary. It also closes a stacked-PR verification gap by allowing the maintained PR checks to run when a feature PR targets the active audit branch rather than only when a PR targets `main`.

This is still a **development baseline / release-candidate audit**, not a production-release claim, until all applicable blockers above are cleared with actual evidence.

## Continuation rule

Do not restart completed phases and do not replace working architecture with duplicate scaffolding. Continue from the newest PR #10/PR #9 states, inspect exact-head workflow evidence first, fix only actual remaining defects or coherent product gaps, preserve meaningful atomic commits, and update this file after each substantial continuation block.

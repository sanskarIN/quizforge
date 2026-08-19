# QuizForge — What Changed / Continuation Ledger

Last updated: 2026-08-19 (Asia/Kolkata)

This file is the primary handoff for continuing QuizForge. It records implemented work, verification evidence, limitations, and the exact next tasks. Do not convert queued/pending checks into passing claims.

## Current milestone

- Package version: `0.1.0+1`
- Repository: `https://github.com/sanskarIN/quizforge`
- Active branch: `audit/phase-6-verification-2026-08-19`
- Active PR: `#9` — `ci: complete Phase 6 hardening and release-candidate audit`
- Audit base: `main` at `d8c27cc81f678b1e49c17670c3d1efeab3d044d3`
- Visibility/source model: public / open source
- License: MIT
- Stack: Flutter + Dart + Drift/SQLite
- Targets: Android, iOS-ready, Web, Windows, macOS, Linux
- Required credit: **Made by the Sanskar**
- Requested Git commit email: `sanskarin@outlook.in`
- Status: Phases 0–5 are substantially implemented. Phase 6 source/configuration hardening has been extended significantly in this continuation, but release-candidate verification is still blocked by final-head CI/build/security evidence, a generated/reviewed `pubspec.lock`, platform/database runtime checks, manual accessibility review, and real release screenshots.

## Repository continuity

- Existing history was inspected and continued rather than replaced.
- Phase 6 work is isolated on the audit branch above.
- PR #9 remains open and mergeable.
- Older PRs #6, #7, and #8 were closed as superseded.
- Work was split into small Conventional-Commit-style changes rather than one monolithic commit.
- `docs/verification.md` remains the evidence ledger for release verification.
- Obsolete source-mutating bootstrap workflows were removed from the maintained branch.

## Product baseline retained

The repository retains the major master-prompt product features:

- multiple-choice, true/false, multi-select, and short-answer questions;
- categories, difficulty, tags, timed/untimed modes;
- daily quiz, randomized practice, timed sprint, and configurable custom sets;
- deterministic quiz selection/scoring fixtures;
- scoring, streaks, explanations, review mode, bookmarks;
- offline local profiles, progress statistics, category statistics, and local leaderboard;
- JSON/CSV question-bank import/export;
- creator with validation and preview;
- duplicate-id/content handling;
- Drift/SQLite persistence;
- local data/activity reset controls;
- onboarding and adaptive Material 3 shell;
- light/dark/system themes;
- large-text, reduced-motion, and screen-reader-oriented settings;
- offline-first architecture;
- disabled-by-default/fail-closed private-room multiplayer boundary;
- support/funding/project identity UI;
- editable branding SVG assets;
- deterministic tests and benchmark tooling.

## Phase 6 localization work

- Kept Flutter-generated localization architecture with externalized ARB strings.
- Kept `flutter_localizations` and `intl: any` so Flutter stable selects its compatible `intl` version.
- Replaced localization identifiers that conflicted with Dart keywords.
- Expanded `lib/l10n/app_en.arb` for primary workflows.
- Localized dashboard, quiz setup, quiz progress/timer semantics, true/false choices, review, question bank, creator, import/export, statistics, settings, privacy/data, profile management, updates, support, and About copy.
- Custom quiz timer values now use localized `secondsShort(...)` output.
- Difficulty/question-type labels no longer expose enum names directly in localized product UI.
- User-authored/imported question content remains domain data rather than being falsely treated as translated framework copy.

## Accessibility and responsive-layout hardening

- Fixed app-level text scaling so QuizForge large-text mode never reduces a larger operating-system text scale.
- Preserved system `disableAnimations` while allowing the app reduced-motion preference to add stricter motion reduction.
- Quiz progress/timer semantics are localized and covered with semantics-enabled widget tests.
- Correct/incorrect review status remains distinguishable by icon/semantic label, not color alone.
- Review UI listens to controller state so bookmark icons refresh after changes.
- Dashboard action cards no longer use a fixed-aspect grid that could overflow with narrow screens/large text; they now use adaptive wrapping with natural card height.
- Statistics cards received the same large-text-safe adaptive layout treatment.
- Question-bank heading/actions use a wrapping header layout instead of a rigid row.
- Section/creator status rows were hardened so long/scaled text has flexible width.
- Added narrow 360px / 2x-text regression coverage for dashboard and statistics layouts.

## Error handling and privacy hardening

- Startup UI no longer renders arbitrary raw initialization exception details.
- Creator/import/settings persistence failures use user-safe localized messages.
- Asynchronous settings/profile-selection failures are now awaited/caught by safe action wrappers.
- Bookmark persistence failures in both question-bank and review flows are caught, logged with safe metadata, and surfaced with localized error UI instead of becoming unhandled futures.
- Logging uses stable event names and safe fields such as exception runtime type rather than serializing raw imported/user content.
- Structured logging remains the supported logging path rather than ad-hoc `print` calls.

## Settings reliability work

### Persist-before-mutate controller ordering

`QuizForgeController.updateSettings` now persists settings before replacing in-memory state. A failed local preference write therefore cannot make the controller/UI claim a setting was saved.

### Single-payload settings persistence

Settings were previously written as multiple independent preference keys. That created a partial-write risk if one write failed after earlier writes succeeded.

Implemented:

- `AppSettings.toJson()` and `AppSettings.fromJson(...)`;
- safe fallback for unknown future theme values and invalid setting types;
- new single JSON preference payload key: `settings.v1`;
- `SettingsRepository.load()` prefers the unified payload;
- malformed/missing unified payload falls back to the legacy individual keys for backward compatibility;
- reset removes both the unified payload and legacy keys;
- new domain tests cover full round-trip serialization and safe invalid-value fallback.

This narrows settings persistence from multiple app-level writes to one app-level settings write while preserving compatibility with previously stored local preferences.

## Import/resource security hardening

`QuestionBankCodec` now has explicit local-resource limits:

- max source size: `5 * 1024 * 1024` characters;
- max imported question count: `10000`.

Behavior:

- oversized JSON/CSV input is rejected before expensive item-level parsing;
- JSON rejects oversized question arrays before per-question parsing;
- CSV stops when row limits are exceeded;
- malformed JSON/CSV continues to return controlled import errors rather than uncontrolled parser exceptions.

Tests cover oversized payload rejection and excessive JSON question counts.

## Question-domain validation hardening

`Question.validate()` now bounds untrusted/authored content:

- id: max 120 chars;
- prompt: max 2000 chars;
- category: max 120 chars;
- choices: max 20;
- each choice: max 500 chars;
- correct/accepted answers: max 20;
- each answer: max 500 chars;
- tags: max 20;
- each tag: max 80 chars;
- explanation: max 5000 chars;
- timer: max 3600 seconds.

Canonical validation now also rejects:

- blank accepted answers;
- accepted answers duplicated after normalization;
- blank tags;
- tags duplicated after normalization;
- custom choices on true/false questions.

Starter/demo true/false fixtures were inspected and are compatible with the stricter rule.

## Creator hardening

- Creator labels/difficulty values are localized.
- Non-empty, non-numeric optional time limits no longer silently become “no limit.”
- Invalid non-numeric time input is converted into an invalid domain value and rejected by the existing timer validation path.
- Added widget regression coverage proving an invalid timer prevents question creation and surfaces the validation message.

## Dedicated About page

A standalone `AboutPage` was added because the master prompt explicitly asks for a real About page, not only an inline settings section.

It contains:

- QuizForge identity/version;
- open-source/MIT product description;
- GitHub repository link;
- security-policy link;
- Buy Me a Coffee link;
- business email `sanskarin@outlook.in`;
- business email `sanskarin.business@gmail.com`;
- support email `supportramsandesh@gmail.com`;
- clickable external/mail links;
- required **Made by the Sanskar** credit.

Settings now provides direct navigation to this dedicated About page while retaining the existing quick About/contact section. Widget tests cover the page identity, contacts, funding, and credit.

## Automated test coverage added/corrected

### Domain

- question validation;
- answer normalization;
- duplicate fingerprint normalization;
- multiple-choice scoring;
- exact-set multi-select scoring;
- canonical true/false scoring;
- accepted short-answer variants;
- deterministic filtering/selection;
- result percentage/duration/streaks;
- private-room disabled transport fail-closed behavior;
- blank/normalized-duplicate accepted answers;
- normalized-duplicate tags;
- true/false custom-choice rejection;
- content/time bounds;
- AppSettings serialization/fallback behavior.

### Codec/parser

- JSON round-trip;
- CSV round-trip;
- commas/quotes in CSV;
- duplicate reporting;
- malformed JSON;
- malformed CSV quoting;
- oversized input rejection;
- question-count limit rejection;
- deterministic malformed-input fuzz-style tests for JSON and CSV.

### Database

The existing in-memory SQLite suite covers question/profile/bookmark/attempt persistence, progress/category statistics, leaderboard aggregation, maintenance/reset, rename/delete, and transaction/foreign-key behavior represented by the database implementation.

### Widget/journey

- localization-aware test harness;
- quiz metadata/choices/progress;
- explicit semantics tests for timer/progress;
- creator validation and invalid time limit;
- import report;
- settings sections/project credit;
- dedicated About page;
- onboarding/custom quiz setup;
- narrow dashboard at 2x text scale;
- narrow statistics screen at 2x text scale;
- primary one-question play → finish → review journey including score, correct answer, and explanation.

## CI/security/release automation

Maintained focused workflows cover:

- Flutter quality gate;
- Android/Web build gate;
- Linux/Windows/macOS/iOS build matrix;
- dependency review;
- OSV vulnerability scanning;
- full-history Gitleaks secret scanning;
- tagged Android/Web release packaging.

Improvements made in Phase 6:

- concurrency cancellation for superseded pull-request runs;
- hardened checkouts with credentials disabled where writes are unnecessary;
- `flutter gen-l10n` before analysis/tests/build verification;
- formatting scope includes `lib`, `test`, and `tool`;
- OSV scan runs for relevant pull-request dependency changes;
- release workflow verifies tag/version relationship, localizations, formatting, analysis, tests, Android/Web builds, checksums, workflow artifacts, and GitHub release publication.

Removed obsolete bootstrap/source-mutating workflows:

- `.github/workflows/fix-intl-dependency.yml`
- `.github/workflows/finalize-baseline.yml`
- `.github/workflows/stabilize-baseline.yml`
- `.github/workflows/verify-latest-baseline.yml`
- `.github/workflows/materialize-platform-runners.yml`

A temporary write-capable one-shot lockfile workflow was also removed after it failed to execute promptly; unnecessary `contents: write` automation was not left in the maintained repository.

## Local quality scripts

`tool/check.sh` and `tool/check.ps1` are synchronized with the maintained quality sequence:

```text
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

## Documentation status

Updated during Phase 6:

- `README.md`
- `CHANGELOG.md`
- `ROADMAP.md`
- `what_changed.md`
- `docs/setup.md`
- `docs/development.md`
- `docs/testing.md`
- `docs/ci.md`
- `docs/release.md`
- `docs/verification.md`

README screenshot slots are explicitly placeholders. Fake screenshots are not presented as release evidence. Real captures remain tied to the exact verified release candidate and fictional/demo data.

## Verification evidence and limitations

### Local execution limitation

The available chat execution environment does not provide a usable Flutter/Dart SDK, and direct container cloning/network access was unavailable. Therefore this continuation does not fabricate local output for:

- `flutter pub get`;
- `flutter gen-l10n`;
- `dart format`;
- `flutter analyze`;
- `flutter test`;
- platform builds.

Those remain real release gates.

### GitHub Actions snapshot before this handoff update

The source head immediately before this handoff-document commit was:

`4c206b8cc0ec5ec31e8c938736049a7a7a56e53a`

PR #9 had 76 commits and was reported mergeable. On that head the observed runs were:

- CI — run `32220173776` — pending;
- OSV Vulnerability Scan — run `32220174015` — pending;
- Dependency Review — run `32220173748` — pending;
- Build Gate — run `32220173747` — queued;
- Platform Build Matrix — run `32220173749` — queued;
- Secret Scan — run `32220173773` — queued.

This `what_changed.md` update itself creates a newer PR head and therefore newer workflow runs. The next continuation must query the latest PR head and use only those latest runs for the release decision. Pending/queued is **not** passing evidence.

## `pubspec.lock` status

`pubspec.lock` is still absent from the audit branch.

Do not hand-author it. A verified Flutter stable environment must run `flutter pub get`, review the resolved graph, and commit the normal application lockfile. All affected quality/dependency/build/security gates must then rerun on that exact head.

This remains a release-candidate blocker.

## Database/migration status

- Schema version is explicitly `1`.
- Foreign keys are enabled at database open.
- Current multi-step writes use transactions where required.
- In-memory SQLite creation/persistence tests exist.
- No historical migration exists yet because no schema version greater than 1 has been released.
- The first schema increment must add a real migration plus old-version-to-new-version migration tests.
- Android/Web release-build database creation/persistence/reload behavior still needs real platform verification.

## Known release blockers

1. Final-head quality/build/security workflows have not completed successfully.
2. `pubspec.lock` is not yet generated/reviewed/committed from a verified Flutter environment.
3. Android release build evidence is pending.
4. Web release build plus Drift creation/persistence/reload evidence is pending.
5. Windows/Linux/macOS release-host build evidence is pending on the final head.
6. iOS no-codesign compile evidence is pending; distribution signing/device validation belongs outside public source control.
7. Real private-room networking is intentionally not implemented; the current architecture is disabled/fail-closed.
8. Production/store icon and splash output still needs actual platform generation/visual verification.
9. Real release-candidate screenshots are pending.
10. Manual keyboard/focus/screen-reader/large-text/reduced-motion/contrast review is pending.
11. Representative benchmark measurements on documented hardware/toolchains are pending.
12. Final documentation-link checking is pending.
13. Final repository/history secret review must be performed on the exact release head.
14. Store signing/provisioning credentials are intentionally absent from the public repository.

## Exact next tasks

Continue in this order:

1. Read this file and `docs/verification.md` first.
2. Fetch PR #9 and record its newest head SHA.
3. Fetch CI, Build Gate, Platform Build Matrix, Dependency Review, OSV, and Secret Scan for that exact head.
4. If any run fails, inspect the failing job/step/log, make a focused fix, add regression coverage when applicable, and rerun affected gates.
5. Do not merge PR #9 while required checks are queued, pending, or failing.
6. In a verified Flutter stable environment run `flutter pub get`; review and commit `pubspec.lock` with the requested Git identity, then rerun affected checks.
7. From a clean checkout run localization generation, formatting, analyzer, and the full automated test suite.
8. Verify Android and Web builds; exercise Drift database creation, persistence, import/export, and Web refresh/reload behavior.
9. Verify Windows/Linux/macOS on appropriate hosts and iOS no-codesign compile on macOS.
10. Run manual keyboard/focus/screen-reader/large-text/reduced-motion/contrast review.
11. Generate/visually verify platform icons/splash treatment.
12. Capture real screenshots from the exact verified release candidate using fictional data.
13. Check documentation links and perform the final repository/history secret review.
14. Update `docs/verification.md`, `CHANGELOG.md`, `ROADMAP.md`, and this file with actual final evidence.
15. Merge PR #9 only after applicable blockers are cleared, preserving meaningful atomic history where repository policy allows.
16. Create the version/release-candidate tag only after final evidence is green and allow the tag release workflow to package verified Android/Web artifacts.

## Recent meaningful commits

Earlier Phase 6 commits include localization, CI, security, testing, documentation, import bounds, question bounds, settings ordering, and workflow cleanup. The latest continuation also added:

- `14dbbf5` — `test: enable semantics in quiz rendering coverage`
- `91e5b81` — `feat: localize custom quiz timer values`
- `ca28357` — `fix: make dashboard cards resilient to large text`
- `f07a716` — `test: cover narrow dashboard with large text`
- `56c3325` — `fix: surface asynchronous settings failures`
- `dfcc216` — `fix: make statistics cards resilient to large text`
- `2d179b3` — `test: cover narrow statistics layout with large text`
- `8f068e4` — `fix: harden question bank bookmarks and header layout`
- `e606a8b` — `fix: surface review bookmark persistence failures`
- `58d2b7f` — `fix: reject invalid creator time limits`
- `df59f6a` — `test: cover invalid creator time limit`
- `9a6e6b7` — `feat: add dedicated About page`
- `65665f2` — `feat: link settings to dedicated About page`
- `fe2ca65` — `test: cover dedicated About page content`
- `55c1733` — `test: account for dedicated About navigation`
- `49690df` — `feat: add stable settings serialization`
- `45ab8fa` — `refactor: persist settings as one atomic payload`
- `5121969` — `test: cover settings serialization fallbacks`

Because commits are intentionally granular, inspect `git log` / PR #9 for the full ordered history rather than treating the list above as exhaustive.

## Release-notes draft

QuizForge now has a broad offline-first cross-platform quiz-game and authoring foundation with four question types, deterministic daily/random/custom practice, timed play, review/explanations/bookmarks, local profiles, SQLite progress tracking, category statistics, a local leaderboard, bounded JSON/CSV question-bank interchange, validated authoring, adaptive Material 3 UI, onboarding, externalized English product strings, accessibility preferences, a dedicated About/contact/funding experience, privacy-aware structured logging, deterministic fuzz-style tests, primary quiz-journey automation, platform/security workflows, extensive documentation, and a Phase 6 evidence ledger.

Phase 6 further hardens localization identifiers, system text scaling, narrow/large-text layouts, import resource usage, question content bounds, creator timer validation, bookmark/settings persistence failures, settings write ordering/serialization, error redaction, workflow permissions, and release documentation.

This is still a **development baseline / release-candidate audit**, not a production-release claim, until all applicable blockers above are cleared with actual evidence.

## Continuation rule

Do not restart completed phases and do not replace working architecture with duplicate scaffolding. Continue from PR #9 and the newest repository state, inspect current workflow evidence first, fix only actual remaining defects/blockers, keep commits atomic and meaningful, and update this file after substantial continuation work.

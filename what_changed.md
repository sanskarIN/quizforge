# QuizForge — What Changed / Final Continuation Ledger

Last updated: 2026-08-19 (Asia/Kolkata)

This file is the primary detailed handoff for the QuizForge repository. It distinguishes **implemented source work** from **verification evidence that has actually completed**. Never treat a queued, pending, cancelled, superseded, skipped-but-applicable, or unobserved check as passing.

## Current repository milestone

- Repository: `https://github.com/sanskarIN/quizforge`
- Visibility/source model: public / open source
- License: MIT
- Package version currently in source: `0.1.0+1`
- Stack: Flutter + Dart + Drift/SQLite
- Intended source targets: Android, iOS, Web, Windows, macOS, Linux
- Required product credit: **Made by the Sanskar**
- Requested maintainer commit email: `sanskarin@outlook.in`
- Current final consolidation branch: `final/consolidated-release-audit-20260819`
- Current final consolidation PR: `#12` — `release: consolidate final QuizForge audit`
- PR #12 base: `main`
- `main` base SHA when PR #12 was opened: `d8c27cc81f678b1e49c17670c3d1efeab3d044d3`
- Status: **implementation consolidation complete; release verification still blocked until final-head automated and manual gates pass**.

## Why a consolidation branch was required

The repository had three important open lines of work that diverged from the same older `main` baseline:

1. PR #9 — `audit/phase-6-verification-2026-08-19`
   - Phase 6 import/resource validation, UI/localization/accessibility, persistence-ordering, privacy/logging, workflow, testing, and release-documentation hardening.
2. PR #10 — `feature/phase-7-attempt-history-2026-08-19`
   - Based on PR #9 and therefore already carrying that stronger Phase 6 baseline.
   - Added bounded recent local quiz-attempt history and its application/UI/tests/docs.
3. PR #11 — `audit/phase6-20260819`
   - Parallel audit line with useful full local backup/restore work, ARB validation tooling, repository-validator tests, and documentation.
   - Also contained overlapping store/controller abstractions that were not automatically stronger than the already-hardened PR #10 implementation.

Blindly merging PR #11 into PR #10 would have risked replacing stronger persistence behavior with overlapping/weaker refactors or creating large conflict-driven churn. The final branch therefore started from PR #10 head `a3d9426f4819468bf2cf360d4062fd0a607bdfe8` and selectively ported/audited the useful unique PR #11 capabilities.

The result is PR #12, which is the maintained final integration candidate.

## Product baseline retained from earlier work

The consolidated branch retains the major QuizForge product surface already implemented before this continuation:

- multiple-choice questions;
- true/false questions;
- multi-select questions;
- short-answer questions;
- exact-set and normalized-answer scoring;
- deterministic seeded quiz selection;
- daily quiz;
- random practice;
- timed sprint;
- configurable custom quiz setup;
- categories;
- difficulty filters;
- tag filters;
- explanations and answer review;
- question bookmarks;
- local profiles;
- profile rename/delete;
- per-profile aggregate statistics;
- category statistics;
- local leaderboard;
- recent per-profile attempt history;
- question creator with validation and preview;
- JSON/CSV question-bank import/export;
- duplicate-id and normalized-content protection;
- Drift/SQLite local persistence;
- active-profile activity clearing;
- complete local-data reset;
- onboarding;
- responsive Material 3 shell;
- light/dark/system themes;
- large-text and reduced-motion preferences;
- screen-reader-oriented semantic hints;
- safe confirmation before leaving an in-progress quiz;
- offline-first application boundary;
- disabled-by-default/fail-closed private-room multiplayer transport abstraction;
- support/business/funding/project identity UI;
- dedicated About page;
- branding source assets;
- deterministic tests and benchmark tooling;
- focused CI/build/security/release workflows.

## Retained Phase 6 hardening from PR #9 / PR #10

### Question/import resource safety

The maintained question-bank path retains bounded local processing and domain validation, including:

- question-bank source-size limits;
- question-count limits;
- bounded question ids, prompts, categories, choices, accepted answers, tags, explanations, and timers;
- rejection of blank/normalized-duplicate accepted answers;
- rejection of blank/normalized-duplicate tags;
- canonical true/false constraints;
- malformed JSON reporting;
- strict CSV quote-structure handling;
- rejection of unexpected quotes in unquoted fields;
- rejection of trailing characters after closing quoted fields;
- duplicate id/content partitioning before persistence;
- deterministic malformed-input/fuzz-style regression coverage.

### Persistence ordering and rollback safety

The consolidated controller retains the stronger persistence-first behavior from PR #10 rather than replacing it with a parallel abstraction solely for branch similarity:

- settings are persisted before visible in-memory settings are replaced;
- active-profile target data is loaded and profile preference persistence succeeds before visible active-profile state changes;
- profile creation rolls the inserted profile back if activation persistence fails;
- active-profile deletion persists the replacement preference before deleting the old database profile;
- profile-operation rollback paths preserve original stack traces;
- post-write derived leaderboard/progress refresh failures do not incorrectly report an already-persisted primary write as unsaved;
- full reset attempts every independent store reset, clears stale memory, reloads durable state, and then reports the first reset failure.

### Settings storage

The versioned unified settings payload remains in place:

- `AppSettings.toJson()` / `AppSettings.fromJson(...)`;
- `settings.v1` unified preference payload;
- safe fallback for malformed/newer values;
- legacy key fallback for migration;
- reset cleanup for unified and legacy keys;
- domain/controller regression coverage.

### Accessibility/localization/UI hardening

The consolidated branch retains:

- English ARB resources for primary application workflows;
- generated-localization usage across major navigation/UI surfaces;
- non-keyword localization identifiers;
- localized quiz metadata and timing labels;
- large-text behavior that does not reduce a larger OS text scale;
- reduced-motion/system animation handling;
- semantic quiz progress/timer labels;
- non-color-only correctness state cues;
- adaptive/wrapping dashboard/statistics/question-bank/creator layouts;
- narrow-screen/large-text regression tests;
- controller-driven bookmark UI refresh in review;
- safe localized user-facing operation errors instead of raw exception content.

### Privacy/logging hardening

The maintained logger and application error paths are designed not to expose:

- question prompts/answers;
- profile display names;
- email values;
- raw imports/exports;
- backup archives;
- credentials/tokens/cookies/authorization values;
- arbitrary long/multiline exception/user content.

Stable event names and small safe metadata such as exception runtime types are preferred.

## Recent local attempt history retained from PR #10

The consolidation preserves the newer recent-history feature rather than returning to the older Phase 6-only UI.

### Domain/read model

`AttemptSummary` provides a privacy-preserving projection of a completed attempt:

- attempt id;
- start/completion timestamps;
- correct count;
- question count;
- best streak;
- earned score;
- computed accuracy;
- computed duration.

Submitted-answer content is intentionally absent from the summary.

### Database contract

`loadRecentAttempts(profileId, limit: ...)`:

- is scoped to one local profile;
- defaults to a bounded result;
- accepts limits only in the supported range;
- sorts newest first by completion timestamp;
- uses attempt id as deterministic tie-breaker;
- projects the existing `attempts` table rather than adding duplicate persistence;
- requires no schema migration for this read-only feature.

### Presentation contract

Statistics recent-history UI:

- caches its async read future rather than issuing a new database query on every build;
- refreshes when active profile/completed-quiz state materially changes;
- uses Flutter-localized date/time formatting;
- shows score/progress/duration/streak/accuracy summary data;
- does not expose submitted answers;
- follows existing profile activity deletion semantics.

### Recent-history tests/docs

Coverage/documentation retained includes:

- database ordering;
- profile isolation;
- result limits;
- invalid-limit rejection;
- cleanup after activity deletion;
- in-memory database widget rendering;
- `docs/progress-history.md`;
- `docs/progress-history-data-contract.md`;
- `docs/attempt-history-verification.md`.

## New final consolidation feature: complete local backup/restore

The final branch now supports a **logical, versioned whole-app local backup**, separate from JSON/CSV question-bank interchange.

### Backup scope

Backup version 1 can contain:

- questions;
- question choices and accepted/correct answers;
- question categories/difficulty/tags/explanations/time limits;
- local profile ids/display names/creation timestamps;
- completed quiz attempt summaries;
- submitted-answer sets and correctness/score rows;
- bookmarks;
- application appearance/accessibility settings;
- active-profile selection;
- archive creation timestamp.

A complete backup is therefore private user data and must not be treated like a public/shareable question pack.

### Backup format identity

- format: `quizforge-local-backup`
- version: `1`
- JSON archive;
- explicit UTC creation timestamp;
- maximum supported archive size enforced before decoding;
- encoder also enforces the same supported size boundary so the app does not intentionally export an archive that the same version refuses solely because of size.

### Database snapshot validation

`DatabaseBackupSnapshot.validate()` now checks:

- question domain validity;
- duplicate question ids;
- duplicate normalized question content;
- at least one local profile for a valid whole-app snapshot;
- profile domain validity;
- duplicate profile ids;
- attempt profile references;
- attempt completion timestamps;
- non-negative aggregate counts;
- question-count/evaluation-count consistency;
- correct-count/evaluation-correctness consistency;
- order-independent best-streak invariants;
- finite/non-negative attempt total score;
- attempt score/evaluation-score consistency;
- attempt question references;
- duplicate question answers inside one attempt;
- finite/non-negative per-answer scores;
- bookmark profile/question references;
- duplicate bookmarks.

### Why profileless backups are rejected

Controller-generated valid application state always has a local profile. Allowing a manually constructed archive with zero profiles would restore an empty database and then cause normal initialization to create a new default profile, meaning the resulting application state would not actually match the archive.

The final validation therefore rejects a profileless whole-app snapshot rather than silently transforming it during restore.

### Database restore

Database restore:

- validates the snapshot before destructive work;
- runs replacement inside a Drift transaction;
- clears dependent rows in foreign-key-safe order;
- recreates questions;
- recreates profiles;
- recreates attempt summaries;
- recreates attempt-answer rows;
- recreates bookmarks;
- relies on database foreign-key enforcement.

### Cross-store controller restore

A whole-app restore also changes settings and active-profile preference, which live outside SQLite. The controller therefore performs a compensating-transaction workflow:

1. decode/validate the new archive;
2. export the current logical database snapshot;
3. load current settings;
4. load current active-profile preference;
5. transactionally restore the new database snapshot;
6. persist restored settings;
7. persist/clear restored active-profile preference;
8. reload controller state;
9. if a later step fails, attempt to restore the previous database/settings/profile preference;
10. reload again after compensation;
11. preserve/rethrow the original restore failure while logging rollback failure separately if compensation also fails.

This reduces partial cross-store state risk without falsely claiming that unrelated platform preference storage can join a SQLite transaction.

### Restore UI

`ImportExportPage` now contains a separate **Local backup** section with:

- Copy local backup;
- paste backup JSON;
- Restore backup;
- destructive replacement confirmation;
- progress-disabled restore button while restore is running;
- success/failure snackbars;
- clipboard read/write failure handling;
- localized backup/restore/privacy copy.

The UI remains explicit that complete local backup is different from question-bank export.

## Important backup bug discovered and fixed during consolidation

A subtle correctness issue was found while auditing the parallel backup implementation.

Schema version 1 stores `attempt_answers` with a primary key of `(attempt_id, question_id)` but **does not store an original answer position/index**. Export reads answer rows in deterministic question-id order so archive output is stable.

`bestStreak`, however, depends on the original play order. Recomputing `bestStreak` from exported rows sorted by question id can produce a different result from the historical quiz.

The first consolidation pass accidentally attempted exactly that recomputation. It was corrected before final PR creation.

The final rule is:

- preserve the stored attempt-level `bestStreak`;
- validate only order-independent invariants that can be proved from counts;
- do not invent historical interaction order that the schema never stored;
- document that exact answer-sequence recovery requires a future schema migration with an explicit order field plus backup-format compatibility work.

A dedicated regression test now protects this behavior.

## Backup automated coverage added

### `test/data/app_database_backup_test.dart`

Covers:

- logical question/profile/attempt/bookmark export;
- reset and transactional restore;
- restored progress aggregation;
- dangling-reference rejection;
- profileless whole-app snapshot rejection;
- impossible streak metadata rejection;
- acceptance of a valid streak that cannot be recomputed from exported answer order;
- non-finite total score rejection.

### `test/data/local_backup_codec_test.dart`

Covers:

- supported format round trip;
- questions/profiles/attempts/bookmarks/settings/active profile;
- unsupported version rejection;
- invalid active-profile reference rejection;
- inconsistent attempt aggregate rejection;
- oversized input rejection.

### `test/application/quizforge_controller_backup_test.dart`

Covers:

- full restore of questions/profiles/bookmarks/progress/settings/active selection;
- malformed archive rejection before current-state mutation;
- simulated settings-write failure after database replacement;
- rollback of database/settings/profile-preference state after that cross-store failure.

### `test/widget/local_backup_page_test.dart`

Covers:

- backup archive preparation through the controller;
- restore field;
- mandatory destructive confirmation;
- successful restore feedback.

## Repository validation tooling added/hardened

### Markdown validator

`tool/check_markdown_links.py` remains the deterministic repository-local documentation link checker.

A missing integration issue was found while wiring the consolidated local/CI sequence: the scripts referenced `tool/test_check_markdown_links.py`, but that regression-test helper did not exist in the PR #10 base.

The missing test helper was ported/added before PR #12 was opened, preventing the consolidated CI graph from knowingly referencing a nonexistent file.

### ARB validator

Added `tool/check_arb_catalogs.py`, implemented with Python standard library only.

It checks:

- valid JSON object root;
- duplicate JSON keys;
- non-empty `@@locale`;
- at least one message;
- string/non-empty message values;
- metadata object shape;
- orphan metadata keys;
- translated-catalog message-key parity with the English template.

Added `tool/test_check_arb_catalogs.py` covering valid catalogs, empty messages, orphan metadata, template-key divergence, and duplicate JSON keys.

`flutter gen-l10n` remains the authoritative Flutter generator compatibility gate after the early structural validator.

## Maintained local quality sequence

`tool/check.sh` and `tool/check.ps1` now run the maintained sequence:

```text
python tool/test_check_markdown_links.py
python tool/test_check_arb_catalogs.py
python tool/check_markdown_links.py
python tool/check_arb_catalogs.py
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

The shell script uses the appropriate `python3` launcher while the PowerShell script uses `python`.

## CI quality gate alignment

`.github/workflows/ci.yml` now performs before Flutter setup:

1. Markdown-validator regression tests;
2. ARB-validator regression tests;
3. repository-local Markdown validation;
4. ARB catalog validation.

Then it:

5. sets up Flutter stable;
6. records toolchain information;
7. resolves dependencies;
8. uploads the generated `pubspec.lock` as short-lived workflow evidence;
9. generates localizations;
10. checks Dart formatting;
11. runs Flutter analyzer;
12. runs tests with coverage.

The workflow retains least-privilege content-read permissions and concurrency cancellation for superseded pull-request runs.

## Tagged release workflow alignment

The tagged release workflow previously reran the Markdown check but could skip the new ARB/tool-test gates. This was corrected.

Before Flutter setup/packaging it now verifies:

- tag/package-version relationship;
- committed non-empty application lockfile;
- Markdown-validator tests;
- ARB-validator tests;
- repository-local Markdown links;
- ARB catalog structure/key consistency.

It then retains:

- Flutter stable setup;
- runner generation for Android/Web;
- `flutter pub get --enforce-lockfile`;
- lockfile non-rewrite check;
- localization generation;
- formatting;
- analysis;
- tests;
- Android release APK build;
- Web release build;
- SHA-256 checksum creation;
- workflow artifact upload;
- GitHub release publication for an explicitly pushed version tag.

Release automation still does not contain signing secrets.

## Documentation completed/synchronized in this consolidation

### `README.md`

Updated to surface:

- complete local backup/restore;
- question-bank export vs whole-app backup distinction;
- backup privacy handling;
- validator/tool test commands;
- current testing scope;
- backup documentation links.

### `PRIVACY.md`

Updated to:

- remove stale wording that described implemented in-app reset as future work;
- document actual profile/activity/full-reset controls;
- document backup scope and privacy sensitivity;
- describe validated restore and rollback;
- clarify logging behavior;
- avoid implying remote transmission for core local data.

### `docs/local-backup.md`

Added as the detailed whole-app backup contract covering:

- scope;
- excluded data;
- format/version identity;
- size boundary;
- validation;
- database transaction;
- cross-store compensation;
- user workflow;
- question-bank export comparison;
- compatibility policy;
- security/privacy guidance;
- schema-v1 missing answer-order limitation;
- release verification requirements.

### `docs/data-lifecycle.md`

Updated from the old future-backup assumption to the actual implemented model:

- question/profile/attempt/bookmark/preference storage;
- data deletion semantics;
- reset semantics;
- complete backup data movement;
- restore transaction/rollback;
- schema-v1 attempt-answer order limitation;
- two distinct portable data scopes.

### `docs/architecture.md`

Updated with:

- `app_database_backup.dart`;
- `local_backup_codec.dart`;
- controller cross-store compensation model;
- backup/restore trust boundary;
- privacy/logging rules;
- schema-v1 answer-order limitation;
- ARB structural validation gate.

### `docs/testing.md`

Updated with:

- validator regression tests;
- full local quality sequence;
- codec/database/controller/widget backup coverage;
- cross-store rollback tests;
- future backup-format test requirements;
- manual backup smoke-test requirements;
- repository validation tooling coverage.

### `docs/development.md`

Updated with:

- maintained quality scripts/commands;
- import/export/backup security rules;
- backup compatibility expectations;
- encoder/decoder size symmetry rule;
- ARB validation command;
- schema-v1 historical-order warning;
- stricter definition of a completed change.

### `docs/setup.md`

Updated with:

- Python 3 repository-tool prerequisite;
- validator tests and validator commands before Flutter work;
- maintained shell/PowerShell scripts;
- whole-app backup versus question-bank export explanation;
- backup privacy guidance.

### `docs/ci.md`

Updated with:

- exact CI validator order;
- ARB checker behavior;
- stacked/consolidated PR evidence rules;
- local reproduction sequence;
- final-head verification policy.

### `docs/release.md`

Updated with:

- repository-validator test gates;
- ARB validation/localization generation gates;
- backup restore smoke-test checklist;
- Web backup/persistence checks;
- backup-format compatibility/versioning rule;
- final-head evidence requirement.

### `docs/verification.md`

Reset to PR #12 as the current candidate and records:

- source/config audit items completed;
- automated gates still requiring final-head success;
- initial PR #12 workflow run ids/statuses;
- execution-environment limitation;
- lockfile blocker;
- database/backup evidence;
- manual accessibility/platform/screenshot blockers;
- strict release decision rule.

### `ROADMAP.md`

Updated to mark implementation milestones complete while leaving real release-verification gates unchecked.

### `CHANGELOG.md`

Updated to record:

- complete local backup;
- restore rollback;
- ARB validation;
- validator tests;
- attempt-order bug fix;
- privacy/documentation fixes;
- source-level security hardening;
- explicit pending verification state.

## Granular consolidation commits

The final branch intentionally uses many focused commits. Important consolidation commits include:

- `df38acf21817dae802412592f6a2659c9234387b` — `feat: add validated local database backups`
- `e75ba281e18cec7ad5fdb0f1fb7e06336ac994e3` — `feat: add versioned local backup codec`
- `014670a5334472b6f8e0e61a9abfcc6028530519` — `feat: integrate transactional local backup restore`
- `e027bc936e7b0f06221303dcb0cc90a866d84093` — `test: cover database backup integrity and restore`
- `5658b746922dd948c78b5d1cad8e0415cbcba48d` — `test: cover local backup codec boundaries`
- `de51e473eec54cf001d60b04e1bc340acb73441d` — `feat: localize local backup and restore controls`
- `863225536399ab4a4c93e804e72a8b3d2a931fcb` — `feat: add local backup restore workspace`
- `f3c5c3d7ec6e2b4a4160a5d389d58bbc453dc381` — `test: cover confirmed local backup restore journey`
- `9011b8b0f7d91f0b36ec8031599b388c42755be4` — `tool: validate localization ARB catalogs`
- `2924746c64149730fa1bd2c453c6babc10ed9fb0` — `test: cover ARB catalog validation tool`
- `a68d3de6ab4afee13fbaa17052d8a36138f85da3` — `tool: run repository validators in local checks`
- `12d3c456fbe4cf7f34eb7710bb11208a5427e4c9` — `tool: validate docs and localization on Windows`
- `9024c2215dbfafae3353598c6a171a142057f8ea` — `ci: validate docs and localization before Flutter setup`
- `7054b51dfad67dacc36e4db4a40a0021af306430` — `docs: document backup privacy and data deletion`
- `c82054b5d4c85e9280047b8db0c3d7d9194bdce4` — `docs: add local backup and restore guide`
- `db1121e9998a18cab1427c55feaa0127cbaedfb5` — `docs: surface backups and repository validators`
- `da4145bd5c2bd5596e5e29999b58d058239c0ef4` — `test: cover controller backup restore rollback`
- `584dc69b3c3a96f7ffd6a34db0faccfeb8d6cfe3` — `test: cover Markdown link validation tool`
- `3729e7993a0df52f3d9e400a34574310b4a5fa88` — `docs: document backup and ARB verification coverage`
- `0b96209d157a94fe363a7fa6fecbaf8b50798ac7` — `fix: validate restored streaks without answer order`
- `7736c7fba385f5c35346e550ddbeea57c07011c5` — `test: preserve valid streak metadata without answer order`
- `655fc58b27d25bdced7eda1fec6984a804e2917b` — `docs: clarify backup attempt ordering semantics`
- `3d704270ff90b6b6882597b15e4528a57d50eced` — `docs: mark backup and localization audit milestones`
- `b4facff0258b075a2290dfb29d7528598acda903` — `docs: record consolidated final audit changes`
- `9505e4a825a5b055e4835e25095a8d86315ddd8e` — `docs: synchronize CI validator sequence`
- `b8c94c4c811948af7f65c7ac22620085508e7d7f` — `docs: synchronize local data lifecycle with backups`
- `812db7fa1ef6f5f63051434e69060b29dcb4a74a` — `docs: document backup architecture boundary`
- `4eb43da23884f1035c700afb920b8463ba452471` — `fix: never export an unrestorable backup archive`
- `e8251da7286c87951ea64993ad54167cd94020fd` — `fix: reject profileless whole-app backups`
- `292961a6cc2cb88463fb92ba74fa7dfbd50305d3` — `test: reject profileless backup snapshots`
- `b38b2edc74da18d10d7c5dcaa000955df4caf9e6` — `docs: synchronize contributor quality workflow`
- `42bfd04db4b1a0f378a44a1e406604fbef40f426` — `docs: add repository validators to setup verification`
- `4941e1550ca9a68e8a223a39dfd8cb74d6435642` — `docs: add localization and backup release gates`
- `6e05fcbd0a7c306f621541df0007cdef37458d8e` — `ci: align tagged releases with repository validators`
- `f23d4de54131ee1391997864f51dacbd4952ed2f` — `docs: reset verification ledger for consolidated PR`
- this commit — consolidated final continuation ledger.

These are in addition to the many earlier PR #9/#10 hardening and recent-history commits already inherited by the branch.

## PR #12 creation and first workflow evidence

PR #12 was opened as:

- title: `release: consolidate final QuizForge audit`
- head: `final/consolidated-release-audit-20260819`
- base: `main`
- source head when opened: `6e05fcbd0a7c306f621541df0007cdef37458d8e`
- commit count reported by GitHub at opening: 192
- changed files reported by GitHub at opening: 86

Immediately after creation the following applicable workflows existed and were all **queued**:

- CI — run `32267984788`;
- Secret Scan — run `32267984765`;
- Platform Build Matrix — run `32267984940`;
- Dependency Review — run `32267984972`;
- Build Gate — run `32267985062`;
- OSV Vulnerability Scan — run `32267985458`.

Those runs were not counted as passing.

The verification-ledger and this handoff commit move PR #12 to newer heads, so the listed runs are historical evidence only. The newest PR #12 head must receive and complete its own applicable checks successfully before release status can advance.

## Execution-environment limitation

During this continuation the repository was edited through the connected GitHub tools.

The available execution container could not resolve/clone `github.com` and did not provide a usable Flutter/Dart SDK. Therefore the following were **not** falsely claimed as locally executed:

- `flutter pub get`;
- `flutter gen-l10n`;
- `dart format`;
- `flutter analyze`;
- `flutter test`;
- Android/Web/desktop/iOS builds;
- Python repository validators against an actual local checkout.

GitHub Actions is the available automated execution environment for this final branch. Final status must be read from the exact final head rather than inferred from source inspection.

## Remaining release blockers

The code/documentation consolidation is intentionally ahead of release verification. The remaining blockers are evidence tasks, not permission to invent more product features.

### Automated final-head blockers

- repository validator regression tests must pass;
- Markdown validation must pass;
- ARB validation must pass;
- Flutter dependency resolution must pass;
- localization generation must pass;
- Dart formatting must pass;
- Flutter analyzer must pass;
- all automated tests must pass;
- Android/Web build gate must pass;
- Linux/Windows/macOS/iOS platform matrix must pass where applicable;
- dependency review must pass;
- OSV scan must pass;
- secret scan must pass.

### Lockfile blocker

The application `pubspec.lock` must be:

1. generated by a supported Flutter environment;
2. reviewed as generated dependency evidence;
3. committed normally;
4. verified with `flutter pub get --enforce-lockfile`;
5. confirmed not rewritten by locked resolution.

Do not hand-author the lockfile.

### Manual/platform blockers

- clean checkout setup verification;
- Android release persistence + complete-backup restore smoke test;
- Web release persistence/reload + complete-backup restore smoke test;
- applicable native desktop smoke verification;
- iOS signing/device validation outside the public repository when distribution requires it;
- keyboard/focus review;
- representative screen-reader review;
- OS + app large-text review;
- reduced-motion review;
- contrast/non-color-only-state review;
- real screenshots from the verified candidate using fictional/demo data;
- final repository/history privacy/secret review.

## Do not do in the next continuation

Unless an actual failing check or verified product defect requires it:

- do not add random unrelated features merely to increase commit count;
- do not replace the hardened settings/profile persistence with a parallel weaker abstraction just because it existed on another branch;
- do not invent a schema-v1 answer order;
- do not mark a queued workflow as passing;
- do not hand-create `pubspec.lock`;
- do not publish or commit real local-backup archives;
- do not commit signing credentials, API keys, tokens, private endpoints, keystores, or provisioning profiles;
- do not tag a verified release until every applicable blocker in `docs/verification.md` is actually cleared.

## Exact next continuation procedure

When continuing from this file:

1. Open PR #12 and identify its newest head SHA.
2. Read **that exact SHA's** CI, Build Gate, Platform Build Matrix, Dependency Review, OSV, and Secret Scan results.
3. If a check fails, inspect the failure, make the smallest correct fix, add/update regression coverage where possible, update this file and the relevant documentation, and let checks rerun on the new head.
4. If all automated checks pass and CI produced a generated `pubspec.lock` artifact while the repository still lacks a reviewed lockfile, review and commit the exact generated lockfile through the branch/PR workflow.
5. Rerun/read final-head verification after the lockfile commit.
6. Complete the manual/platform/accessibility/backup/screenshot checks documented in `docs/verification.md` and `docs/release.md`.
7. Update `docs/verification.md`, `CHANGELOG.md`, and this ledger only with evidence that was actually observed.
8. Tag/release only after all applicable blockers are cleared.

## Final continuation status at this handoff

The repository's major product implementation, Phase 6 hardening, recent local attempt history, complete local backup/restore, repository validators, release-workflow alignment, and deep documentation synchronization are consolidated into PR #12.

The remaining work is primarily **verification of the exact final candidate**, plus any focused fixes revealed by that verification. The project must not yet be described as fully release-verified solely because the source-level audit is complete.

**Made by the Sanskar**

# QuizForge — What Changed / Version 2.7.4 Final Continuation Ledger

Last updated: 2026-08-19 (Asia/Kolkata)

This file is the primary detailed cross-chat handoff for the QuizForge repository. It records what is actually implemented, what was fixed during the final audit, what is documented, what is automated, and what still requires real verification.

Do **not** convert a queued, pending, cancelled, superseded, skipped-but-applicable, unobserved, or planned check into a passing claim.

## Current repository milestone

- Repository: `https://github.com/sanskarIN/quizforge`
- Visibility/source model: public / open source
- License: MIT
- Package/application version currently in source: **`2.7.4+1`**
- Intended public Git tag after verification: **`v2.7.4`**
- Database schema version: `1`
- Local-backup format version: `1`
- Stack: Flutter + Dart + Drift/SQLite
- Intended source targets: Android, iOS, Web, Windows, macOS, Linux
- Required product credit: **Made by the Sanskar**
- Requested maintainer commit email: `sanskarin@outlook.in`
- Final consolidation branch: `final/consolidated-release-audit-20260819`
- Maintained pull request: **PR #12 — `release: prepare QuizForge 2.7.4 final candidate`**
- PR #12 base: `main`
- Original `main` base SHA when the consolidation PR was opened: `d8c27cc81f678b1e49c17670c3d1efeab3d044d3`
- Status: **2.7.4 source/release-candidate hardening is implemented; release verification remains blocked until exact-final-head automated/manual evidence is complete.**

The version declaration is intentional and complete in source metadata. It is not, by itself, evidence that `v2.7.4` is already a verified production release.

## Why PR #12 is the only maintained final path

Three earlier work lines contained useful but overlapping changes:

1. PR #9 — `audit/phase-6-verification-2026-08-19`
   - import/resource validation;
   - localization/accessibility hardening;
   - persistence ordering and rollback behavior;
   - privacy/logging improvements;
   - CI/build/security/release hardening;
   - broad tests and release documentation.
2. PR #10 — `feature/phase-7-attempt-history-2026-08-19`
   - based on the stronger PR #9 line;
   - added bounded, privacy-preserving recent per-profile attempt history;
   - added database/UI/tests/docs for that feature.
3. PR #11 — `audit/phase6-20260819`
   - parallel audit branch;
   - contained useful complete local-backup/restore work;
   - contained ARB validation and repository-tooling additions;
   - also contained overlapping store/controller work that was not blindly preferred over PR #10's stronger persistence behavior.

The final consolidation branch started from PR #10's stronger integrated base and selectively ported/audited the useful unique work from the parallel branch. PRs #9, #10, and #11 were closed as superseded so there is one unambiguous release-candidate path.

## Product functionality present in the 2.7.4 candidate

The maintained branch contains the major QuizForge product surface:

- multiple-choice questions;
- true/false questions;
- multi-select questions;
- short-answer questions;
- exact-set scoring for set-based answers;
- normalized short-answer scoring;
- deterministic seeded quiz selection;
- daily quiz mode;
- random practice;
- timed sprint;
- configurable custom quiz setup;
- category filtering;
- difficulty filtering;
- tag filtering;
- explanations and answer review;
- question bookmarks;
- local profiles;
- profile rename/delete;
- per-profile progress summaries;
- category statistics;
- local leaderboard;
- bounded recent per-profile attempt history;
- question creator with validation/preview;
- JSON question-bank import/export;
- CSV question-bank import/export;
- duplicate-id and normalized-content protection;
- Drift/SQLite local persistence;
- active-profile activity clearing;
- complete local-data reset;
- onboarding;
- adaptive Material 3 application shell;
- light/dark/system themes;
- large-text preference;
- reduced-motion preference;
- screen-reader-oriented semantics/hints;
- safe confirmation before abandoning an in-progress quiz;
- offline-first application architecture;
- disabled-by-default/fail-closed private-room multiplayer boundary;
- project/business/support/funding identity UI;
- About page;
- branding SVG assets;
- deterministic unit/integration/widget tests;
- deterministic benchmark tooling;
- repository-local validation tools;
- CI/build/security/release workflows.

## Persistence-ordering and rollback safety retained

The final controller keeps the stronger persistence-first behavior from the earlier audit line rather than replacing it with overlapping weaker refactors.

### Settings

- Settings persistence happens before visible controller settings are replaced.
- A failed preference write therefore does not falsely show a setting as saved.
- The settings repository uses the versioned `settings.v1` payload.
- Malformed/newer values fall back safely.
- Legacy preference keys remain a migration fallback where documented.
- Reset removes both maintained and legacy preference state as required.

### Active profile switching

- Target profile data is loaded before switching.
- The active-profile preference write succeeds before visible active-profile state is mutated.
- A failed preference write therefore cannot partially switch the visible profile.

### Profile creation

- A newly inserted profile is rolled back if activation persistence fails.
- The application does not intentionally leave a hidden profile row after failed activation.

### Profile deletion

- A replacement active-profile preference is persisted before the previous active profile is removed.
- Failure ordering prevents deletion from leaving an invalid active-profile reference.

### Error propagation

- Rollback-aware operations preserve original stack traces when rethrowing the primary persistence error.
- Post-write leaderboard/statistics refreshes are treated separately from a successful primary durable write so a completed save is not incorrectly reported as unsaved only because a derived read later failed.

### Full reset

- Independent store resets are attempted according to the maintained reset contract.
- In-memory state is reloaded from durable state after partial failure so stale pre-reset data is not left visible.

## Question-bank/import safety retained

The maintained JSON/CSV path includes bounded local processing and domain validation.

### Resource boundaries

- source-size limits;
- question-count limits;
- bounded question ids;
- bounded prompts;
- bounded categories;
- bounded choices;
- bounded correct/accepted answers;
- bounded tags;
- bounded explanations;
- bounded time limits.

### Domain validation

- required ids/prompts/categories;
- correct-answer requirements by question type;
- canonical true/false behavior;
- no custom true/false choices;
- non-empty unique normalized choices;
- non-empty unique normalized accepted answers;
- non-empty unique normalized tags;
- correct answers must belong to available choices where required.

### Parser hardening

- malformed JSON is rejected;
- malformed/unclosed CSV quoting is rejected;
- unexpected quote characters in unquoted fields are rejected;
- trailing characters after a quoted CSV field closes are rejected;
- duplicate ids/content are partitioned before persistence;
- deterministic malformed-input/fuzz-style tests protect parser failure behavior.

## Recent local attempt history retained

The 2.7.4 candidate preserves PR #10's newer recent-history feature.

### `AttemptSummary` projection

The summary intentionally contains only privacy-preserving attempt metadata:

- attempt id;
- started timestamp;
- completed timestamp;
- correct count;
- question count;
- best streak;
- earned score;
- computed accuracy;
- computed duration.

Submitted-answer content is intentionally not exposed in the recent-history summary.

### Database query contract

`loadRecentAttempts(profileId, limit: ...)`:

- scopes reads to one profile;
- defaults to a bounded result;
- accepts only supported limits;
- orders newest first by completion timestamp;
- uses attempt id as deterministic tie-breaker;
- projects the existing attempt table rather than duplicating persistence;
- does not require a schema migration because it is a read-only projection.

### UI behavior

The Statistics recent-history UI:

- caches its asynchronous read future rather than performing a fresh query on every build;
- refreshes after meaningful profile/completed-quiz state changes;
- uses localized date/time formatting;
- renders score/progress/duration/streak/accuracy summaries;
- follows active-profile activity cleanup semantics;
- does not surface submitted-answer payloads.

### Related documentation

- `docs/progress-history.md`
- `docs/progress-history-data-contract.md`
- `docs/attempt-history-verification.md`

## Complete local backup/restore in 2.7.4

The final branch contains a logical, versioned whole-application local backup distinct from shareable JSON/CSV question-bank interchange.

### Backup version 1 scope

A valid archive can contain:

- all local questions;
- choices/correct answers;
- categories/difficulty/tags/explanations/time limits;
- local profiles;
- profile creation timestamps;
- completed attempt summaries;
- submitted-answer sets;
- per-answer correctness and score rows;
- bookmarks;
- appearance/accessibility/application settings;
- active-profile selection;
- archive creation timestamp.

Because it can contain profile names, authored quiz content, and submitted answers, a complete local backup is treated as **private user data**, not as a public question pack.

### Backup format identity

- `format`: `quizforge-local-backup`
- backup `version`: `1`
- JSON archive;
- UTC creation timestamp;
- bounded maximum archive size before decode;
- the encoder enforces the same supported size ceiling so QuizForge does not intentionally create an archive that the same version immediately refuses only because of size.

Application version `2.7.4+1` and backup format version `1` are deliberately independent version contracts.

## Backup validation hardening completed during the final audit

The final backup path goes beyond simple JSON shape validation.

### Minimum directly restorable state

Version 1 describes a complete initialized QuizForge state. It therefore requires:

- at least one valid question;
- at least one valid local profile;
- a non-null active-profile id;
- that active-profile id must reference an archived profile.

Why this matters: if a hand-crafted archive contained no questions/profile/active selection, normal initialization would seed/select state not actually present in the archive. The final validator fails closed rather than silently changing the meaning of the restored snapshot.

### Referential integrity

The snapshot rejects:

- attempts referencing unknown profiles;
- attempt answers referencing unknown questions;
- bookmarks referencing unknown profiles;
- bookmarks referencing unknown questions;
- active-profile ids not present in the archived profiles.

### Duplicate integrity

The snapshot rejects:

- duplicate question ids;
- duplicate normalized question content;
- duplicate profile ids;
- duplicate question answers inside one attempt;
- duplicate bookmark pairs.

Bookmark identity is validated as the exact `(profileId, questionId)` pair. The earlier delimiter-concatenation approach was removed because arbitrary identifier text could create composite-key collisions.

### Attempt bounds

Restored attempt summaries must represent sessions normal QuizForge configuration can create:

- minimum question count: 1;
- maximum question count: 100;
- evaluation count must match stored question count;
- correct count must agree with evaluation correctness;
- counts cannot be negative or impossible.

### Score integrity

- attempt total score must be finite and non-negative;
- per-answer score must be finite and non-negative;
- attempt total must agree with the sum of evaluation scores.

### Submitted-answer tamper resistance

A crafted backup can no longer simply claim that an answer was correct or assign arbitrary score metadata while keeping aggregate counts superficially consistent.

For every archived evaluation whose question exists, the validator re-evaluates the submitted answers using the same normal `QuizEngine` rules used during quiz play. It rejects a backup if:

- stored correctness disagrees with the QuizEngine result;
- stored answer score disagrees with the QuizEngine result.

Focused regression coverage protects this behavior.

## Important schema-v1 answer-order limitation and fix

A subtle bug was found during consolidation.

Schema version 1 stores `attempt_answers` using attempt/question identity but does **not** store original per-answer sequence/position. Export can sort rows deterministically for archive stability, but that order is not necessarily the historical play order.

`bestStreak` depends on historical play order.

Therefore, recomputing `bestStreak` from exported rows sorted by question id is invalid and can reject a legitimate historical attempt.

The final rule is:

- preserve the stored attempt-level `bestStreak`;
- validate only order-independent streak invariants;
- do not invent play order that schema version 1 never stored;
- if future functionality needs exact historical answer sequence, add an explicit order field through a real schema migration and backup-format compatibility design.

A dedicated regression test protects this boundary.

## Restore transaction and cross-store rollback

### SQLite restore

The database snapshot is validated before destructive replacement. Replacement then runs inside a Drift transaction and rebuilds dependent records in foreign-key-safe order.

### Cross-store controller restore

A complete restore changes SQLite state, settings preferences, and active-profile preference state. These independent stores cannot participate in one native SQLite transaction.

The controller therefore performs a compensating workflow:

1. decode/validate the requested backup;
2. snapshot current logical database state;
3. load current settings;
4. load current active-profile preference;
5. transactionally restore the new database snapshot;
6. persist restored settings;
7. persist/clear restored active-profile preference;
8. reload controller state;
9. if a later step fails, attempt to restore the old database/settings/profile preference;
10. reload after compensation;
11. preserve/rethrow the original restore failure while separately recording safe rollback failure metadata if compensation itself fails.

This reduces partial cross-store restore risk without pretending unrelated platform preference stores can join a database transaction.

## Backup UI

`ImportExportPage` includes a separate Local backup section with:

- Copy local backup;
- paste backup JSON;
- Restore backup;
- destructive replacement confirmation;
- restore-in-progress disabling;
- safe success/failure feedback;
- clipboard read/write failure handling;
- localized backup/privacy guidance.

The UI distinguishes whole-app backup from JSON/CSV question-bank sharing.

## Backup test coverage

The maintained source contains focused coverage across multiple layers.

### Data/codec tests

- `test/data/local_backup_codec_test.dart`
- `test/data/local_backup_required_active_profile_test.dart`
- `test/data/app_database_backup_test.dart`
- `test/data/app_database_backup_minimum_state_test.dart`
- `test/data/app_database_backup_answer_integrity_test.dart`
- `test/data/app_database_backup_bookmark_key_test.dart`
- `test/data/app_database_backup_attempt_bounds_test.dart`

These collectively cover format round trips, unsupported versions, active-profile requirements, archive-size boundaries, logical export/reset/restore, dangling references, minimum state, streak semantics, non-finite values, answer-score tampering, exact bookmark-pair identity, and normal session-size bounds.

### Application tests

`test/application/quizforge_controller_backup_test.dart` covers:

- whole-controller restoration;
- malformed archive rejection before mutation;
- simulated failure after database replacement;
- compensating rollback across database/settings/profile-selection state.

### Widget test

`test/widget/local_backup_page_test.dart` covers the destructive-replacement confirmation and successful restore feedback flow.

## Repository validators in the 2.7.4 line

The maintained quality graph now has three deterministic Python-standard-library validator families.

### Markdown validator

`tool/check_markdown_links.py`

Checks repository-local Markdown/image/reference targets while ignoring fenced examples, pure anchors, and external network URLs.

Regression suite:

- `tool/test_check_markdown_links.py`

### ARB localization validator

`tool/check_arb_catalogs.py`

Checks:

- valid JSON object root;
- duplicate JSON keys;
- non-empty locale metadata;
- message value shape;
- empty/non-string messages;
- metadata object shape;
- orphan metadata;
- translated-catalog key parity with the English template.

Regression suite:

- `tool/test_check_arb_catalogs.py`

`flutter gen-l10n` remains the authoritative Flutter generator compatibility gate after this early structural check.

### New 2.7.4 release-metadata validator

`tool/check_release_metadata.py`

Purpose: detect version drift on a pull request before a Git tag exists.

It validates:

- exactly one `MAJOR.MINOR.PATCH+BUILD` package version in `pubspec.yaml`;
- a positive Flutter build number;
- presence of `## [Unreleased]` in `CHANGELOG.md`;
- a dated changelog release entry matching the package public version;
- unique release headings;
- descending release-version ordering;
- historical zero-major release recognition such as `0.1.0`;
- no stale `Pre-1.0 policy` heading when the package major version is stable (`>=1`);
- matching maintained package identity in `docs/versioning.md`;
- matching public tag identity in `docs/versioning.md`.

Regression suite:

- `tool/test_check_release_metadata.py`

The first validator implementation had a release-heading regex edge case that did not fully recognize historical `0.x.y` headings. That was caught during source review, fixed, and protected with an explicit `0.1.0` history fixture before the new gate was treated as maintained.

## Current local quality sequence

Unix-like hosts:

```text
python3 tool/test_check_markdown_links.py
python3 tool/test_check_arb_catalogs.py
python3 tool/test_check_release_metadata.py
python3 tool/check_markdown_links.py
python3 tool/check_arb_catalogs.py
python3 tool/check_release_metadata.py
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

Windows uses the equivalent `python` launcher in `tool/check.ps1`.

## CI quality gate

`.github/workflows/ci.yml` now performs before Flutter setup:

1. Markdown-validator regression tests;
2. ARB-validator regression tests;
3. release-metadata-validator regression tests;
4. repository-local Markdown validation;
5. ARB catalog validation;
6. release metadata validation.

Then it:

7. sets up Flutter stable;
8. records the toolchain;
9. resolves dependencies;
10. uploads the generated `pubspec.lock` as short-lived workflow evidence;
11. generates localizations;
12. checks Dart formatting across `lib`, `test`, and `tool`;
13. runs Flutter analyzer;
14. runs automated tests with coverage.

The workflow retains read-only repository content permissions and concurrency cancellation for superseded pull-request runs.

## Build and platform workflows

### Build Gate

`.github/workflows/build.yml` materializes Android/Web runners in the ephemeral checkout and provides Android/Web build compatibility evidence.

### Platform Build Matrix

`.github/workflows/platform-builds.yml` provides host-appropriate release compile/build gates for Linux, Windows, macOS, and iOS. iOS uses a no-codesign release compile because distribution credentials must not be committed.

A passing build matrix is required evidence but does not replace installer/device interaction/accessibility testing.

### Dependency Review

`.github/workflows/dependency-review.yml` reviews dependency changes on pull requests.

### OSV vulnerability scan

`.github/workflows/osv-scan.yml` scans dependency state on applicable pull request/push/scheduled paths.

### Secret Scan

`.github/workflows/secret-scan.yml` uses full-history Gitleaks scanning in its isolated security job.

## Tagged release workflow for 2.7.4

`.github/workflows/release.yml` is the tag-triggered Android/Web release path.

Before Flutter setup/packaging it now:

- verifies Git tag/public package-version agreement;
- requires a committed non-empty `pubspec.lock`;
- runs Markdown validator tests;
- runs ARB validator tests;
- runs release-metadata validator tests;
- validates repository-local Markdown targets;
- validates ARB catalogs;
- validates package/changelog/versioning release metadata.

It then:

- sets up Flutter stable;
- regenerates Android/Web runners in the ephemeral checkout;
- runs `flutter pub get --enforce-lockfile`;
- verifies dependency resolution did not rewrite `pubspec.lock`;
- generates localizations;
- verifies formatting;
- analyzes;
- tests;
- builds Android release APK;
- builds Web release bundle;
- prepares release artifacts;
- produces SHA-256 checksums;
- uploads workflow artifacts;
- publishes the GitHub release for the explicitly pushed matching tag.

For this candidate, the intended public tag is `v2.7.4`.

## Version 2.7.4 metadata work completed in this continuation

The user explicitly requested this final pass to be made for version **2.7.4**.

The following source/release identity changes are complete:

- `pubspec.yaml` changed from `0.1.0+1` to **`2.7.4+1`**;
- `CHANGELOG.md` now has an explicit dated `2.7.4` release-candidate entry plus a fresh Unreleased section;
- `docs/versioning.md` no longer describes the project as pre-1.0;
- stable 2.x compatibility expectations are documented;
- `docs/versioning.md` records package `2.7.4+1` and tag `v2.7.4`;
- the database schema remains version 1 because application version metadata alone does not alter database layout;
- local-backup format remains version 1 because backup-format identity is independent from application SemVer;
- README displays the 2.7.4 release-candidate identity and explicitly avoids equating version metadata with successful verification;
- `docs/release.md` contains the exact 2.7.4 release procedure;
- `docs/release-notes-2.7.4.md` contains dedicated release notes, compatibility notes, and known blockers;
- `docs/testing.md` documents release-metadata validation;
- `docs/ci.md` documents the three maintained repository-validator families;
- `docs/verification.md` is now the 2.7.4 evidence ledger;
- PR #12 title/body now identify it as the maintained QuizForge 2.7.4 final candidate.

## Notable 2.7.4 continuation commits

The final version/release continuation was intentionally kept as multiple focused commits rather than one opaque rewrite.

- `5a6b733bea985d227209040ff30825be19788929` — `release: set QuizForge version 2.7.4`
- `0b82802a178c9b52faf535eb459f5d3357f03ca3` — `docs: align compatibility policy with version 2.7.4`
- `2a4a54dc138e01c7849597127d4784048962c954` — `docs: cut the 2.7.4 changelog entry`
- `b31cf60cee98378be8ca9d1f5ff1a5d06376aa10` — `tool: validate release metadata consistency`
- `f3543e8cc09d4adc805090783b736f7574289c1d` — `test: cover release metadata validator`
- `7d98b3608e6d933b2a68d3b4dc122fab1e11f609` — `tool: enforce release metadata in shell checks`
- `4721e2a471499b1eb6bb5faa1a05f118085198d6` — `tool: enforce release metadata in PowerShell checks`
- `7a0792b18604408355c9c0a7d11c8e784a424c2e` — `ci: gate release metadata consistency`
- `8e5ecfc2dca8b76c595db669419454f36ac7e80a` — `ci: validate release metadata before packaging`
- `a2e1c3ea57a99e8d7ff36ee9d0c7d7ef01002572` — `fix: validate historical zero-major releases`
- `bc2a7eddfe02ebe5eed9f773d37f3235a6f5020a` — `test: cover zero-major release history validation`
- `393de1ea163df42d92eb0e6d6109d6787a718111` — `docs: present the 2.7.4 release candidate`
- `39221af68920d50330424da5a3f22f0090266ddc` — `docs: document 2.7.4 release metadata checks`
- `697e31b8040acfb3648feb017b7b2eee586854dd` — `docs: align CI guide with 2.7.4 metadata gates`
- `444ecd4b91f63be70571a525a2cb61488b27cc25` — `docs: define the 2.7.4 release procedure`
- `a67b52beb1dd96465bf6122907c999c009fdde49` — `docs: add QuizForge 2.7.4 release notes`
- `b99a6e2dfba792fabd02955128768b509c1702e9` — `docs: reset verification ledger for 2.7.4`

This `what_changed.md` update creates another newer PR head; final verification must therefore always use the newest head rather than any SHA listed above as an old check target.

## Documentation surface maintained

The repository includes and maintains documentation for:

- README/project overview;
- setup;
- development workflow;
- architecture;
- architectural decision records;
- testing strategy;
- CI workflows;
- release process;
- versioning/compatibility;
- 2.7.4 release notes;
- verification evidence;
- maintenance;
- repository settings;
- security tooling;
- threat model;
- privacy;
- data lifecycle;
- accessibility;
- performance;
- benchmarking;
- question-bank format;
- localization;
- branding;
- screenshots/capture policy;
- progress/history behavior;
- progress/history data contract;
- attempt-history verification;
- local backup/restore contract;
- troubleshooting;
- project roadmap;
- changelog;
- contributing/support/code-of-conduct/security policies;
- this continuation ledger.

## Lockfile status — still a real blocker

`pubspec.lock` must not be hand-authored.

The maintained CI quality workflow resolves dependencies and uploads its generated application lockfile as short-lived evidence when it reaches dependency resolution.

During this continuation:

- earlier PR #9 matching-manifest runs were still queued/pending;
- PR #10's final head had no completed pull-request workflow evidence available through the connector;
- earlier PR #12 runs were also queued;
- no completed CI-generated lockfile artifact was found that could be safely reviewed and reused.

The root package version changed from `0.1.0+1` to `2.7.4+1`, while the dependency constraints themselves remained unchanged. Even so, the repository keeps the stronger evidence rule: commit a lockfile only after a supported Flutter resolver actually generates it and the exact generated content is reviewed.

The tag release workflow intentionally fails if:

- `pubspec.lock` is missing;
- it is empty;
- locked resolution cannot use it;
- locked resolution rewrites it.

Therefore the lockfile blocker is deliberately not waived just to make a release appear complete.

## Automated verification still required on the exact final 2.7.4 head

The following must actually complete successfully:

- Markdown-validator regression tests;
- ARB-validator regression tests;
- release-metadata-validator regression tests;
- Markdown local-link validation;
- ARB catalog validation;
- release metadata validation;
- dependency resolution;
- generated/reviewed lockfile evidence;
- localization generation;
- Dart formatting gate;
- Flutter analyzer;
- Flutter tests;
- Android build gate;
- Web build gate;
- Linux platform build;
- Windows platform build;
- macOS platform build;
- iOS no-codesign build;
- Dependency Review;
- OSV vulnerability scan;
- full-history Secret Scan.

A workflow run that remains queued/pending is not a pass.

## Manual/release-host verification still required

Source tests and compile gates cannot establish every real application behavior. Before describing 2.7.4 as fully release-verified, the applicable release candidate still needs:

- clean-checkout setup using `docs/setup.md`;
- reproducible platform-runner generation;
- Android release-build database creation/persistence check;
- Web built-artifact database creation and refresh/reload persistence check;
- complete local-backup export → mutate/reset → restore smoke check on Android using fictional data;
- complete local-backup restore and reload persistence smoke check on Web using fictional data;
- at least one applicable native-desktop backup/restore smoke check when desktop is part of the release scope;
- malformed backup failure UX review;
- destructive replacement confirmation review;
- keyboard navigation review;
- visible focus review;
- representative screen-reader review;
- large-text behavior with app and OS scaling;
- reduced-motion review;
- light/dark contrast review;
- non-color-only correctness/status review;
- real screenshots captured from actual verified candidate builds using fictional/demo data;
- release-critical external-link spot checks;
- final exact-head history/secret review;
- distribution signing/provisioning where a store/channel requires it.

## Evidence limitations of the repository-editing environment

The environment used for this audit can modify/read GitHub repository content through the connected GitHub tooling, but its local execution container does not provide the project Flutter/Dart toolchain and cannot be used as a truthful substitute for a supported Flutter checkout/build host.

Therefore this ledger intentionally does not claim execution of:

- `flutter pub get`;
- `flutter gen-l10n`;
- `dart format` against the real checkout;
- `flutter analyze`;
- `flutter test`;
- Android/Web/desktop/iOS builds.

The new release-metadata regex behavior was independently sanity-checked for current `2.7.4+1` parsing and historical `0.1.0` changelog recognition, but the authoritative repository-validator execution remains CI or another real checkout.

This limitation does not weaken the release gate. It is recorded so future work knows exactly which evidence is source-level and which evidence still needs execution.

## Current release decision

The project has a complete, intentionally versioned **QuizForge 2.7.4+1 release candidate** in the maintained branch and PR #12.

Do **not** yet claim:

- all GitHub Actions checks are green;
- a reviewed lockfile is committed;
- every platform has been release built;
- backup/restore has been manually smoke-verified on every release target;
- accessibility manual review is complete;
- screenshots are verified release screenshots;
- `v2.7.4` is already a verified production release.

Those claims become valid only after the corresponding evidence actually exists on the exact final release head.

## Next continuation rule

If work continues after this file:

1. inspect PR #12's newest head SHA;
2. read workflow runs for that exact SHA;
3. fix real source/test/config failures with focused commits and regression coverage;
4. do not change code merely because a run is queued;
5. if CI reaches dependency resolution, review its generated `pubspec.lock` artifact and commit that exact resolver output when valid;
6. after any commit, treat prior check results as historical and read checks again for the new head;
7. when all automated and required manual gates are genuinely complete, update `docs/verification.md`, `docs/release-notes-2.7.4.md`, and this file with exact evidence;
8. only then create/promote `v2.7.4` according to `docs/release.md`.

The remaining work is therefore primarily **exact-final-head verification and evidence collection**, plus focused fixes for any failures that verification reveals.

**Made by the Sanskar**

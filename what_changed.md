# QuizForge — What Changed / Version 2.7.4 Cross-Platform Final Continuation Ledger

Last updated: 2026-08-20 (Asia/Kolkata)

This file is the primary detailed cross-chat handoff for the QuizForge repository. It records the maintained release path, implemented product/data hardening, version 2.7.4 work, six-platform support work, observed GitHub Actions evidence, and the remaining release blockers.

Do **not** convert a queued, pending, cancelled, superseded, skipped-but-applicable, unobserved, or merely planned check into a passing claim.

## Current repository milestone

- Repository: `https://github.com/sanskarIN/quizforge`
- Visibility/source model: public / open source
- License: MIT
- Package/application version: **`2.7.4+1`**
- In-app/About public version: **`2.7.4`**
- Intended public Git tag after verification: **`v2.7.4`**
- Database schema version: `1`
- Local-backup format version: `1`
- Stack: Flutter + Dart + Drift/SQLite
- Supported source targets: **Android, iOS, Web, Windows, macOS, Linux**
- Required product credit: **Made by the Sanskar**
- Requested maintainer commit email: `sanskarin@outlook.in`
- Final consolidation branch: `final/consolidated-release-audit-20260819`
- Maintained pull request: **PR #12 — `release: prepare QuizForge 2.7.4 final candidate`**
- PR #12 base: `main`
- Original `main` base SHA: `d8c27cc81f678b1e49c17670c3d1efeab3d044d3`
- Earlier fully observed six-platform build-evidence head: `306bee785cbebbf5b5d6bea875f8d5b4988ea175`
- Status: **six-platform implementation/release engineering is present, but exact-final-head verification and manual release-host evidence remain incomplete.**

The version declaration and supported-target declaration are source/release contracts. Neither is, by itself, evidence that the exact current head is already a production-verified release.

## Maintained branch/PR consolidation

The repository previously had three overlapping lines of work:

1. PR #9 — `audit/phase-6-verification-2026-08-19`
   - import/resource validation;
   - persistence ordering/rollback;
   - localization/accessibility hardening;
   - privacy/logging improvements;
   - CI/build/security/release hardening;
   - broad test/documentation expansion.
2. PR #10 — `feature/phase-7-attempt-history-2026-08-19`
   - based on the stronger PR #9 line;
   - added bounded per-profile recent attempt history and its database/UI/tests/docs.
3. PR #11 — `audit/phase6-20260819`
   - parallel audit work;
   - contained useful whole-app local backup/restore, ARB validation, tooling/tests/docs;
   - also contained overlapping store/controller refactors that were not blindly preferred over the already-hardened PR #10 implementation.

PR #12 deliberately started from the stronger integrated PR #10 line and selectively ported/audited unique useful PR #11 work. PRs #9, #10, and #11 were closed as superseded. PR #12 is the only maintained final candidate path.

## Core QuizForge functionality retained in 2.7.4

The maintained branch includes:

- multiple-choice questions;
- true/false questions;
- multi-select questions;
- short-answer questions;
- deterministic exact-set and normalized short-answer scoring;
- deterministic seeded selection;
- daily quiz;
- random practice;
- timed sprint;
- configurable custom quizzes;
- category/difficulty/tag filtering;
- explanations and review;
- bookmarks;
- local profiles with rename/delete;
- per-profile progress;
- category statistics;
- local leaderboard;
- bounded recent per-profile attempt history;
- question creator with validation/preview;
- JSON/CSV question-bank import/export;
- duplicate-id and normalized-content handling;
- Drift/SQLite persistence;
- local activity clearing and complete local-data reset;
- onboarding;
- adaptive Material 3 presentation;
- light/dark/system themes;
- large-text and reduced-motion preferences;
- accessibility semantics/hints;
- safe confirmation before abandoning an active quiz;
- offline-first architecture;
- disabled-by-default/fail-closed private-room transport boundary;
- project/contact/support/funding/About UI;
- deterministic tests/benchmarking;
- repository-local validators;
- CI/build/security/release automation.

## Persistence-ordering and rollback hardening retained

The final controller keeps persistence-first behavior from the stronger audit line.

### Settings

- settings are persisted before visible in-memory settings are replaced;
- failed preference persistence does not falsely display unsaved settings as committed;
- versioned `settings.v1` payload is maintained;
- malformed/newer values fall back safely;
- legacy key cleanup/migration fallback remains documented/tested.

### Active profile

- target profile data is loaded before visible switching;
- active-profile preference persistence succeeds before visible controller mutation;
- failed preference persistence does not partially switch the visible profile.

### Profile creation/deletion

- failed activation after profile insertion rolls the new profile back;
- active-profile deletion persists a replacement selection before deleting the old row;
- rollback-aware paths preserve the original error stack trace.

### Reset/read refresh behavior

- partial reset failures reload durable state instead of leaving stale pre-reset memory;
- a successful primary durable write is not incorrectly reported as failed only because a later derived statistics/leaderboard refresh fails.

## Question-bank import safety retained

The JSON/CSV path enforces:

- source-size bounds;
- question-count bounds;
- bounded ids/prompts/categories/choices/answers/tags/explanations/timers;
- required domain fields;
- canonical true/false rules;
- unique normalized choices/answers/tags;
- correct-answer membership where applicable;
- duplicate id/content partitioning before persistence;
- malformed JSON rejection;
- strict CSV quote handling;
- rejection of unexpected quote characters in unquoted fields;
- rejection of trailing characters after closed quoted fields;
- deterministic malformed-input/fuzz-style tests.

## Recent attempt history retained

`AttemptSummary` exposes privacy-preserving summary metadata only:

- attempt id;
- started/completed timestamps;
- correct/question counts;
- best streak;
- earned score;
- derived accuracy;
- derived duration.

Submitted-answer content is intentionally excluded from the summary UI.

`loadRecentAttempts(profileId, limit: ...)` is profile-scoped, bounded, newest-first, uses attempt id as deterministic tie-breaker, and projects the existing attempt table without a schema migration.

The Statistics page caches its async read future, refreshes on meaningful profile/quiz changes, uses localized date/time rendering, and follows profile activity cleanup semantics.

## Complete local backup/restore retained and hardened

Backup format identity:

- `format`: `quizforge-local-backup`
- backup version: `1`
- JSON archive;
- UTC archive timestamp;
- bounded archive size;
- encoder and decoder use a symmetric supported size boundary.

Backup version 1 can contain:

- questions and answer metadata;
- categories/difficulty/tags/explanations/timers;
- profiles;
- attempts and submitted-answer evaluations;
- bookmarks;
- settings;
- active-profile selection.

A complete backup is therefore private user data and must not be treated as a public question pack.

### Minimum directly restorable state

A version-1 whole-app backup requires:

- at least one valid question;
- at least one valid profile;
- a non-null active profile;
- active profile membership in the archived profiles.

This prevents restore followed by implicit initialization from silently creating state that was not actually present in the archive.

### Referential/duplicate integrity

Validation rejects:

- unknown attempt profile references;
- unknown attempt question references;
- unknown bookmark profile/question references;
- invalid active-profile references;
- duplicate question ids;
- duplicate normalized question content;
- duplicate profile ids;
- duplicate question answers within an attempt;
- duplicate bookmarks.

Bookmark identity is exact `(profileId, questionId)` tuple identity rather than delimiter-concatenated text, avoiding arbitrary-id collision ambiguity.

### Attempt/score integrity

- restored attempts must contain 1–100 questions;
- evaluation count must match question count;
- correct count must agree with evaluation flags;
- scores must be finite/non-negative;
- attempt total must agree with evaluation score totals;
- each archived submitted answer is re-evaluated with normal `QuizEngine` logic;
- stored correctness/score must agree with that evaluation.

### Schema-v1 answer-order limitation

Schema version 1 does not store original per-answer position in `attempt_answers`. Database export may deterministically order rows for stable archives, but that is not historical play order.

Because `bestStreak` depends on play order, the validator must not recompute it from question-id-sorted export rows. The maintained behavior:

- preserves stored attempt-level `bestStreak`;
- checks order-independent streak invariants only;
- does not invent historical order;
- requires a future schema migration + backup compatibility design if exact historical answer order becomes a product requirement.

### Restore transaction model

SQLite replacement is validated before destructive work and performed transactionally.

Whole-app restore also touches settings and active-profile preference stores, so the controller uses a compensating workflow:

1. decode/validate requested archive;
2. snapshot current database/settings/active-profile preference;
3. restore database transactionally;
4. persist restored settings;
5. persist/clear restored active-profile preference;
6. reload controller state;
7. if a later step fails, attempt compensation to the old database/settings/profile selection;
8. reload after compensation;
9. rethrow the original restore failure while logging rollback failure separately if compensation fails.

## Version 2.7.4 identity hardening

This continuation moved the candidate from the stale `0.1.0+1` identity to **`2.7.4+1`** and then audited every user/release-facing version surface.

Completed:

- `pubspec.yaml` → `2.7.4+1`;
- `AppConstants.version` → `2.7.4`;
- About-page test → `Installed version: 2.7.4`;
- dated 2.7.4 changelog entry;
- stable post-1.0/2.x versioning policy;
- maintained package/tag identity in `docs/versioning.md`;
- dedicated `docs/release-notes-2.7.4.md`;
- 2.7.4-specific setup/testing/CI/release/support/repository policy docs;
- bug-report example updated from `v0.1.0` to `v2.7.4`;
- PR #12 retitled/reframed as the 2.7.4 candidate.

## Release-metadata validator

Added `tool/check_release_metadata.py` plus `tool/test_check_release_metadata.py`.

The validator checks:

- one canonical `MAJOR.MINOR.PATCH+BUILD` package version;
- positive build number;
- no leading-zero SemVer components;
- one semantic in-app `AppConstants.version`;
- exact in-app/public package-version equality;
- presence of Unreleased changelog section;
- matching dated release entry;
- real calendar dates;
- unique release headings;
- descending release order;
- historical zero-major releases such as `0.1.0`;
- no stale pre-1.0 policy on a stable-major package;
- package/tag identity in versioning documentation.

A first regex edge case that did not fully recognize historical `0.x.y` releases was found during source review, fixed, and protected by regression coverage before treating the tool as maintained.

## Markdown validator CI defect discovered from real Actions evidence

The earlier exact head `306bee785cbebbf5b5d6bea875f8d5b4988ea175` produced a real main-CI failure in run `32273890486`.

Failure location: `Test repository validation tooling` before Flutter setup.

All Markdown checker tests errored because `tool/test_check_markdown_links.py` expected a public regression contract that the implementation did not expose:

- `extract_targets(markdown)`;
- `validate_file(source, root)`;
- `BrokenLink.reason`.

The repository-escape regression also established that `../outside.md` needed explicit rejection rather than merely resolving a path and checking existence.

Fixed in commit:

- `8120a2605671894dbc99e2a502f472c0eb8f3cb4` — `fix: align Markdown validator with regression contract`

The maintained checker now:

- exposes the tested APIs;
- reports deterministic reasons;
- ignores fenced examples;
- validates local targets;
- rejects targets escaping the repository root.

This was a real source/tooling defect, not classified as runner noise.

## Cross-platform continuation — 2026-08-20

The user requested that QuizForge become fully cross-platform supportable rather than only being described as cross-platform by design.

The maintained target set is:

1. Android
2. iOS
3. Web
4. Windows
5. macOS
6. Linux

### Shared-code audit

Repository code search did not find core application dependencies on `dart:io`, `Platform.*`, or `kIsWeb` branches. Core quiz/domain/controller behavior therefore remains shared instead of becoming six separate application implementations.

### Plugin/infrastructure boundary

Cross-platform behavior uses Flutter-compatible infrastructure:

- Drift/SQLite database;
- Shared Preferences for small local preferences;
- Flutter clipboard APIs for current import/export/backup UI;
- URL launcher for support/project links.

### Standard platform runners

Platform runner shells remain reproducible with:

```text
flutter create . --platforms=android,ios,web,windows,macos,linux
```

They are intentionally not hand-maintained as six divergent application forks.

## Web persistence defect discovered and fixed

The previous `AppDatabase.defaults()` used only:

```text
driftDatabase(name: 'quizforge')
```

That can compile as shared Flutter code, but the Web backend needs explicit Drift Web runtime configuration plus compatible SQLite WASM/worker files for persistent database startup.

Fixed in:

- `ea8b5652e9146fb91966de5bb690dd20653b571d` — `fix: configure Drift persistence for Flutter Web`

The default database connection now supplies:

```text
DriftWebOptions(
  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
  driftWorker: Uri.parse('drift_worker.js'),
)
```

Native Android/iOS/Windows/macOS/Linux behavior continues through the normal `drift_flutter` native path.

## Drift Web runtime preparation

Added:

- `tool/prepare_web_assets.py`
- `tool/test_prepare_web_assets.py`

The tool is pinned to Drift `2.34.3` and prepares:

- `sqlite3.wasm`;
- `drift_worker.js`.

The tool:

- is idempotent for already-valid files;
- validates WebAssembly magic bytes;
- enforces bounded WASM/worker sizes;
- validates worker UTF-8;
- rejects HTML error pages masquerading as JavaScript;
- writes files atomically;
- supports `--check` for offline verification of existing assets.

A first worker check looked for the literal text `drift`, which could incorrectly reject a minified official worker. That source-review issue was fixed in:

- `7ac68d4246a84d3abd4509bb76f5ef6649b2e349` — `fix: avoid minifier-sensitive worker validation`
- `6cdc4e835454b88c6989f9364b9fb67ce8ee0aff` — regression test alignment for minified workers/HTML rejection.

## Android/Web build gate strengthened

`.github/workflows/build.yml` now:

1. tests Web runtime asset tooling;
2. sets up Flutter;
3. generates Android/Web runners;
4. prepares Drift Web runtime assets;
5. resolves dependencies;
6. generates localizations;
7. builds Android **release APK**;
8. builds Web release bundle;
9. validates `sqlite3.wasm` and `drift_worker.js` inside `build/web`.

This prevents a Web build from being treated as runtime-persistence-ready merely because Dart compilation succeeded.

Key commit:

- `d01d3c01c100ccbec64abe2d61614ab48464b7dd` — `ci: verify Android and Web release runtime support`

## Main CI/local tooling alignment

Main CI now runs `tool/test_prepare_web_assets.py` with the other deterministic repository-tool tests before Flutter setup.

The general source-quality job does not download the runtime files; network-dependent preparation stays in Web build/release jobs.

Local scripts were aligned:

- `tool/check.sh`
- `tool/check.ps1`

These test the Web asset validator alongside Markdown/ARB/release metadata tooling.

## Six-platform PR build evidence

On earlier exact head `306bee785cbebbf5b5d6bea875f8d5b4988ea175`, GitHub Actions completed with:

- Build Gate `32273890444` — **SUCCESS**;
- Platform Build Matrix `32273890427` — **SUCCESS**;
- Dependency Review `32273890437` — **SUCCESS**;
- OSV Vulnerability Scan `32273890873` — **SUCCESS**;
- Secret Scan `32273890415` — **SUCCESS**;
- CI `32273890486` — **FAILURE** for the Markdown checker contract issue described above.

The successful Platform Build Matrix means that head successfully built/compiled:

- Linux release;
- Windows release;
- macOS release;
- iOS release with `--no-codesign`.

The successful Build Gate established Android/Web build evidence for that head.

These successes are valuable historical proof that the source line compiled across all six targets. They are **not** transferred to the newer Web-runtime/cross-platform-release head; affected jobs must pass again.

## Gated six-platform tag release pipeline

The old tag workflow only packaged Android/Web.

It has been replaced with a gated multi-job cross-platform pipeline.

### Verify job

Before platform packaging:

- tag/public package version agreement;
- committed non-empty lockfile;
- all repository/tool regression tests;
- Markdown/ARB/release metadata validators;
- `flutter pub get --enforce-lockfile`;
- lockfile no-rewrite check;
- localization generation;
- formatting;
- Flutter analysis;
- tests with coverage.

### Platform jobs

After verification succeeds:

- Android: APK + AAB;
- Web: release bundle + packaged Drift WASM/worker verification;
- Linux: x64 release bundle;
- Windows: x64 release bundle;
- macOS: release output;
- iOS: release compile with `--no-codesign`, packaged explicitly as unsigned compile evidence.

Each host job again uses locked dependency resolution and checks the lockfile is unchanged.

### Publication job

Publication depends on every platform job.

It:

- downloads all immutable workflow artifacts;
- verifies multiple artifacts exist;
- creates SHA-256 checksums;
- creates the GitHub release only after all platform jobs succeed.

Only this final job has `contents: write`; build/verification jobs use read-only repository permission.

This prevents automatic publication of a knowingly partial six-platform tag when a maintained target fails packaging.

## Six-platform documentation added/synchronized

Added:

- `docs/platform-support.md`

Synchronized:

- `README.md`
- `docs/setup.md`
- `docs/testing.md`
- `docs/ci.md`
- `docs/release.md`
- `docs/architecture.md`
- `docs/release-notes-2.7.4.md`
- `docs/verification.md`
- `CHANGELOG.md`
- this ledger.

The docs now explicitly distinguish:

- supported source target;
- compile/build evidence;
- runtime persistence verification;
- distribution signing/provisioning;
- production-release verification.

## Current six-platform release boundaries

### Android

Implemented/buildable through Flutter and dedicated release APK build gate. Final release still needs real-device persistence/backup and signing/store evidence where distributed.

### iOS

Implemented/compileable through Flutter on macOS. CI uses `--no-codesign`. A packaged unsigned `.app` is compile evidence only; signed device/App Store distribution requires private provisioning outside the public repository.

### Web

Implemented with explicit Drift Web configuration and pinned WASM/worker preparation. Build output now checks those runtime files. Final release still needs real-browser database creation/write/read, refresh/reload persistence, correct `.wasm` MIME serving, clipboard flows, and backup restore.

### Windows

Implemented/buildable through Flutter Windows release workflow. Final release still needs representative local persistence/interaction smoke testing and any desired installer/signing work.

### macOS

Implemented/buildable through Flutter macOS release workflow. Final distribution still needs representative persistence/interaction checks plus signing/notarization where required.

### Linux

Implemented/buildable through Flutter Linux release workflow. Final distribution still needs representative persistence/interaction testing and packaging validation for intended distribution format.

## Application lockfile remains a deliberate release blocker

`pubspec.lock` is not hand-authored.

The maintained PR CI resolves dependencies and uploads the generated lockfile as short-lived evidence when it reaches that step. The exact generated contents should be reviewed and committed before tagging.

The tag workflow refuses to package a release without a committed lockfile and enforces it in both shared verification and platform packaging jobs.

Do not weaken this rule simply to make the release appear complete.

## Manual/release-host evidence still required

Before calling 2.7.4 fully release-verified:

- clean checkout setup;
- exact-final-head repository validators;
- exact-final-head Flutter dependency/localization/format/analyzer/tests;
- exact-final-head Android/Web build gate;
- exact-final-head Linux/Windows/macOS/iOS matrix;
- exact-final-head Dependency Review/OSV/Secret Scan;
- generated/reviewed/committed lockfile;
- Android database persistence + backup restore smoke test;
- Web WASM/worker loading + database persistence + refresh/reload + backup restore smoke test;
- representative Windows/Linux/macOS local persistence/core-flow smoke tests;
- signed iOS device validation if iOS is distributed;
- keyboard/focus review on desktop/Web;
- screen-reader review;
- large-text review;
- reduced-motion review;
- contrast/non-color cue review;
- verified screenshots from actual built candidates using fictional/demo data;
- distribution signing/notarization/provisioning where applicable.

## Repository-editing environment limitation

The connected editing environment can inspect and modify GitHub source/configuration but does not provide the authoritative local Flutter/Dart build toolchain for six-platform execution.

Therefore no local Flutter build/test claim is invented. GitHub Actions exact-head results and real platform smoke tests remain the evidence source.

## Important cross-platform continuation commits

- `8120a2605671894dbc99e2a502f472c0eb8f3cb4` — fix Markdown validator CI contract and repository escape handling
- `b50f4be1c40f2d86a39e8845f47d8272bdd3a6ff` — add deterministic Drift Web asset preparation
- `b625a2115fabe36ad3fdc2e7ff44807a1ce5fa40` — add Web asset regression tests
- `ea8b5652e9146fb91966de5bb690dd20653b571d` — configure Drift persistence for Flutter Web
- `d01d3c01c100ccbec64abe2d61614ab48464b7dd` — verify Android release/Web runtime support in build CI
- `e41978455abcf69d2a310b08932aa310b466a26b` — test Web runtime tooling in main CI
- `6d5a1a26cb4bb376ba057499df5a3502dd991a33` — add Web runtime assets to tagged release path
- `7a8ac34ec491e1596800bbf3524edf823bbb9030` — align Unix local checks
- `a1e6ce4ddd7cb2e0e8029b46bbed566adf2fb45f` — align PowerShell local checks
- `f6e4ac3b79b727235f987db7310f5f2cdf1903a3` — add six-platform support contract
- `7ac68d4246a84d3abd4509bb76f5ef6649b2e349` — make worker validation minifier-safe
- `6cdc4e835454b88c6989f9364b9fb67ce8ee0aff` — align Web worker regression tests
- `ff298d4ce388ca3f7ed504c1dfb6b630bea8c7c0` — document Web persistence setup
- `2dc4aa9d52eeae8b7ef02f54a5c052a2603dfce1` — document cross-platform runtime/build testing
- `7b512b057c6cf38354b467a00ba96b697df215c7` — publish gated cross-platform release artifacts
- `344e8c540385af41cd285ba750834be430ffadb1` — document cross-platform CI/release packaging
- `24fa14843162617f014221160670b77533b478de` — define gated six-platform release process
- `e2658467a2d3f48d2679ac7cb05c233ecb41d2a1` — present QuizForge as six-platform application in README
- `3126a5bd6a86fc94892847d61909a158480a137a` — record six-platform 2.7.4 hardening in changelog
- `6e12419de9cad0938229fa320ab0157723aa1e4b` — expand 2.7.4 release notes for six-platform support
- `675858cdf7e6edc1fa96771c2f734bc58907f913` — record six-platform verification evidence
- `a885353861b8b09e41a2ceb76198bf1179d73c30` — document cross-platform persistence architecture

The commit that writes this ledger creates a newer exact PR head. Use the PR's current head SHA after this commit for all final workflow decisions.

## Current release decision

QuizForge 2.7.4 is now a **six-platform implementation/release candidate** in the maintained branch:

- Android
- iOS
- Web
- Windows
- macOS
- Linux

Do **not** yet claim that the exact current head is fully production/release verified on all six platforms. The remaining work is evidence collection and focused repair of any failures revealed by exact-head automation/manual platform tests.

Do not create/promote `v2.7.4` until the applicable blockers in `docs/verification.md` are cleared.

## Next continuation rule

If work continues after this file:

1. fetch PR #12's newest head SHA;
2. fetch workflow runs for that exact SHA;
3. inspect any completed failure at job/log level;
4. make focused fixes only for real failures;
5. after a source commit, discard older check states as final evidence and read the new exact head again;
6. when CI generates `pubspec.lock`, review and commit the exact generated resolver output instead of hand-authoring it;
7. perform the required real-platform persistence/backup/accessibility/screenshot checks;
8. update `docs/verification.md`, release notes, and this ledger with exact evidence;
9. only then create/promote `v2.7.4` through the gated six-platform release workflow.

**Made by the Sanskar**

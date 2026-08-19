# QuizForge — What Changed / Continuation Ledger

Last updated: 2026-08-19 (Asia/Kolkata)

This is the primary handoff file for continuing QuizForge in another chat/session. It records what was implemented, what was actually verified, what is still blocked, and the exact next work. Do not turn a pending check into a passing claim.

## Current milestone

- Package version: `0.1.0+1`
- Repository: `https://github.com/sanskarIN/quizforge`
- Active audit branch: `audit/phase-6-verification-2026-08-19`
- Active pull request: `#9` — `ci: verify Phase 6 release-candidate baseline`
- Audit base: `main` at `d8c27cc81f678b1e49c17670c3d1efeab3d044d3`
- Visibility/source model: public / open source
- License: MIT
- Primary stack: Flutter + Dart + Drift/SQLite
- Intended targets: Android, iOS-ready, Web, Windows, macOS, Linux
- Required product credit: **Made by the Sanskar**
- Current status: Phases 0–5 are substantially implemented. Phase 6 source/configuration hardening is well advanced, but final release-candidate verification is **blocked/pending** on final-head CI/build/security evidence, a reviewed Flutter-generated `pubspec.lock`, platform/database build checks, manual accessibility review, and real screenshots.

## Git commit identity

The requested commit email is `sanskarin@outlook.in`.

The raw Git commit metadata inspected during this audit shows connector-created commits using the requested email even though some higher-level GitHub wrapper responses omit the email field. A temporary workflow created for lockfile generation also explicitly configured:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

That temporary workflow was later removed because it had not executed and there was no reason to leave extra `contents: write` automation in the repository.

## Repository/PR continuity work

- Inspected the existing repository instead of replacing working history.
- Created the dedicated Phase 6 branch `audit/phase-6-verification-2026-08-19` from the latest inspected `main` state.
- Opened PR #9 to keep verification work reviewable and avoid directly rewriting `main`.
- Closed older PRs #6, #7, and #8 as superseded so only the current audit path remains active.
- Preserved granular atomic commits rather than collapsing unrelated fixes into one change.
- Added `docs/verification.md` as the evidence ledger for Phase 6.

## Product work already present and retained

QuizForge already includes the major master-prompt product requirements and they were preserved while auditing:

- multiple-choice, true/false, multi-select, and short-answer questions;
- categories, difficulty, tags, timed/untimed quiz configuration;
- daily quiz, random practice, timed sprint, and custom quiz builder;
- deterministic selection/scoring fixtures;
- explanations, review mode, streaks, bookmarks;
- offline profiles, progress statistics, category statistics, and local leaderboard;
- JSON/CSV question-bank import/export;
- quiz creator with validation and preview;
- duplicate id/content protection;
- Drift/SQLite persistence;
- local data/activity reset controls;
- adaptive Material 3 UI;
- light/dark/system themes;
- large-text/reduced-motion/screen-reader-oriented settings;
- offline-first architecture and a disabled-by-default private-room transport boundary;
- onboarding, About, support/funding/project identity UI;
- editable branding SVG;
- deterministic test fixtures and benchmark harness.

## Phase 6 localization and UI hardening completed

### Localization architecture

- Kept `flutter_localizations` + generated localization architecture.
- Kept `intl: any` so the Flutter SDK selects the compatible `intl` version instead of using an arbitrary conflicting manual version.
- Fixed localization message identifiers that conflicted with Dart language keywords.
- Expanded `lib/l10n/app_en.arb` for primary product workflows.
- Localized import/export labels and reports.
- Localized question creator labels, difficulty values, validation state, and preview text.
- Localized question-bank search/filter metadata.
- Localized quiz setup difficulty controls.
- Localized quiz progress/timer semantics and true/false choices.
- Localized answer review, score/correctness labels, and bookmark tooltips.
- Localized statistics/category progress/leaderboard labels.
- Localized settings, privacy/data, profile management, About, support, and update sections.
- Kept user-authored/imported question content as domain data rather than pretending it is translated UI copy.

### Accessibility fixes

- Fixed large-text handling so enabling QuizForge large text never reduces a larger OS/system text scale.
- Preserved OS `disableAnimations` while also honoring QuizForge reduced-motion settings.
- Added/maintained semantic quiz progress and timer labels.
- Explicitly enabled semantics in accessibility widget tests.
- Preserved non-color-only correct/incorrect status cues.
- Updated review UI to listen to controller state so bookmark icons refresh immediately after changes.

### Error/privacy handling

- Startup UI no longer displays arbitrary raw initialization details.
- Creator/import/settings persistence errors use user-safe localized messages.
- Logging paths report stable event names and safe metadata such as runtime error type instead of serializing raw imported/user content.
- Structured logger remains the supported path rather than ad-hoc `print` calls.

## Phase 6 reliability/security hardening completed

### Settings persistence ordering

Fixed `QuizForgeController.updateSettings` so settings are persisted first and are only assigned to in-memory controller state after persistence succeeds. This avoids UI/controller state claiming a setting was saved when the local preference write failed.

### Import resource bounds

`QuestionBankCodec` now defines explicit in-process safety limits:

- maximum import source size: `5 * 1024 * 1024` characters;
- maximum questions per imported bank: `10000`.

Both JSON and CSV paths reject oversized payloads before expensive item-level parsing. JSON rejects excessive question arrays before item parsing. CSV stops when the row limit is exceeded.

### Question content bounds and canonical validation

`Question.validate()` now bounds and validates untrusted/authored content:

- id: max 120 characters;
- prompt: max 2000 characters;
- category: max 120 characters;
- choices: max 20;
- each choice: max 500 characters;
- accepted/correct answers: max 20;
- each answer: max 500 characters;
- tags: max 20;
- each tag: max 80 characters;
- explanation: max 5000 characters;
- timer: max 3600 seconds.

Additional canonical validation now rejects blank accepted answers, accepted answers duplicated after normalization, blank tags, tags duplicated after normalization, and custom choices on true/false questions.

The fictional starter question bank was inspected and does not define custom true/false choices, so this stricter rule does not conflict with the existing starter fixtures.

## Automated test work added or corrected

### Domain tests

Coverage includes question validation, normalized-answer behavior, normalized fingerprint duplicate behavior, multiple-choice scoring, exact-set multi-select scoring, canonical true/false scoring, short-answer accepted variants, deterministic selection/filtering, result percentage/duration/streak behavior, private-room transport fail-closed behavior, blank/normalized-duplicate accepted answers, normalized-duplicate tags, true/false custom-choice rejection, and content/time-bound validation.

### Import/export tests

Coverage includes JSON round trip, CSV round trip, commas/quotes in CSV content, duplicate reporting, malformed JSON, malformed CSV quoting, oversized import rejection before parsing, and excessive JSON question-count rejection.

### Deterministic fuzz-style parser tests

The repository retains deterministic malformed-input coverage using fixed random seeds:

- 500 malformed/random JSON samples;
- 500 malformed/random CSV samples;
- invariant: public decoder entry points report errors instead of allowing parser exceptions to escape uncontrolled.

### Database integration tests

The in-memory SQLite suite covers question/profile/bookmark/attempt persistence, statistics, category aggregation, leaderboard, maintenance/reset flows, rename/delete behavior, and the transactional application behavior represented by the database implementation.

### Widget/journey tests

Phase 6 added or corrected coverage for localization harness usage, quiz metadata/choices/progress, quiz progress/timer semantics, creator UI, import report, settings sections and required credit, viewport-independent settings scrolling, onboarding/custom quiz setup, and the primary one-question play → finish → review journey including deterministic score/correct-answer/explanation rendering.

## CI/security/release workflow work completed

### Maintained recurring workflows

The audit branch keeps focused recurring workflows for Flutter quality, Android/Web build, Linux/Windows/macOS/iOS platform builds, dependency review, OSV vulnerability scanning, full-history Gitleaks secret scanning, and tagged Android/Web release packaging.

### Workflow improvements

- Added concurrency cancellation to recurring PR workflows so superseded commits do not unnecessarily consume runner capacity.
- Hardened checkouts with `persist-credentials: false` where write credentials are not needed.
- Ensured CI runs `flutter gen-l10n` before analysis/tests.
- Extended formatting verification to `lib`, `test`, and `tool`.
- Added OSV scanning to relevant pull-request dependency changes.
- Kept the secret scanner on full history for actual history coverage.
- Updated release workflow to regenerate localizations, verify formatting/analyzer/tests, build Android/Web release artifacts, generate SHA-256 checksums, upload workflow artifacts, and create GitHub releases for valid version tags.

### Obsolete workflows removed

Removed one-shot/bootstrap workflows that had served earlier repository creation/repair purposes and should not remain as recurring source-mutating automation:

- `.github/workflows/fix-intl-dependency.yml`
- `.github/workflows/finalize-baseline.yml`
- `.github/workflows/stabilize-baseline.yml`
- `.github/workflows/verify-latest-baseline.yml`
- `.github/workflows/materialize-platform-runners.yml`

A temporary `.github/workflows/generate-audit-lockfile.yml` was also removed after GitHub Actions did not execute it. This avoided retaining unnecessary `contents: write` capability.

## Local developer tooling synchronized

Updated `tool/check.sh` and `tool/check.ps1`. Both now perform the maintained quality sequence:

```text
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

The CI and release documentation now use the same source-quality scope.

## Documentation updated in Phase 6

Updated or added:

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

The README now contains explicit real-screenshot placeholders and links to `docs/screenshots/README.md`. Fake/mock screenshots are intentionally not presented as evidence of a working build.

`docs/testing.md` matches the implemented domain, codec/fuzz, database, widget, accessibility, and primary-journey coverage.

`docs/ci.md` no longer documents deleted self-mutating baseline workflows as maintained automation.

`docs/release.md` explicitly requires the reviewed application lockfile, localization generation, current formatting scope, final-head CI evidence, and manual release checks.

`ROADMAP.md` was reconciled so work that is genuinely implemented is checked off while real Phase 6 blockers remain open.

`CHANGELOG.md` records localization, accessibility, CI, security, resource-limit, test, workflow-cleanup, and verification changes without claiming a verified release.

## Verification actually observed in this session

### Repository inspection

The repository tree, source, tests, docs, workflows, recent commits, PR state, and multiple critical source files were inspected through the connected GitHub repository.

### Local container limitation

The available chat execution container did **not** provide a usable Flutter/Dart SDK, and direct container GitHub cloning/network access was unavailable. Therefore this session did not fabricate local output for `flutter pub get`, `flutter gen-l10n`, `dart format`, `flutter analyze`, `flutter test`, or platform builds. Those gates remain evidence requirements.

### GitHub Actions state

On audit head `501b32282c68bde32cc51c328cddd27da497b753`, these PR-triggered runs were observed:

- CI — run `32219052359` — pending;
- Build Gate — run `32219052296` — pending;
- Platform Build Matrix — run `32219052449` — pending;
- Dependency Review — run `32219052382` — queued;
- OSV Vulnerability Scan — run `32219052881` — queued;
- Secret Scan — run `32219052453` — pending.

Subsequent documentation/handoff commits create a newer PR head and newer runs. The latest head must be used for the real release decision. The observed queue/pending state is explicitly **not** a pass.

## `pubspec.lock` status

`pubspec.lock` is still missing from the audit branch.

A temporary one-shot GitHub Actions workflow was created to use Flutter stable, run `flutter pub get`, verify the lockfile exists, commit it with email `sanskarin@outlook.in`, and remove itself. GitHub Actions remained queued/pending and the file was not generated. The temporary workflow was then deleted rather than leaving a write-capable workflow in source control.

The next verified Flutter environment must generate and review `pubspec.lock`, and the normal Flutter application lockfile should be committed before a release-candidate tag. Do **not** hand-author a lockfile.

## Current database/migration state

- Database schema version: `1`.
- Current database creation is explicit in `AppDatabase`.
- Foreign keys are enabled before normal use.
- Current multi-step writes use transactions where needed.
- In-memory database creation/persistence tests exist in source control.
- There is no historical schema migration to test yet because no schema version greater than 1 has been released.
- The first schema increment must add a real migration and an old-version-to-new-version migration test.

## Known limitations / release blockers

1. Final-head CI has not yet completed successfully.
2. `pubspec.lock` has not yet been generated/reviewed in a verified Flutter environment.
3. Android release build evidence is pending.
4. Web release build and Drift persistence/reload evidence are pending.
5. Windows/Linux/macOS host build evidence is pending on the final head.
6. iOS no-codesign compile evidence is pending on the final head; signing/device validation is external to public source control.
7. Real private-room networking is intentionally not implemented; only a disabled/fail-closed architecture boundary exists.
8. Production/store icon/splash output still needs actual platform-generation/visual verification.
9. Real release-candidate screenshots are pending; fabricated screenshots are intentionally prohibited.
10. Manual keyboard/focus/screen-reader/large-text/reduced-motion/contrast review is pending.
11. Representative performance measurements are pending even though the deterministic benchmark harness exists.
12. Final documentation-link checking is pending.
13. Final repository/history secret review must be performed on the final release head.
14. Store signing/provisioning secrets are intentionally absent from the public repository.

## Exact next tasks

Continue in this order:

1. Read this file and `docs/verification.md` first.
2. Read the latest PR #9 head because documentation updates after the run ids above create new workflow runs.
3. Check whether the final-head CI, Build Gate, Platform Build Matrix, Dependency Review, OSV, and Secret Scan have completed.
4. For any failed workflow, fetch the failing job steps/logs, fix the defect in a focused commit, add regression coverage where appropriate, and rerun the affected checks.
5. Do not merge PR #9 while required final-head checks are queued/pending/failing.
6. In a verified Flutter stable environment, run `flutter pub get`, review and commit `pubspec.lock`, then rerun all affected dependency/build/security gates.
7. From a clean checkout run the documented localization/format/analyzer/test commands.
8. Verify Android and Web builds; exercise Drift database creation, persistence, import/export, and Web refresh/reload behavior.
9. Verify Windows/Linux/macOS on their proper hosts and iOS no-codesign compile on macOS.
10. Perform manual keyboard/focus/screen-reader/large-text/reduced-motion/contrast checks.
11. Capture real screenshots listed in `docs/screenshots/README.md` from the exact verified release candidate using fictional data.
12. Check documentation links.
13. Update `docs/verification.md`, `CHANGELOG.md`, `ROADMAP.md`, and this file with actual final evidence.
14. Merge PR #9 using a normal merge strategy that preserves the meaningful atomic commit history unless repository policy requires a different strategy.
15. Only after all applicable blockers are cleared, create the release-candidate/version tag and allow `.github/workflows/release.yml` to package the verified Android/Web release artifacts.

## Recent meaningful commits from this audit

Recent commits include, among others:

- `d110ea9` — `docs: start phase 6 verification evidence`
- `bff20cf` — `feat: localize question creator and harden save errors`
- `c780c45` — `feat: localize question bank browsing and filters`
- `424cc2c` — `feat: localize quiz progress timers and true false choices`
- `5cb7cc8` — `feat: localize custom quiz difficulty controls`
- `d6f0cbe` — `feat: localize statistics and local leaderboard`
- `40b1e0b` — `feat: localize settings and redact action errors`
- `750f4be` — `test: verify private room transport fails closed`
- `1da9dc8` — `test: cover canonical true false scoring`
- `573cfd7` — `build: declare Flutter-pinned intl dependency`
- `9c3b0b1` — `test: cover primary quiz completion journey`
- `20b8e0b` — `docs: add verified screenshot placeholders and current quality commands`
- `0cd299f` — `docs: align setup guide with localization and tooling gates`
- `eae5a36` — `docs: update development guide for logging and localization`
- `bcccec2` — `docs: synchronize testing strategy with implemented coverage`
- `ebf26b4` — `docs: document maintained CI and remove obsolete workflow guidance`
- `34afb5a` — `build: align shell quality check with CI`
- `87afb15` — `build: align PowerShell quality check with CI`
- `cbe7a08` — `docs: strengthen release reproducibility requirements`
- `47495b1` — `security: bound question bank import size and row count`
- `919121d` — `test: cover question bank import resource limits`
- `89356a2` — `security: enforce bounded question content and canonical answers`
- `0fad6f0` — `test: cover bounded question validation and canonical inputs`
- `f2adf27` — `fix: apply settings only after persistence succeeds`
- `2810e81` — `docs: reconcile roadmap with completed phases and audit blockers`
- `7d827e1` — `docs: record phase 6 hardening and verification status`
- `501b322` — `ci: remove blocked one-shot lockfile workflow`
- `5a6ccc2` — `docs: update phase 6 evidence and blocked verification state`

The audit branch also contains separate focused commits removing obsolete bootstrap/self-mutating workflows and separate CI concurrency/security improvements. Keep those atomic commits when merging if possible.

## Release notes draft — development baseline / pending RC

QuizForge now has an offline-first cross-platform quiz-game and quiz-authoring foundation with four question types, deterministic daily/random/custom practice, timed play, review/explanations/bookmarks, local profiles, SQLite progress tracking, category statistics, a local leaderboard, bounded JSON/CSV question-bank interchange, validated authoring, adaptive Material 3 UI, first-run onboarding, externalized English product strings, accessibility preferences, privacy-first structured logging, deterministic fuzz-style tests, primary quiz-journey automation, platform build/security workflows, extensive documentation, and a Phase 6 evidence ledger.

Phase 6 additionally hardens import resource usage, question content bounds, settings persistence ordering, localization identifiers, system text scaling, error redaction, and workflow permissions/maintenance.

This remains a **development baseline / release-candidate audit**, not a production-release claim, until the blockers above are cleared with actual evidence.

## Continuation rule

When another session continues this repository, do not restart completed phases and do not create duplicate replacement scaffolding. Continue from PR #9 / the latest repository state, inspect the latest workflow evidence first, fix only actual remaining defects/blockers, keep commits atomic and meaningful, and update this file after every substantial continuation.

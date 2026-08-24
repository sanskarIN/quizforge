# QuizForge 2.18.12 — Next-Version Preparation

Status: planning only; implementation must begin only after QuizForge 2.7.4 is verified and its maintained release path is closed.

This document prepares the next milestone without changing the current `2.7.4+1` package identity or pretending that an unreleased version already exists. Version `2.18.12` must inherit the verified 2.7.4 data, platform, privacy, and release contracts rather than bypass them.

## Entry criteria

Before implementation work for 2.18.12 begins:

- `v2.7.4` has been created only after its applicable exact-head automated gates pass;
- required Android/Web/native-host persistence and local-backup smoke evidence has been recorded;
- representative branding/accessibility review and real screenshots for 2.7.4 are complete;
- release signing/provisioning boundaries are documented for distributed targets;
- `main` contains the verified 2.7.4 release state;
- the 2.18.12 development branch starts from that verified state rather than from an older audit branch;
- `CHANGELOG.md` retains an Unreleased section before the new version is cut.

## Version transition contract

When 2.18.12 implementation is ready to declare a release candidate, update all release identity surfaces together:

- `pubspec.yaml` package version, using an intentional positive build number;
- `AppConstants.version` public version;
- `CHANGELOG.md` dated 2.18.12 release entry while retaining a fresh Unreleased section;
- `docs/versioning.md` maintained package/tag identity;
- release notes and verification evidence;
- About/version widget expectations;
- intended Git tag `v2.18.12` only after exact-head verification.

Do not bump the database schema or local-backup format merely because the application version changes. Those versions change only when their actual contracts change and must include migration/compatibility tests.

## Planned milestone themes

### 1. Portable authoring and backup workflows

- Add optional file-picker based question-bank import/export where supported.
- Add optional file-picker based complete local-backup save/restore where supported.
- Keep clipboard workflows available as the low-dependency fallback.
- Treat every imported file as untrusted and retain existing size/domain/reference validation.
- Add platform-adapter tests for success, cancellation, permission denial, malformed content, and unsupported-platform behavior.

### 2. Shareable quiz packs

- Define a versioned quiz-pack format that contains quiz content only, never profiles, attempts, submitted answers, or settings.
- Keep quiz packs clearly separate from complete local backups.
- Include format/version validation and duplicate handling.
- Add deterministic import/export round-trip and malformed-input tests.
- Document privacy differences between shareable packs and private local backups.

### 3. Richer statistics

- Add longitudinal local statistics beyond the current bounded recent-attempt list.
- Preserve per-profile isolation.
- Avoid exposing submitted-answer content in summary surfaces.
- Add deterministic aggregation tests for empty, single-attempt, multi-category, and long-history cases.
- Measure query cost before introducing schema/index changes.

### 4. Localization expansion

- Add additional ARB catalogs only after message-key parity and fallback behavior are defined.
- Keep domain serialization identifiers language-neutral.
- Add locale-specific formatting checks for dates, numbers, percentages, and long text.
- Preserve the deterministic ARB validation gate.

### 5. Optional private-room transport

- Keep multiplayer networking disabled until a transport is explicitly implemented and security reviewed.
- Preserve the existing fail-closed transport boundary.
- Any enabled transport must include authorization, malformed-message, timeout, replay/duplication, disconnect, privacy, and abuse-case tests.
- Core offline quiz functionality must remain available without an account or network service.

### 6. Real-browser and restart-level end-to-end coverage

- Add a built-Web browser journey for database create/write/read, refresh/reload persistence, question-bank exchange, and local-backup restore.
- Add restart-level settings/profile persistence journeys using stable test adapters.
- Add full UI profile isolation coverage for bookmarks, progress, and recent history.
- Keep fixtures fictional and credential-free.

### 7. Performance evidence

- Record benchmark hardware/toolchain metadata.
- Measure large question-bank selection, JSON/CSV/pack codecs, backup encode/decode, statistics queries, and startup/database initialization.
- Introduce pagination/virtualization/isolate work only when measurements justify it.
- Record performance budgets and regressions in documentation rather than relying on subjective impressions.

### 8. Distribution maturity

- Keep canonical generated application identity `io.github.sanskarin.quizforge`.
- Preserve deterministic platform branding and generated-runner contract validation.
- Evaluate platform-native packaging/installers separately from Flutter compilation.
- Keep Android/iOS/macOS signing credentials outside the public repository.
- Produce checksums for published artifacts.

## Required compatibility rules

2.18.12 work must preserve unless intentionally migrated and documented:

- offline-first core use;
- Android, iOS, Web, Windows, macOS, and Linux source support;
- canonical application identity `io.github.sanskarin.quizforge`;
- deterministic scoring and question-domain validation;
- profile data isolation;
- local-backup version compatibility rules;
- privacy-safe logging;
- no committed production credentials/signing secrets/private user archives;
- exact-head automated verification before release promotion.

## Proposed implementation order

1. Close and publish verified 2.7.4.
2. Branch the 2.18.12 development line from the verified release state.
3. Add file-adapter abstractions and tests before UI integration.
4. Define/test shareable quiz-pack format.
5. Add richer statistics with measured database impact.
6. Expand localization catalogs and UI coverage.
7. Expand browser/restart end-to-end verification.
8. Record performance evidence and optimize only measured bottlenecks.
9. Consider optional private-room transport only after the offline/product work remains green.
10. Perform full six-platform release-candidate verification before `v2.18.12`.

## Non-goals for preparation

This planning stage does not:

- change `pubspec.yaml` away from `2.7.4+1`;
- create tag `v2.18.12`;
- claim database schema or backup format changes;
- enable network multiplayer;
- claim manual platform verification that has not happened;
- replace 2.7.4 release blockers with future-version work.

**Made by the Sanskar**

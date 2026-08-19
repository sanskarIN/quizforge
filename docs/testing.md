# Testing Strategy

QuizForge treats tests as executable product requirements rather than placeholders.

## Local quality gate

Run:

```bash
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

On Windows, use `python` in place of `python3` when that is the configured launcher. `tool/check.sh` and `tool/check.ps1` run the maintained quality sequence for their host shells.

The repository-local Markdown, ARB, and release-metadata validators use Python's standard library and do not depend on third-party network availability. Their own regression tests run before Flutter setup in CI so a broken validator cannot silently become the gatekeeper for the rest of the project.

CI runs the maintained source-quality checks for every pull request and on pushes to `main`; dedicated workflows add Android/Web and desktop/Apple platform build gates plus dependency and secret scanning. Path-filtered workflows still run only when their relevant files change.

## Current coverage areas

### Domain unit tests

- question validation;
- answer normalization;
- duplicate fingerprints;
- exact-set scoring;
- canonical true/false scoring;
- accepted short-answer variants;
- deterministic seeded selection;
- category/difficulty/tag filtering;
- result percentage, duration, and streak calculations;
- private-room protocol validation and fail-closed disabled transport behavior.

### Application/controller regression tests

Controller-level tests use explicit persistence interfaces and an in-memory database to verify failure ordering that is difficult to exercise through real platform preference plugins. Coverage includes:

- active-profile selection remains unchanged when the active-profile preference write fails;
- failed new-profile activation removes the newly inserted profile instead of leaving a hidden local record;
- failed replacement-profile preference persistence prevents active-profile deletion before any database row is removed;
- settings remain unchanged in memory when settings persistence fails;
- a partial local-data reset failure still reloads controller state from the stores that actually remain, rather than leaving stale pre-reset state in memory;
- complete local backup restores questions, profiles, bookmarks, quiz progress, settings, and active-profile selection;
- malformed local backup is rejected before mutating current controller state;
- a cross-store restore failure rolls the database/settings/profile-preference state back to the pre-restore snapshot when rollback succeeds.

These tests protect the rule that user-visible controller state and durable local state must not claim a preference was saved before its persistence operation succeeds. Post-write derived-data refreshes are isolated from the primary write so a successful persisted action is not incorrectly reported as failed only because a statistics/leaderboard refresh could not be read immediately afterward.

### Question-bank codec and fuzz tests

- JSON round trips;
- CSV round trips;
- quoted commas/quotes;
- malformed JSON;
- malformed/unclosed CSV quoting;
- quotes embedded in unquoted CSV fields;
- characters after a quoted CSV field closes;
- duplicate handling against an existing bank;
- deterministic malformed-input/fuzz cases that ensure parser failures are reported rather than escaping as uncontrolled crashes.

### Local-backup tests

Backup coverage is deliberately split across layers:

- `test/data/local_backup_codec_test.dart` covers versioned JSON round trips, unsupported versions, invalid active-profile references, inconsistent aggregate metadata, and the maximum archive-size guard;
- `test/data/local_backup_required_active_profile_test.dart` verifies that version 1 cannot encode or decode a complete archive without an active-profile selection;
- `test/data/app_database_backup_test.dart` covers logical database export/reset/restore, dangling-reference rejection, profile/minimum-state checks, best-streak consistency, missing-answer-order semantics, and non-finite aggregate-score rejection;
- `test/data/app_database_backup_minimum_state_test.dart` verifies that a complete archive cannot omit every question and rely on initialization to silently reseed state after restore;
- `test/data/app_database_backup_answer_integrity_test.dart` verifies that a crafted archive cannot mark a wrong submitted answer correct or assign a score that disagrees with the archived question's normal QuizForge evaluation;
- `test/data/app_database_backup_bookmark_key_test.dart` verifies that distinct bookmark `(profileId, questionId)` pairs remain distinct even when identifier text contains a character that would collide in a delimiter-concatenated composite key;
- `test/data/app_database_backup_attempt_bounds_test.dart` verifies that restored attempts respect the same 1–100-question session-size range as normal quiz configuration;
- `test/application/quizforge_controller_backup_test.dart` covers whole-controller restoration and cross-store rollback behavior;
- `test/widget/local_backup_page_test.dart` verifies that restore cannot proceed without the destructive-replacement confirmation dialog.

Backup fixtures must stay fictional. Real backup archives can contain profile names, authored content, and submitted answers and must not be committed as test data.

### Database integration tests

An in-memory SQLite database exercises:

- question persistence;
- local profiles;
- bookmarks;
- transactional attempt persistence;
- progress aggregation;
- category statistics;
- leaderboard aggregation;
- bounded recent-attempt projection;
- newest-first recent-attempt ordering;
- recent-attempt query limits and invalid-limit rejection;
- recent-history cleanup with active-profile activity deletion;
- local activity/data reset behavior;
- logical backup export and transactional restore.

The current schema is version 1, so there is no historical schema migration path to exercise yet. Recent attempt history is a read-only projection over the existing attempts table and therefore does not require a schema change. The first released schema change must add both migration code and an old-version-to-new-version migration test before it can be merged.

### Widget and journey tests

Widget coverage includes:

- onboarding content;
- real app-shell first-run routing with an injectable onboarding store;
- onboarding skip/completion transition into the dashboard;
- completed-onboarding startup into the dashboard;
- question creator validation/preview behavior;
- JSON question-bank import and report rendering;
- local-backup restore confirmation and success rendering;
- custom quiz setup;
- localized quiz metadata and choices;
- timer/progress accessibility semantics with semantics explicitly enabled;
- About-page project identity, contact/funding/credit, and exact public application version (`2.7.4` for this candidate);
- settings sections and the required project credit;
- recent-attempt statistics rendering using in-memory SQLite and memory-only preference adapters;
- a primary one-question play → finish → review journey, including score, correct answer, and explanation rendering.

The recent-attempt widget regression specifically avoids depending on platform SharedPreferences so it can remain a deterministic Flutter widget test. It persists an attempt in the in-memory database, opens the Statistics page, and verifies summary score/accuracy/time rendering.

### Repository validation tooling

`tool/check_markdown_links.py` scans tracked Markdown content for repository-local inline links, image targets, and reference definitions. It ignores fenced code examples, pure anchors, and external URL schemes so results remain deterministic.

`tool/check_arb_catalogs.py` validates localization catalogs before `flutter gen-l10n`. It rejects duplicate JSON keys, missing/non-empty locale metadata, non-string/empty message values, orphaned metadata entries, and translated catalogs whose message-key sets diverge from the English template.

`tool/check_release_metadata.py` validates release identity before Flutter setup. It requires one valid `MAJOR.MINOR.PATCH+BUILD` package version with a positive build number; exactly one semantic `AppConstants.version` that matches the public package version; a matching dated changelog release entry; unique/descending release headings (including historical zero-major releases); a stable-major versioning policy; and matching maintained package/tag identities in `docs/versioning.md`.

Its regression suite includes both mismatched and non-semantic in-app version constants, so a future package bump cannot leave the About-page version on an older release without failing the repository gate.

All three validators have stdlib-only regression tests and run in CI before Flutter setup. The release-metadata validator also runs in the tag packaging workflow so a 2.7.4 tag cannot bypass the same package/in-app/changelog/versioning consistency check exercised on pull requests.

## Required tests for future changes

- Every bug fix should add a regression test when reproducible in automation.
- Every migration must test creation from a clean database and migration from the previous schema.
- Parser changes should add malformed/edge-heavy inputs.
- Scoring changes must add deterministic domain tests.
- New settings should test defaults, persistence, and UI behavior.
- New progress/history queries should test profile isolation, ordering, bounds, deletion semantics, and empty state.
- Backup-format changes must test old-version compatibility or explicit rejection, complete reference validation, answer-scoring integrity, session-size bounds, collision-safe composite identities, rollback behavior, and privacy-safe logging.
- Version changes must update `pubspec.yaml`, `AppConstants.version`, `CHANGELOG.md`, and the maintained package/tag identity in `docs/versioning.md`, then pass `tool/test_check_release_metadata.py` and `tool/check_release_metadata.py`.
- New localization catalogs/messages must pass the ARB validator and localization generation.
- New network transports must include failure, timeout, malformed-message, authorization, and privacy-sensitive cases.
- Platform clipboard/file-adapter changes should test success and failure paths with platform-channel fakes where practical.

## Remaining end-to-end expansion targets

The app shell and primary quiz journey are covered with deterministic in-memory dependencies. Additional high-value journeys to automate when reliable host/platform fixtures are introduced are:

1. create a custom question, persist it, and immediately play it;
2. export and re-import a complete question bank through platform clipboard/file adapters;
3. export, mutate state, and restore a complete local backup through real platform clipboard/file adapters;
4. switch local profiles and verify independent bookmarks/progress/recent history through the full UI;
5. change accessibility/theme preferences and verify persistence across a real app restart/platform-preference boundary;
6. recover gracefully from malformed imports through the complete navigation flow.

These should use deterministic local fixtures and must not require production credentials or an external service.

## Determinism

Tests must not depend on the current clock when an explicit date/seed can be supplied. Fixtures must be fictional and must not require internet access, production credentials, or private user data.

## Parser fuzz/property testing

The repository includes deterministic fuzz-style malformed-input coverage without adding an unnecessary property-testing dependency. Important invariants remain:

- encoding then decoding a valid question preserves its semantic fields;
- arbitrary malformed input never causes an uncontrolled application crash;
- duplicate partitioning never emits the same id/fingerprint twice in the accepted set;
- CSV quote handling either parses deterministically or reports a format error;
- a local backup is accepted only when its format version, minimum initialized state, object graph, submitted-answer scoring, aggregate metadata, bounded attempt sizes, bookmark pair identity, and active-profile reference are internally consistent.

A dedicated property-testing package should be added only if it provides materially stronger coverage and passes dependency/security review.

## Performance checks

Performance tests use generated fictional data. `tool/benchmark.dart` exercises deterministic quiz selection plus JSON/CSV encode/decode paths and is included in the formatting gate. Do not add arbitrary benchmark targets without measuring on documented hardware/toolchains. See `docs/performance.md` and `docs/benchmarking.md`.

## Manual backup/restore review

Before a release candidate is described as backup-verified, follow [`local-backup.md`](local-backup.md): create a backup containing a custom question, second profile, bookmark, completed attempt, and non-default settings; mutate the current state; restore the archive; confirm every backed-up field returns; verify the confirmation dialog and failure messaging; and repeat a smoke restore on Android and Web release builds using fictional data.

## Manual attempt-history review

Before merging the recent-history feature, follow `docs/attempt-history-verification.md`: complete multiple quizzes with different outcomes, confirm newest-first ordering, switch profiles, confirm independent history, verify refresh after a new completion, clear profile activity, and inspect the UI with enlarged text. The summary list must not expose submitted answer content.

## Manual accessibility review

Before a release candidate, manually verify keyboard navigation, visible focus, scalable text, screen-reader semantics, high-contrast status comprehension, and reduced-motion behavior on representative platforms. Automated semantics tests increase confidence but do not replace assistive-technology review.

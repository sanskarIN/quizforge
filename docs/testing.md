# Testing Strategy

QuizForge treats tests as executable product requirements rather than placeholders.

## Local quality gate

Run:

```bash
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
python3 tool/check_markdown_links.py
flutter analyze
flutter test --coverage
```

On Windows, use `python tool/check_markdown_links.py` when `python` is the configured launcher. The repository-local Markdown checker is deterministic and does not depend on third-party network availability.

CI runs the same source-quality checks on pushes and pull requests targeting `main`; dedicated workflows add Android/Web and desktop/Apple platform build gates plus dependency and secret scanning.

## Current coverage areas

### Domain unit tests

- question validation and bounded content rules;
- answer normalization;
- accepted-answer duplicate rejection before JSON list-to-set conversion;
- duplicate fingerprints;
- exact-set scoring;
- canonical true/false scoring;
- accepted short-answer variants;
- deterministic seeded selection with a known cross-runtime ordering fixture;
- negative-seed normalization and daily-date determinism;
- category/difficulty/tag filtering;
- result percentage, duration, and streak calculations;
- private-room protocol validation and fail-closed disabled transport behavior.

### Starter-bank integrity tests

The deterministic fictional starter bank is checked for:

- domain validity of every question;
- unique ids;
- unique normalized duplicate fingerprints;
- coverage of every supported question type;
- multiple practice categories.

This prevents a content edit from breaking first-run seeding or silently introducing duplicate starter questions.

### Application/controller regression tests

Controller-level tests use explicit persistence interfaces and an in-memory database to verify failure ordering that is difficult to exercise through real platform preference plugins. Coverage includes:

- noncritical settings/active-profile preference failures do not block core startup;
- active-profile selection remains unchanged when the active-profile preference write fails;
- failed new-profile activation removes the newly inserted profile instead of leaving a hidden local record;
- failed replacement-profile preference persistence prevents active-profile deletion before any database row is removed;
- settings remain unchanged in memory when settings persistence fails;
- a partial local-data reset failure still reloads controller state from the stores that actually remain, rather than leaving stale pre-reset state in memory;
- settings and active-profile selection reload across a simulated controller restart boundary using shared in-memory stores.

These tests protect the rule that user-visible controller state and durable local state must not claim a preference was saved before its persistence operation succeeds. Post-write derived-data refreshes are isolated from the primary write so a successful persisted action is not incorrectly reported as failed only because a statistics/leaderboard refresh could not be read immediately afterward.

### Codec and fuzz tests

- JSON round trips;
- CSV round trips;
- quoted commas/quotes;
- normalized duplicate accepted-answer rejection in JSON and CSV before list-to-set collapse;
- malformed JSON;
- malformed/unclosed CSV quoting;
- quotes embedded in unquoted CSV fields;
- characters after a quoted CSV field closes;
- duplicate handling against an existing bank;
- oversized payload and excessive-question-count rejection;
- deterministic malformed-input/fuzz cases that ensure parser failures are reported rather than escaping as uncontrolled crashes.

### Database integration tests

An in-memory SQLite database exercises:

- question persistence;
- local profiles;
- bookmarks;
- transactional attempt persistence;
- progress aggregation;
- category statistics;
- leaderboard aggregation;
- local activity/data reset behavior;
- rollback of an entire question batch when a later item is invalid;
- rollback of an attempt when an answer row violates its question foreign key.

The current schema is version 1, so there is no historical schema migration path to exercise yet. The first released schema change must add both migration code and an old-version-to-new-version migration test before it can be merged.

### Widget and journey tests

Widget coverage includes:

- onboarding content;
- real app-shell first-run routing with an injectable onboarding store;
- onboarding skip/completion transition into the dashboard;
- completed-onboarding startup into the dashboard;
- onboarding preference-load failure fail-open behavior;
- question creator validation/preview behavior;
- non-numeric creator time-limit rejection;
- live creator duplicate accepted-answer validation and recovery after correction;
- JSON question-bank import and report rendering;
- custom quiz setup;
- localized quiz metadata and choices;
- timer/progress accessibility semantics with semantics explicitly enabled;
- settings sections and the required project credit;
- a primary one-question play → finish → review journey, including score, correct answer, and explanation rendering.

### Documentation integrity

`tool/check_markdown_links.py` scans tracked Markdown content for repository-local inline links, image targets, and reference definitions. It ignores fenced code examples, pure anchors, and external URL schemes so results remain deterministic. The CI quality gate runs it on every relevant pull request/push.

## Required tests for future changes

- Every bug fix should add a regression test when reproducible in automation.
- Every migration must test creation from a clean database and migration from the previous schema.
- Parser changes should add malformed/edge-heavy inputs.
- Scoring or seeded-order changes must add deterministic domain fixtures and document behavior changes.
- New settings should test defaults, persistence, and UI behavior.
- New network transports must include failure, timeout, malformed-message, authorization, and privacy-sensitive cases.
- Platform clipboard/file-adapter changes should test success and failure paths with platform-channel fakes where practical.

## Remaining end-to-end expansion targets

The app shell and primary quiz journey are covered with deterministic in-memory dependencies. Additional high-value journeys to automate when reliable host/platform fixtures are introduced are:

1. create a custom question, persist it, and immediately play it;
2. export and re-import a complete question bank through platform clipboard/file adapters;
3. switch local profiles and verify independent bookmarks/progress through the full UI;
4. change accessibility/theme preferences and verify persistence across a real app restart/platform-preference boundary;
5. recover gracefully from malformed imports through the complete navigation flow.

These should use deterministic local fixtures and must not require production credentials or an external service.

## Determinism

Tests must not depend on the current clock when an explicit date/seed can be supplied. Fixtures must be fictional and must not require internet access, production credentials, or private user data.

The seeded quiz shuffle uses a small explicitly implemented deterministic generator instead of relying on SDK-specific `Random` behavior. Tests lock one known order and also verify daily-date and negative-seed behavior.

## Parser fuzz/property testing

The repository includes deterministic fuzz-style malformed-input coverage without adding an unnecessary property-testing dependency. Important invariants remain:

- encoding then decoding a valid question preserves its semantic fields;
- arbitrary malformed input never causes an uncontrolled application crash;
- duplicate partitioning never emits the same id/fingerprint twice in the accepted set;
- duplicate accepted answers cannot disappear silently during parsing;
- CSV quote handling either parses deterministically or reports a format error.

A dedicated property-testing package should be added only if it provides materially stronger coverage and passes dependency/security review.

## Performance checks

Performance tests use generated fictional data. `tool/benchmark.dart` exercises deterministic quiz selection plus JSON/CSV encode/decode paths and is included in the formatting gate. Do not add arbitrary benchmark targets without measuring on documented hardware/toolchains. See `docs/performance.md` and `docs/benchmarking.md`.

## Manual accessibility review

Before a release candidate, manually verify keyboard navigation, visible focus, scalable text, screen-reader semantics, high-contrast status comprehension, and reduced-motion behavior on representative platforms. Automated semantics tests increase confidence but do not replace assistive-technology review. Large-text review must include operating-system scaling and, where available, nonlinear scaling behavior so the app-level minimum does not replace stronger platform scaling.

# Testing Strategy

QuizForge treats tests as executable product requirements rather than placeholders.

## Local quality gate

Run:

```bash
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

CI runs the same source-quality checks on pushes and pull requests targeting `main`; dedicated workflows add Android/Web and desktop/Apple platform build gates plus dependency and secret scanning.

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

### Codec and fuzz tests

- JSON round trips;
- CSV round trips;
- quoted commas/quotes;
- malformed JSON;
- malformed CSV quoting;
- duplicate handling against an existing bank;
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
- local activity/data reset behavior.

The current schema is version 1, so there is no historical schema migration path to exercise yet. The first released schema change must add both migration code and an old-version-to-new-version migration test before it can be merged.

### Widget and journey tests

Widget coverage includes:

- onboarding content;
- question creator validation/preview behavior;
- JSON question-bank import and report rendering;
- custom quiz setup;
- localized quiz metadata and choices;
- timer/progress accessibility semantics with semantics explicitly enabled;
- settings sections and the required project credit;
- a primary one-question play → finish → review journey, including score, correct answer, and explanation rendering.

## Required tests for future changes

- Every bug fix should add a regression test when reproducible in automation.
- Every migration must test creation from a clean database and migration from the previous schema.
- Parser changes should add malformed/edge-heavy inputs.
- Scoring changes must add deterministic domain tests.
- New settings should test defaults, persistence, and UI behavior.
- New network transports must include failure, timeout, malformed-message, authorization, and privacy-sensitive cases.

## Remaining end-to-end expansion targets

The current widget journey covers quiz completion and review. Additional high-value journeys to automate when reliable host/platform fixtures are introduced are:

1. complete first launch and starter-data initialization through the real app bootstrap;
2. create a custom question, persist it, and immediately play it;
3. export and re-import a complete question bank through platform clipboard/file adapters;
4. switch local profiles and verify independent bookmarks/progress through the full UI;
5. change accessibility/theme preferences and verify persistence across an app restart boundary;
6. recover gracefully from malformed imports through the complete navigation flow.

These should use deterministic local fixtures and must not require production credentials or an external service.

## Determinism

Tests must not depend on the current clock when an explicit date/seed can be supplied. Fixtures must be fictional and must not require internet access, production credentials, or private user data.

## Parser fuzz/property testing

The repository includes deterministic fuzz-style malformed-input coverage without adding an unnecessary property-testing dependency. Important invariants remain:

- encoding then decoding a valid question preserves its semantic fields;
- arbitrary malformed input never causes an uncontrolled application crash;
- duplicate partitioning never emits the same id/fingerprint twice in the accepted set;
- CSV quote handling either parses deterministically or reports a format error.

A dedicated property-testing package should be added only if it provides materially stronger coverage and passes dependency/security review.

## Performance checks

Performance tests use generated fictional data. `tool/benchmark.dart` exercises deterministic quiz selection plus JSON/CSV encode/decode paths and is included in the formatting gate. Do not add arbitrary benchmark targets without measuring on documented hardware/toolchains. See `docs/performance.md` and `docs/benchmarking.md`.

## Manual accessibility review

Before a release candidate, manually verify keyboard navigation, visible focus, scalable text, screen-reader semantics, high-contrast status comprehension, and reduced-motion behavior on representative platforms. Automated semantics tests increase confidence but do not replace assistive-technology review.

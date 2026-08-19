# Testing Strategy

QuizForge treats tests as executable product requirements rather than placeholders.

## Local quality gate

Run:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
```

CI runs the same core checks on pushes and pull requests targeting `main`.

## Current coverage areas

### Domain unit tests

- question validation;
- answer normalization;
- duplicate fingerprints;
- exact-set scoring;
- accepted short-answer variants;
- deterministic seeded selection;
- category/difficulty/tag filtering;
- result percentage, duration, and streak calculations.

### Codec tests

- JSON round trips;
- CSV round trips;
- quoted commas/quotes;
- malformed JSON;
- malformed CSV quoting;
- duplicate handling against an existing bank.

### Database integration tests

An in-memory SQLite database exercises:

- question persistence;
- local profiles;
- bookmarks;
- transactional attempt persistence;
- progress aggregation;
- leaderboard aggregation.

### Widget tests

Initial widget coverage verifies rendering of a playable question, metadata, choices, and progress indicator.

## Required tests for future changes

- Every bug fix should add a regression test when reproducible in automation.
- Every migration must test creation from a clean database and migration from the previous schema.
- Parser changes should add malformed/edge-heavy inputs.
- Scoring changes must add deterministic domain tests.
- New settings should test defaults, persistence, and UI behavior.
- New network transports must include failure, timeout, malformed-message, authorization, and privacy-sensitive cases.

## End-to-end targets

Primary journeys to automate before release-candidate status:

1. first launch and starter data creation;
2. start and finish a quiz;
3. review explanations and bookmark a question;
4. create and play a custom question;
5. export and re-import a question bank;
6. switch local profiles and verify independent bookmarks/progress;
7. change accessibility/theme preferences and restart;
8. recover gracefully from malformed imports.

## Determinism

Tests must not depend on the current clock when an explicit date/seed can be supplied. Fixtures must be fictional and must not require internet access, production credentials, or private user data.

## Parser fuzz/property testing

The JSON/CSV boundary is a good candidate for property/fuzz testing. Desired invariants include:

- encoding then decoding a valid question preserves its semantic fields;
- arbitrary malformed input never causes an uncontrolled application crash;
- duplicate partitioning never emits the same id/fingerprint twice in the accepted set;
- CSV quote handling either parses deterministically or reports a format error.

This remains a roadmap item until a lightweight maintained Dart testing dependency is selected and verified.

## Performance checks

Performance tests should use generated fictional data at defined sizes. Do not add arbitrary benchmark numbers without measuring on documented hardware/toolchains. See `docs/performance.md`.

## Manual accessibility review

Before a release candidate, manually verify keyboard navigation, visible focus, scalable text, screen-reader semantics, high-contrast status comprehension, and reduced-motion behavior on representative platforms.

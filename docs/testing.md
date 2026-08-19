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
- duplicate handling against an existing bank;
- deterministic fuzz-style malformed-input coverage.

### Database integration tests

An in-memory SQLite database exercises:

- question persistence;
- local profiles;
- bookmarks;
- transactional attempt persistence;
- progress aggregation;
- category aggregation;
- leaderboard aggregation;
- profile activity cleanup;
- profile rename/delete cleanup;
- full local-data reset.

### Controller integration tests

The application controller is exercised against an in-memory database plus injected question/settings/profile-selection fakes. Coverage includes:

- initialization and default-profile creation;
- restoring active-profile selection;
- safe startup failure state;
- search/filter behavior;
- question creation and duplicate rejection;
- settings persistence and failure consistency;
- profile create/rename/select/delete behavior;
- preference-save failure consistency;
- bookmark persistence;
- result/progress/category/leaderboard refresh;
- profile activity clearing;
- full local-data reset.

### Widget tests

Widget coverage includes:

- onboarding progression;
- creator flow;
- import/export flow;
- quiz setup and quiz play;
- quiz accessibility semantics;
- localized review presentation.

### App-level primary journey

`test/integration/primary_journey_test.dart` exercises the application shell with injected onboarding persistence and an in-memory database. It covers startup → dashboard → random practice → answer submission → review → persisted progress.

This is a deterministic app-level widget journey, not a claim that physical-device release builds have been validated.

## Required tests for future changes

- Every bug fix should add a regression test when reproducible in automation.
- Every migration must test creation from a clean database and migration from the previous schema.
- Parser changes should add malformed/edge-heavy inputs.
- Scoring changes must add deterministic domain tests.
- New settings should test defaults, persistence, and UI behavior.
- New network transports must include failure, timeout, malformed-message, authorization, and privacy-sensitive cases.

## Remaining end-to-end targets

The primary startup/play/result/persistence journey is automated. Additional release-depth journeys remain useful:

1. first-launch onboarding plus starter-data creation;
2. review explanations and bookmark a question from the review screen;
3. create and play a custom question;
4. export and re-import a question bank;
5. switch local profiles and verify independent bookmarks/progress;
6. change accessibility/theme preferences and restart;
7. recover gracefully from malformed imports;
8. run representative journeys on real release builds/platform hosts.

## Determinism

Tests must not depend on the current clock when an explicit date/seed can be supplied. Fixtures must be fictional and must not require internet access, production credentials, or private user data.

## Parser fuzz/property testing

QuizForge currently includes deterministic fuzz-style codec coverage without adding a large property-testing dependency. Important invariants remain:

- encoding then decoding a valid question preserves its semantic fields;
- arbitrary malformed input never causes an uncontrolled application crash;
- duplicate partitioning never emits the same id/fingerprint twice in the accepted set;
- CSV quote handling either parses deterministically or reports a format error.

A maintained property-testing package may be introduced later only if it materially improves coverage and passes dependency/security review.

## Performance checks

Performance tests should use generated fictional data at defined sizes. Do not add arbitrary benchmark numbers without measuring on documented hardware/toolchains. See `docs/performance.md`.

## Manual accessibility review

Before a release candidate, manually verify keyboard navigation, visible focus, scalable text, screen-reader semantics, high-contrast status comprehension, and reduced-motion behavior on representative platforms.

# QuizForge Architecture

QuizForge is a modular monolith. The application is intentionally offline-first and keeps UI, application orchestration, domain rules, and infrastructure concerns separate enough that each can evolve without forcing a distributed architecture.

## Dependency direction

```text
presentation  ---> application ---> domain
                      |
                      v
                     data -------> domain
```

The domain layer does not import Flutter widgets, Drift, SQLite, platform APIs, or network clients.

## Layers

### `lib/src/domain/`

Pure product rules and immutable value-oriented models:

- `question.dart` — supported question types, difficulty, validation, normalization, serialization shape, duplicate fingerprint.
- `quiz_config.dart` — category/difficulty/tag/count/timing selection configuration.
- `quiz_engine.dart` — deterministic selection, stable seeded shuffle, daily seed, scoring, and result assembly.
- `quiz_result.dart` — per-question evaluation and aggregate result metrics.
- `question_deduplicator.dart` — duplicate partitioning by id and normalized fingerprint.
- `profile.dart` — local profile, progress, and leaderboard models.
- `app_settings.dart` — appearance/accessibility preferences.
- `private_room.dart` — transport-neutral optional multiplayer contract; networking is disabled by default.

### `lib/src/data/`

Infrastructure adapters:

- `app_database.dart` — Drift-managed SQLite connection with explicit SQL schema and transactional writes.
- `app_database_maintenance.dart` — destructive/maintenance operations kept separate from ordinary persistence paths.
- `app_database_progress.dart` — category-progress aggregation queries.
- `question_repository.dart` — question-bank persistence and deterministic starter seeding.
- `question_bank_codec.dart` — bounded JSON/CSV import/export boundary with strict CSV parsing.
- `settings_repository.dart` — `AppSettingsStore` plus the Shared Preferences implementation for non-sensitive settings.
- `profile_preferences.dart` — `ActiveProfilePreferences` plus the Shared Preferences implementation for active local profile selection.
- `onboarding_repository.dart` — `OnboardingStore` plus first-run preference persistence.
- `demo_questions.dart` — fictional deterministic starter fixtures.

The small storage interfaces make application behavior testable without a live platform preference plugin. Production defaults still use Shared Preferences; tests can inject deterministic in-memory/failing stores to exercise persistence ordering and recovery behavior.

### `lib/src/application/`

`QuizForgeController` coordinates repositories and domain services. It owns observable application state, not domain rules. Widgets request operations from the controller rather than writing directly to SQLite.

Persistence ordering is intentional. Operations that combine SQLite with platform preferences do not mutate visible controller state until the required primary writes have succeeded. When a cross-store reset partially fails, the controller reloads from the durable stores that actually remain before reporting the failure.

Noncritical startup preference/derived-statistic reads fail soft: QuizForge can start with default settings/profile selection and empty derived statistics while still logging a redacted warning. Core question/profile database initialization failures remain fatal and surface the startup retry UI.

### `lib/src/presentation/`

Adaptive Flutter pages and components. Presentation code handles input, navigation, responsive layout, semantics, and user-safe feedback while delegating scoring, validation, persistence, and duplicate decisions.

`QuizForgeApp` accepts an optional `OnboardingStore`, allowing the real root routing/onboarding transitions to be tested without platform channels. Clipboard and URL-launch operations are treated as fallible platform adapters and use user-safe failure feedback.

### `lib/src/core/`

Product identity, design tokens, theme definitions, and structured logging helpers.

## Persistence model

Schema version 1 contains:

- `questions`
- `profiles`
- `attempts`
- `attempt_answers`
- `bookmarks`

Question ids are primary keys. A normalized question fingerprint is unique to reduce accidental duplicate content. Attempt writes and their answer rows use a transaction. Foreign keys are enabled when the database opens.

Future schema changes must increment `schemaVersion` and add explicit migration logic plus migration tests. Editing an already-released schema in place is not acceptable.

## Determinism

Quiz selection accepts an integer seed. The daily quiz derives its seed from the local calendar date (`YYYYMMDD`), allowing the same bank and date to produce the same selection.

The shuffle does not rely on the implementation details of `dart:math Random`. QuizForge uses a small Park-Miller generator whose arithmetic remains within JavaScript's exact-integer range, locking seeded order across Dart VM and Dart-compiled Web for the same input ordering and seed. Regression tests assert a known seeded fixture rather than only comparing two calls in one runtime.

Changing this seeded-order algorithm is user-visible behavior for daily/shared seeded quizzes and must be documented and tested deliberately.

## Import boundary

JSON and CSV are untrusted input. The import path checks source/question-count bounds, parses content, converts to domain models, runs domain validation, partitions duplicates, and only then persists accepted questions.

Accepted-answer arrays are checked for normalized duplicates before conversion to a `Set`, so exact duplicate input cannot disappear silently during parsing. CSV quoting follows a strict state machine: quotes can open only at field start, doubled quotes escape a quote, and no arbitrary characters are allowed after a closing quote.

## Multiplayer boundary

Private-room multiplayer is represented by `PrivateRoomTransport`. The default implementation fails closed and performs no networking. A future implementation must add an ADR covering transport security, privacy, room-code entropy, abuse/rate limits, retention, and threat modeling before it can become enabled product behavior.

## State management

The current app uses a deliberately small `ChangeNotifier` controller instead of a state-management framework. This avoids unnecessary dependencies at the present scale. If state complexity grows enough to warrant a framework, the migration must preserve domain/data isolation and should be recorded in an ADR.

## Error handling

Domain/configuration errors use typed exceptions such as `ArgumentError`, `StateError`, and `FormatException` at internal boundaries. Presentation code catches operation failures and renders user-safe feedback. Structured logging uses stable event names and redacts user content and secrets before emission.

A successful primary persistence write is not reclassified as failed solely because a subsequent statistics/leaderboard refresh fails. Such derived refresh failures are logged as warnings and can be refreshed later.

## Internationalization

English ships first. Primary product/navigation/settings/error copy is externalized through Flutter localization resources. User-authored/imported question content remains domain data and is not silently translated. Domain enum identifiers remain stable and are mapped to localized presentation labels rather than displayed directly.

## Architecture decisions

See `docs/adr/` for durable decisions and their tradeoffs.

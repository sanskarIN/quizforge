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
- `quiz_engine.dart` — deterministic selection, daily seed, scoring, and result assembly.
- `quiz_result.dart` — per-question evaluation and aggregate result metrics.
- `question_deduplicator.dart` — duplicate partitioning by id and normalized fingerprint.
- `profile.dart` — local profile, progress, and leaderboard models.
- `app_settings.dart` — appearance/accessibility preferences.
- `private_room.dart` — transport-neutral optional multiplayer contract; networking is disabled by default.

### `lib/src/data/`

Infrastructure adapters:

- `app_database.dart` — Drift-managed SQLite connection with explicit SQL schema and transactional writes.
- `question_repository.dart` — question-bank persistence and deterministic starter seeding.
- `question_bank_codec.dart` — JSON/CSV import/export boundary.
- `settings_repository.dart` — non-sensitive preferences using the asynchronous Shared Preferences API.
- `profile_preferences.dart` — active local profile selection.
- `demo_questions.dart` — fictional deterministic starter fixtures.

### `lib/src/application/`

`QuizForgeController` coordinates repositories and domain services. It owns observable application state, not domain rules. Widgets request operations from the controller rather than writing directly to SQLite.

### `lib/src/presentation/`

Adaptive Flutter pages and components. Presentation code handles input, navigation, responsive layout, semantics, and user-safe feedback while delegating scoring, validation, persistence, and duplicate decisions.

### `lib/src/core/`

Product identity, design tokens, theme definitions, and future cross-cutting utilities.

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

Quiz selection accepts an integer seed. The daily quiz derives its seed from the local calendar date (`YYYYMMDD`), allowing the same bank and date to produce the same selection. Tests should always supply explicit seeds.

## Import boundary

JSON and CSV are untrusted input. The import path parses, converts to domain models, runs domain validation, partitions duplicates, and only then persists accepted questions.

## Multiplayer boundary

Private-room multiplayer is represented by `PrivateRoomTransport`. The default implementation fails closed and performs no networking. A future implementation must add an ADR covering transport security, privacy, room-code entropy, abuse/rate limits, retention, and threat modeling before it can become enabled product behavior.

## State management

The current app uses a deliberately small `ChangeNotifier` controller instead of a state-management framework. This avoids unnecessary dependencies at the present scale. If state complexity grows enough to warrant a framework, the migration must preserve domain/data isolation and should be recorded in an ADR.

## Error handling

Domain/configuration errors use typed platform exceptions such as `ArgumentError`, `StateError`, and `FormatException` at internal boundaries. Presentation code catches operation failures and renders user-safe feedback. Future structured logging must redact user content and secrets before emission.

## Internationalization

English ships first. Product text should continue moving toward externalized localization resources before additional languages are added. Domain values use stable enum names and should not be used directly as final translated labels.

## Architecture decisions

See `docs/adr/` for durable decisions and their tradeoffs.

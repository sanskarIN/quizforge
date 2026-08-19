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
- `profile.dart` — local profile, aggregate progress, recent-attempt summary, category progress, and leaderboard models.
- `app_settings.dart` — appearance/accessibility preferences.
- `private_room.dart` — transport-neutral optional multiplayer contract; networking is disabled by default.

### `lib/src/data/`

Infrastructure adapters:

- `app_database.dart` — Drift-managed SQLite connection with explicit SQL schema and transactional writes.
- `app_database_progress.dart` — read-side progress projections, including category progress and bounded newest-first attempt history.
- `app_database_maintenance.dart` — explicit local profile/activity/data maintenance operations.
- `question_repository.dart` — question-bank persistence and deterministic starter seeding.
- `question_bank_codec.dart` — JSON/CSV import/export boundary.
- `settings_repository.dart` — non-sensitive preferences using the asynchronous Shared Preferences API.
- `profile_preferences.dart` — active local profile selection.
- `demo_questions.dart` — fictional deterministic starter fixtures.

### `lib/src/application/`

`QuizForgeController` coordinates repositories and domain services. It owns observable application state, not domain rules. Widgets request operations from the controller rather than writing directly to SQLite.

Small feature-specific read operations can be exposed as controller extensions when they do not need to enlarge the controller's mutable state. `quizforge_controller_progress.dart` follows that approach for recent-attempt history: it resolves the active profile and delegates the bounded read to the database progress query layer.

### `lib/src/presentation/`

Adaptive Flutter pages and components. Presentation code handles input, navigation, responsive layout, semantics, and user-safe feedback while delegating scoring, validation, persistence, duplicate decisions, and persistent history reads.

The Statistics page treats recent attempts as a derived read model. Its history panel caches the current database future and invalidates it when the active profile or completed-quiz count changes, avoiding a FutureBuilder request loop while keeping the view synchronized with meaningful controller state changes.

### `lib/src/core/`

Product identity, design tokens, theme definitions, structured logging, and shared cross-cutting utilities.

## Persistence model

Schema version 1 contains:

- `questions`
- `profiles`
- `attempts`
- `attempt_answers`
- `bookmarks`

Question ids are primary keys. A normalized question fingerprint is unique to reduce accidental duplicate content. Attempt writes and their answer rows use a transaction. Foreign keys are enabled when the database opens.

Recent history does **not** introduce another persistence table. `AttemptSummary` is projected from existing `attempts` rows. This keeps aggregate progress and recent-history metadata tied to the same source of truth and avoids migration work for a feature that needs no new stored fields.

Detailed submitted answers remain in `attempt_answers`; the recent-history projection intentionally excludes those values because the Statistics summary only needs score/progress metadata.

Future schema changes must increment `schemaVersion` and add explicit migration logic plus migration tests. Editing an already-released schema in place is not acceptable.

## Read-model bounds

Read-side convenience must remain bounded when a UI needs only a compact window of data. Recent attempt history defaults to 10 rows and accepts limits from 1 through 100. Ordering is deterministic:

```sql
ORDER BY completed_at DESC, id DESC
LIMIT ?
```

The timestamp gives newest-first behavior and the local row id gives deterministic ordering when two attempts share the same completion timestamp.

## Determinism

Quiz selection accepts an integer seed. The daily quiz derives its seed from the local calendar date (`YYYYMMDD`), allowing the same bank and date to produce the same selection. Tests should always supply explicit seeds when testing selection behavior.

Database history tests likewise use explicit timestamps rather than the current wall clock so ordering and duration expectations remain deterministic.

## Import boundary

JSON and CSV are untrusted input. The import path parses, converts to domain models, runs domain validation, partitions duplicates, and only then persists accepted questions. Source size, item count, and domain-content bounds are enforced so local imports remain predictable.

## Multiplayer boundary

Private-room multiplayer is represented by `PrivateRoomTransport`. The default implementation fails closed and performs no networking. A future implementation must add an ADR covering transport security, privacy, room-code entropy, abuse/rate limits, retention, and threat modeling before it can become enabled product behavior.

## State management

The current app uses a deliberately small `ChangeNotifier` controller instead of a state-management framework. This avoids unnecessary dependencies at the present scale. If state complexity grows enough to warrant a framework, the migration must preserve domain/data isolation and should be recorded in an ADR.

Not every read must become long-lived controller state. The attempt-history feature deliberately keeps its bounded result in the presentation panel's asynchronous read lifecycle because aggregate controller state already supplies the invalidation signal (`activeProfile` and completed quiz count).

## Error handling

Domain/configuration errors use typed exceptions such as `ArgumentError`, `StateError`, and `FormatException` at internal boundaries. Presentation code catches operation failures and renders user-safe feedback. Structured logging must redact user content and secrets before emission.

Recent-history load failures use the same safe localized error surface and do not render raw database/exception details.

## Internationalization

English ships first. Product text should continue moving toward externalized localization resources before additional languages are added. Domain values use stable enum names and should not be used directly as final translated labels. Recent-history date/time rendering uses Flutter material localization helpers and existing localized product labels.

## Architecture decisions and supporting contracts

See `docs/adr/` for durable decisions and their tradeoffs. The recent-history read model is additionally documented in:

- `docs/progress-history.md`
- `docs/progress-history-data-contract.md`
- `docs/attempt-history-verification.md`

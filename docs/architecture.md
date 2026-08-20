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

## Cross-platform architecture boundary

QuizForge 2.7.4 targets Android, iOS, Web, Windows, macOS, and Linux from the same application/domain source tree.

Core quiz, scoring, validation, selection, backup, controller, and presentation behavior is shared. The maintained application code does not require `dart:io` or `Platform.*` branches to fork core product logic by operating system.

Platform differences are kept at infrastructure/build boundaries:

- Android/iOS/Windows/macOS/Linux use the native `drift_flutter` SQLite path;
- Web uses the same database abstraction with explicit `DriftWebOptions`, `sqlite3.wasm`, and `drift_worker.js`;
- small settings/profile preferences use Flutter-compatible Shared Preferences adapters;
- clipboard flows use Flutter clipboard APIs;
- external support/project links use `url_launcher`;
- standard Flutter platform runners are reproducibly generated instead of becoming separate application forks.

This keeps feature behavior consistent while allowing host-specific build/signing/storage behavior to remain explicit. See [`platform-support.md`](platform-support.md).

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

- `app_database.dart` — Drift-managed SQLite connection with explicit SQL schema and transactional writes, including explicit Web runtime options.
- `app_database_progress.dart` — read-side progress projections, including category progress and bounded newest-first attempt history.
- `app_database_maintenance.dart` — explicit local profile/activity/data maintenance operations.
- `app_database_backup.dart` — logical database snapshot export/validation and transactional restore.
- `local_backup_codec.dart` — versioned whole-app backup JSON boundary and archive validation.
- `question_repository.dart` — question-bank persistence and deterministic starter seeding.
- `question_bank_codec.dart` — JSON/CSV question-bank import/export boundary.
- `settings_repository.dart` — non-sensitive preferences using the asynchronous Shared Preferences API.
- `profile_preferences.dart` — active local profile selection.
- `demo_questions.dart` — fictional deterministic starter fixtures.

### `lib/src/application/`

`QuizForgeController` coordinates repositories and domain services. It owns observable application state, not domain rules. Widgets request operations from the controller rather than writing directly to SQLite.

Small feature-specific read operations can be exposed as controller extensions when they do not need to enlarge the controller's mutable state. `quizforge_controller_progress.dart` follows that approach for recent-attempt history: it resolves the active profile and delegates the bounded read to the database progress query layer.

The controller also coordinates whole-app backup/restore across three local storage boundaries: SQLite data, application settings, and active-profile selection. Database replacement is transactional, while the controller snapshots all three pre-restore states and performs compensating rollback if a later cross-store step fails. This is intentionally application-layer orchestration rather than forcing platform preference storage into the database transaction model.

### `lib/src/presentation/`

Adaptive Flutter pages and components. Presentation code handles input, navigation, responsive layout, semantics, and user-safe feedback while delegating scoring, validation, persistence, duplicate decisions, backup validation, and persistent history reads.

The Statistics page treats recent attempts as a derived read model. Its history panel caches the current database future and invalidates it when the active profile or completed-quiz count changes, avoiding a FutureBuilder request loop while keeping the view synchronized with meaningful controller state changes.

The Import / export page intentionally separates question-bank interchange from complete local backup. Backup restore requires destructive-replacement confirmation and never treats pasted JSON as trusted merely because it carries the QuizForge format marker.

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

### Native database path

Android, iOS, Windows, macOS, and Linux use `driftDatabase(name: 'quizforge')` through `drift_flutter`'s native implementation.

### Web database path

The same `AppDatabase.defaults()` constructor passes `DriftWebOptions` containing:

- `sqlite3Wasm: Uri.parse('sqlite3.wasm')`;
- `driftWorker: Uri.parse('drift_worker.js')`.

The corresponding files are prepared by `tool/prepare_web_assets.py` from the maintained Drift compatibility line. Build/release workflows validate them in the final Web bundle.

This packaging validation proves that required runtime files exist and have the expected basic format. It does not replace real-browser storage verification: release evidence must still exercise database creation, write/read persistence, refresh/reload behavior, and backup restore.

Recent history does **not** introduce another persistence table. `AttemptSummary` is projected from existing `attempts` rows. This keeps aggregate progress and recent-history metadata tied to the same source of truth and avoids migration work for a feature that needs no new stored fields.

Detailed submitted answers remain in `attempt_answers`; the recent-history projection intentionally excludes those values because the Statistics summary only needs score/progress metadata.

Schema version 1 does not store an explicit answer-position column in `attempt_answers`. Consequently, local backup can preserve each answer record and the stored attempt aggregates, but it cannot reconstruct the original per-question play sequence from database rows. `bestStreak` is preserved as an attempt aggregate and backup validation checks only order-independent streak invariants. A future requirement for exact historical answer order requires an explicit schema migration plus backup-format compatibility work.

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

Backup export uses deterministic ordering for database collections where possible. That ordering is an archive-stability aid and must not be confused with historical interaction order that schema version 1 never stored.

## Import and restore boundaries

JSON and CSV question-bank data are untrusted input. The import path parses, converts to domain models, runs domain validation, partitions duplicates, and only then persists accepted questions. Source size, item count, and domain-content bounds are enforced so local imports remain predictable.

Local backup JSON is a separate untrusted boundary. The codec validates its format/version and primitive structure; the logical snapshot then validates questions, profiles, attempt references/aggregates/scores, bookmarks, and selected-profile membership before database replacement. Unsupported versions fail closed.

The backup archive deliberately contains no credentials or platform signing state. It can contain private user-authored/profile/history data, so raw archive content must never be logged and automatic remote synchronization requires a separate privacy/security architecture decision.

## Backup/restore consistency model

A complete local restore crosses stores that cannot participate in one physical transaction:

1. export the current database logical snapshot;
2. load current settings and active-profile preference;
3. validate and transactionally replace SQLite state;
4. persist restored settings;
5. persist/clear the restored active-profile preference;
6. reload controller state;
7. if a later step fails, attempt to restore the pre-restore database/settings/profile preference and reload again;
8. preserve the original restore failure when rethrowing, while logging rollback failure separately if compensation also fails.

This is a compensating-transaction design. It minimizes partial-state risk but does not claim atomicity across unrelated platform stores. Users are still advised to keep an independent backup before important destructive restores.

## Platform runner and release architecture

Generated platform projects are treated as reproducible shells. Development/CI materializes the applicable runner with Flutter tooling, then applies only QuizForge-specific runtime preparation that cannot be inferred by Flutter itself (currently the Web SQLite WASM/worker assets).

Pull-request build evidence is split by host:

- Ubuntu: Android release + Web release;
- Ubuntu: Linux release;
- Windows: Windows release;
- macOS: macOS release + iOS no-codesign compile.

The tag workflow first verifies the shared source once, then packages all six targets in host-appropriate jobs. GitHub release publication depends on every platform job. This prevents a partial cross-platform tag from being automatically published when one supported platform fails its packaging job.

Distribution signing/provisioning remains separate from application architecture. An unsigned iOS compile or unsigned/notarized desktop bundle must not be described as a signed store artifact.

## Multiplayer boundary

Private-room multiplayer is represented by `PrivateRoomTransport`. The default implementation fails closed and performs no networking. A future implementation must add an ADR covering transport security, privacy, room-code entropy, abuse/rate limits, retention, and threat modeling before it can become enabled product behavior.

## State management

The current app uses a deliberately small `ChangeNotifier` controller instead of a state-management framework. This avoids unnecessary dependencies at the present scale. If state complexity grows enough to warrant a framework, the migration must preserve domain/data isolation and should be recorded in an ADR.

Not every read must become long-lived controller state. The attempt-history feature deliberately keeps its bounded result in the presentation panel's asynchronous read lifecycle because aggregate controller state already supplies the invalidation signal (`activeProfile` and completed quiz count).

## Error handling

Domain/configuration errors use typed exceptions such as `ArgumentError`, `StateError`, and `FormatException` at internal boundaries. Presentation code catches operation failures and renders user-safe feedback. Structured logging must redact user content and secrets before emission.

Recent-history load failures use the same safe localized error surface and do not render raw database/exception details. Backup failures likewise surface generic/localized UI messages while logs record event names, aggregate counts when safe, and error types rather than raw archives.

## Internationalization

English ships first. Product text should continue moving toward externalized localization resources before additional languages are added. Domain values use stable enum names and should not be used directly as final translated labels. Recent-history date/time rendering uses Flutter material localization helpers and existing localized product labels.

ARB catalogs are validated with the stdlib-only `tool/check_arb_catalogs.py` structural/key-parity gate before Flutter localization generation in the maintained CI/local quality sequence. `flutter gen-l10n` remains the authoritative generator compatibility check.

## Architecture decisions and supporting contracts

See `docs/adr/` for durable decisions and their tradeoffs. Additional feature/platform contracts include:

- [`progress-history.md`](progress-history.md)
- [`progress-history-data-contract.md`](progress-history-data-contract.md)
- [`attempt-history-verification.md`](attempt-history-verification.md)
- [`local-backup.md`](local-backup.md)
- [`data-lifecycle.md`](data-lifecycle.md)
- [`platform-support.md`](platform-support.md)

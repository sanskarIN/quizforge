# ADR 0002 — Use Drift with explicit SQLite schema SQL

- Status: Accepted for the baseline
- Date: 2026-08-19

## Context

QuizForge needs reliable local persistence across Flutter targets, transactional writes, schema versioning, testable in-memory database behavior, and enough SQL control for statistics/leaderboards.

The baseline also benefits from avoiding generated source files while the repository is being established.

## Decision

Use Drift as the database connection/query infrastructure while defining schema version 1 with explicit SQL in the migration strategy. Repository methods expose domain models rather than raw rows.

The schema contains questions, profiles, attempts, attempt answers, and bookmarks. Foreign keys are enabled when the database opens. Multi-row question and attempt writes are transactional.

## Consequences

### Positive

- SQLite behavior is explicit and inspectable.
- Drift provides cross-platform connection support and test-friendly executors.
- In-memory integration tests can exercise real SQL.
- Aggregate SQL for progress/leaderboards remains straightforward.
- The repository does not require generated `.g.dart` files for the initial schema.

### Negative

- Handwritten column strings have less compile-time schema checking than generated Drift tables.
- Schema changes require disciplined migration code and tests.
- Cross-platform database runtime behavior, especially web assets, still needs clean-build verification.

## Migration rule

After a public release, never silently rewrite an old `CREATE TABLE` definition and call it a migration. Increment `schemaVersion`, implement an old-to-new migration, and test both fresh creation and upgrade from the previous schema.

## Revisit criteria

Consider converting to generated Drift table definitions if compile-time query/schema safety materially improves maintenance without making migrations or cross-platform builds less reliable. Record that conversion in a new ADR.

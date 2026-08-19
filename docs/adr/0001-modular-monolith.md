# ADR 0001 — Use a modular monolith

- Status: Accepted
- Date: 2026-08-19

## Context

QuizForge needs to support quiz play, authoring, persistence, import/export, statistics, accessibility settings, and future optional multiplayer without turning a small offline product into an unnecessarily distributed system.

Flutter widgets should not become the location for scoring, validation, SQL, or transport rules. At the same time, introducing microservices or a large framework would increase build, deployment, security, and maintenance cost without a demonstrated need.

## Decision

QuizForge will use a modular monolith with four primary layers:

1. domain — product rules and models;
2. data — persistence/import/platform adapters;
3. application — orchestration/state;
4. presentation — Flutter UI.

Dependencies point toward the domain. The domain must remain independent of Flutter UI, Drift, and networking.

## Consequences

### Positive

- Domain logic is fast to test and reusable across UI targets.
- SQLite/network implementation details can change with limited blast radius.
- The repository remains understandable for contributors.
- Cross-platform builds share one product model.
- Optional multiplayer can be added behind an interface instead of infecting offline logic.

### Negative

- The application controller can become too broad if new capabilities are added carelessly.
- Some mapping/boilerplate is required between layers.
- Very large future features may require additional modules/use-case classes.

## Follow-up

Split orchestration into focused controllers/use cases when measured complexity requires it. Do not move to microservices without an explicit product/deployment need and a new ADR.

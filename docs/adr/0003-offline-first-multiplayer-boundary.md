# ADR 0003 — Keep core offline-first and multiplayer behind a disabled transport

- Status: Accepted
- Date: 2026-08-19

## Context

QuizForge's core value does not require internet access or accounts. The product requirements also call for architecture that can support optional private-room multiplayer.

Implementing a backend prematurely would introduce identity, abuse prevention, availability, privacy, data-retention, rate-limit, and deployment concerns before the local product is verified.

## Decision

Core QuizForge remains offline-first. Multiplayer is represented by the `PrivateRoomTransport` interface. The default `DisabledPrivateRoomTransport` performs no networking and fails closed.

No remote transport may become enabled by default without an explicit implementation review.

## Requirements for a future transport

A future multiplayer proposal must document and test:

- room-code generation/entropy and expiry;
- host/member authorization rules;
- replay and duplicate-message handling;
- input/schema validation;
- rate limiting and abuse controls;
- timeout/reconnect behavior;
- encryption in transit through maintained platform libraries;
- data minimization and retention;
- log redaction;
- deletion behavior;
- dependency and endpoint configuration;
- privacy-policy changes;
- offline fallback behavior.

## Consequences

### Positive

- Offline quiz play remains reliable and private.
- No account is forced on users.
- Network complexity cannot affect scoring/domain behavior.
- A transport can be swapped or omitted by platform/distribution.

### Negative

- The baseline does not provide real-time multiplayer.
- A later transport needs integration/end-to-end infrastructure and a security review.

## Revisit criteria

Revisit only when a concrete private-room product requirement, deployment environment, and threat model are available.

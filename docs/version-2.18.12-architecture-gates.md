# QuizForge 2.18.12 Architecture and Dependency Gates

Use these gates before accepting a new dependency, persistence contract, platform adapter, or network capability into the planned 2.18.12 milestone. The goal is to prevent future-version feature work from weakening the verified offline-first, privacy, cross-platform, and release contracts inherited from 2.7.4.

## New package/dependency gate

Before adding a Flutter/Dart package, record:

- capability the package provides;
- why the standard Flutter/Dart libraries or an existing dependency are insufficient;
- current maintenance/release status;
- supported Android/iOS/Web/Windows/macOS/Linux targets relevant to QuizForge;
- license compatibility with the repository;
- native/plugin requirements;
- transitive dependency impact;
- privacy/network behavior;
- known security/advisory history reviewed at the time of adoption;
- expected impact on application size/startup/build complexity;
- fallback behavior on unsupported hosts.

Required actions:

- [ ] Update `pubspec.yaml` intentionally.
- [ ] Regenerate `pubspec.lock` using a supported Flutter resolver.
- [ ] Review the complete lockfile diff.
- [ ] Run dependency review/security tooling.
- [ ] Re-run locked resolution after the lockfile is committed.
- [ ] Add tests around the new integration boundary.

Do not add a package only to avoid a small amount of straightforward maintainable code.

## Platform adapter gate

For file pickers, save dialogs, sharing, clipboard extensions, or platform services:

- [ ] Keep domain codecs and business rules independent from the plugin.
- [ ] Define an application-level interface that can be faked in tests.
- [ ] Handle cancellation separately from failure/corruption.
- [ ] Handle unsupported-platform behavior explicitly.
- [ ] Avoid assuming identical filesystem paths or permission models across targets.
- [ ] Bound imported data before expensive processing where practical.
- [ ] Keep current clipboard fallback where it remains useful.
- [ ] Test adapter success, cancellation, permission failure, malformed content, and platform-error paths.

## Data/schema gate

Before changing SQLite schema:

- state the user-visible/data requirement that cannot be represented safely in schema version 1;
- document the new schema version;
- implement deterministic migration from the immediately previous released schema;
- test clean database creation;
- test old-to-new migration with representative fictional records;
- test foreign-key/reference integrity;
- verify rollback/failure behavior where practical;
- update architecture/data lifecycle/backup docs.

Application SemVer alone is never a reason to increment `schemaVersion`.

## Local-backup format gate

Before changing backup format version 1:

- define why the existing version cannot represent the new state safely;
- specify the new format version and compatibility policy;
- decide whether older archives are migrated, accepted with defaults, or explicitly rejected;
- keep archive validation before destructive restore;
- preserve size/resource bounds;
- preserve answer-scoring/reference/aggregate validation;
- preserve privacy-safe failure/log behavior;
- add old-version compatibility/rejection tests;
- update `docs/local-backup.md`, privacy/data lifecycle docs, changelog, release notes, and verification steps.

Do not silently reinterpret a version-1 archive with incompatible semantics.

## Shareable quiz-pack gate

A content-sharing format must remain separate from complete local backup.

It must never include:

- local profile names or ids unless the format explicitly uses a non-user author identity with clear semantics;
- attempts/history;
- submitted answers from user play history;
- bookmarks tied to local profiles;
- application settings;
- active-profile selection;
- local database/internal-only metadata not needed to represent quiz content.

Required tests:

- round trip;
- unsupported version;
- malformed structure;
- oversized input;
- duplicate ids/content;
- Unicode;
- content-domain validation;
- deterministic encoding where appropriate.

## Statistics/query gate

Before adding a new historical aggregate:

- define the exact user question the metric answers;
- preserve active-profile isolation;
- avoid exposing submitted-answer payloads in summary APIs;
- add deterministic empty/small/large-history tests;
- measure representative query latency;
- add an index/schema change only when measurements justify it;
- ensure clearing local activity/data has documented effects on the metric.

## Localization gate

Before adding a locale:

- [ ] Translation quality can be maintained.
- [ ] ARB key parity passes.
- [ ] Locale metadata is correct.
- [ ] Dates/numbers/percentages use locale-aware presentation where applicable.
- [ ] Long labels/messages are tested at compact widths and large text.
- [ ] RTL layout is explicitly tested if the locale is right-to-left.
- [ ] Domain serialization identifiers remain language-neutral.
- [ ] Error/privacy/security wording remains accurate after translation.

Machine-generated translations must not be treated as reviewed product translations without appropriate review.

## Network/private-room transport gate

Networking remains optional and disabled until this gate is satisfied.

Architecture requirements:

- core quiz engine remains transport-independent;
- offline solo/local flows require no account/network;
- transport boundary remains replaceable/disableable;
- room/session authorization is explicit;
- messages use a versioned validated protocol;
- untrusted remote messages are resource-bounded before processing;
- connection loss cannot corrupt durable local quiz/profile state;
- privacy-sensitive content is not emitted to logs.

Required cases:

- malformed/unknown message;
- oversized message;
- unauthorized participant/action;
- timeout;
- disconnect/reconnect;
- duplicate/replayed message;
- out-of-order state where relevant;
- host/participant divergence;
- transport unavailable;
- abuse/rate limiting where relevant.

An enabled transport requires a security/threat review; protocol tests alone are not sufficient.

## Performance optimization gate

Before adding complexity for performance:

- record a reproducible benchmark/workload;
- record hardware, OS, Flutter/Dart version, dataset size, and methodology;
- measure a baseline;
- identify the actual bottleneck;
- make the smallest justified change;
- record after measurements;
- ensure behavior/data correctness tests remain green.

Do not add pagination, caching, isolates, or database indexes solely from intuition when the existing path has not been measured.

## Cross-platform/release gate

Every 2.18.12 architecture change must consider:

- Android;
- iOS;
- Web;
- Windows;
- macOS;
- Linux;
- canonical identity `io.github.sanskarin.quizforge`;
- deterministic runner/branding generation;
- locked dependency reproducibility;
- release packaging/signing boundaries;
- exact-head CI/build/security evidence.

A feature may be intentionally unavailable on a target only when the fallback/unsupported behavior is documented and the overall supported-platform contract remains truthful.

## Decision record trigger

Create an ADR under `docs/adr/` when a change materially alters one of these long-lived contracts:

- persistence architecture or schema strategy;
- backup/share format compatibility;
- state-management architecture;
- network/multiplayer model;
- platform runner/materialization strategy;
- distribution/signing architecture;
- privacy/security boundary;
- dependency choice that becomes foundational to multiple subsystems.

The ADR should record context, options considered, decision, consequences, compatibility impact, and rollback/migration implications.

**Made by the Sanskar**

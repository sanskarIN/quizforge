# QuizForge Threat Model

This document covers the current offline-first baseline. It must be revised before enabling a real multiplayer/network transport or adding cloud accounts.

## Assets worth protecting

- locally authored/imported question-bank content;
- local profile names and identifiers;
- quiz history, submitted answers, bookmarks, and statistics;
- local settings and accessibility preferences;
- release/build integrity;
- contributor and maintainer credentials that must remain outside the repository.

## Trust boundaries

### Imported question-bank content

JSON/CSV pasted or loaded from outside QuizForge is untrusted. It crosses into the domain/persistence boundary only after parsing, type conversion, validation, and duplicate handling.

### Local database

SQLite is application-managed state, not an authorization boundary against an attacker who already has unrestricted access to the user's device/application storage. QuizForge should still preserve transactional consistency and avoid accidentally exposing stored content through logs/exports.

### Clipboard/export

Copying an export is an explicit user action that moves data outside QuizForge control. Exported question-bank content can then be read by whatever software/platform has clipboard/file access.

### External links

About/Support actions intentionally leave the app to open GitHub, Buy Me a Coffee, or an email handler. QuizForge uses fixed project-owned destinations rather than imported/user-controlled URLs for these actions.

### Build and dependency pipeline

Package resolution, GitHub Actions, dependency updates, and release artifacts are a supply-chain boundary. CI uses pinned major/versioned actions, dependency review, and OSV scanning. Repository branch/security settings remain part of the deployment configuration.

## Current threats and mitigations

### Malformed import data

Threats include crashes, inconsistent questions, malformed quoting, unexpected JSON types, and resource-heavy data.

Mitigations:

- parsers return structured errors instead of intentionally executing imported data;
- domain validation runs before persistence;
- duplicate ids/content are partitioned;
- deterministic malformed-input tests exercise parser entry points;
- future very-large-file work must add measured size/resource controls rather than relying on UI assumptions.

### Partial writes / corrupted relationships

Mitigations:

- foreign keys enabled at database open;
- transactional attempt + answer writes;
- transactional question batch writes;
- transactional destructive maintenance operations;
- explicit schema-version/migration policy.

### Sensitive data in logs

Mitigations:

- structured logger;
- sensitive-key redaction;
- prompt/answer/content/profile-name redaction;
- long/multiline string redaction;
- user-facing errors avoid raw internal exception dumps in major flows.

### Destructive local actions

Mitigations:

- clear-profile and full-reset actions are separated;
- destructive UI requires explicit confirmation;
- at least one local profile must remain during ordinary profile deletion;
- full reset intentionally restores fictional starter data/default profile.

### Accidental quiz loss

Mitigation: configurable confirmation before leaving an in-progress quiz.

### Secret leakage in source control

Mitigations:

- public repository requires no core production credentials;
- `.gitignore` excludes local secret/signing classes of files;
- `.env.example` contains placeholders only;
- documentation explicitly forbids committing keys/tokens/signing material;
- GitHub secret scanning/push-protection is recommended where available.

### Dependency compromise / known vulnerable dependency

Mitigations:

- Dependabot update configuration;
- pull-request dependency review;
- scheduled/push OSV scan;
- small dependency surface;
- release workflow verifies source before packaging.

## Explicitly deferred threat surface: real multiplayer

The default `PrivateRoomTransport` performs no networking. Before a transport is enabled, the threat model must expand to cover at least:

- room-code entropy, enumeration resistance, and expiry;
- host/member authorization;
- message replay/ordering/duplication;
- malformed or oversized messages;
- transport encryption;
- rate limiting and abuse;
- connection exhaustion;
- endpoint/service authentication;
- data retention/deletion;
- logging and telemetry;
- denial of service and reconnect behavior;
- privacy disclosures;
- version/protocol compatibility.

ADR 0003 makes this review a prerequisite rather than an optional cleanup task.

## Out of scope for the current security boundary

QuizForge cannot guarantee confidentiality from a person or process that already controls the user's unlocked device or has unrestricted access to its application storage. Device/OS security remains the outer boundary.

## Review triggers

Update this threat model whenever QuizForge adds:

- network communication;
- cloud sync/accounts;
- authentication;
- file-picker/background filesystem access beyond user-initiated flows;
- analytics/telemetry;
- payments/advertising;
- a new persistent data category;
- a new import format;
- a schema/backup format change;
- a privilege/permission change;
- a new release/distribution channel.

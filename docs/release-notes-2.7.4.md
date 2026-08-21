# QuizForge 2.7.4 Release Notes

Release-candidate date: 2026-08-19

Package version: `2.7.4+1`

Intended public tag after verification: `v2.7.4`

Status: **six-platform release candidate — not yet release-verified**

## Overview

QuizForge 2.7.4 consolidates the maintained offline-first quiz application, authoring tools, local persistence, progress/history features, complete local backup/restore, accessibility-oriented settings, deterministic repository validation, and hardened cross-platform release automation into one release-candidate line.

The supported target set is **Android, iOS, Web, Windows, macOS, and Linux**. The version number identifies the candidate; it does not replace exact-head verification.

## Cross-platform support

The application keeps quiz/domain/controller behavior in shared Dart code and uses Flutter-compatible integration packages instead of OS-specific application forks.

- Android: Flutter UI + native Drift/SQLite persistence.
- iOS: Flutter UI + native Drift/SQLite persistence.
- Web: Flutter Web + explicit Drift Web SQLite WASM/worker configuration.
- Windows: Flutter desktop + native Drift/SQLite persistence.
- macOS: Flutter desktop + native Drift/SQLite persistence.
- Linux: Flutter desktop + native Drift/SQLite persistence.

Standard platform runners are reproducibly materialized with:

```bash
flutter create . --platforms=android,ios,web,windows,macos,linux
```

Web additionally prepares compatible database runtime assets with `tool/prepare_web_assets.py`.

See [`platform-support.md`](platform-support.md).

## User-facing capabilities

- Multiple-choice, true/false, multi-select, and short-answer quizzes.
- Daily quiz, random practice, timed sprint, and configurable custom quiz flows.
- Categories, difficulty, tags, explanations, exact/normalized scoring, streaks, and answer review.
- Local profiles with independent progress, bookmarks, recent attempt history, and a device-local leaderboard.
- Search/filterable question bank and validated question creator.
- JSON/CSV question-bank import/export with duplicate and resource-bound validation.
- Complete versioned local backup/restore for questions, profiles, bookmarks, attempt history/submitted answers, settings, and active-profile selection.
- Light/dark/system themes, large-text behavior, reduced motion, and screen-reader-oriented semantics.
- Offline-first operation without a required account or production credentials.

## Web persistence hardening

The earlier source path could compile for Web without fully specifying the Drift Web runtime. The 2.7.4 candidate now:

- supplies `DriftWebOptions` in `AppDatabase.defaults()`;
- references `sqlite3.wasm` and `drift_worker.js` explicitly;
- provides an idempotent pinned Drift 2.34.3 asset-preparation utility;
- validates the WASM magic header and bounded asset shapes;
- rejects HTML error responses masquerading as JavaScript worker content;
- accepts minified worker JavaScript without depending on human-readable symbol names;
- prepares the Web runtime before Android/Web CI builds;
- verifies the runtime files are present in `build/web` after release compilation;
- repeats the same runtime preparation/verification in the tagged release pipeline.

A packaged-asset check is still not a substitute for real-browser persistence testing. The final release requires database creation/write/read, refresh/reload, and backup-restore smoke evidence.

## Backup and data integrity hardening

Local-backup format version 1 remains independent from application version 2.7.4. The release candidate validates backup archives before destructive restore and includes:

- format/version and archive-size boundaries;
- at least one question, one local profile, and a valid archived active profile;
- question/profile domain validity and duplicate checks;
- valid attempt/profile/question references;
- normal 1–100-question attempt-size bounds;
- count, timestamp, score, and order-independent streak invariants;
- submitted-answer correctness and score re-evaluation using the normal QuizForge `QuizEngine`;
- exact `(profileId, questionId)` bookmark identity without delimiter-composite collisions;
- transactional SQLite replacement;
- compensating controller-level rollback across database/settings/active-profile preference stores;
- destructive-replacement confirmation in the UI;
- privacy guidance that treats complete backup archives as private user data.

Schema version 1 does not store original per-answer sequence. Historical `bestStreak` is therefore preserved from the stored attempt summary and checked only with order-independent invariants rather than reconstructed from reordered export rows.

## Persistence and failure safety

The maintained controller favors persistence-first state changes:

- settings become visible only after durable preference persistence succeeds;
- profile switching persists the target active-profile id before visible state changes;
- failed new-profile activation rolls back the inserted profile;
- active-profile deletion persists a replacement selection before deleting the old profile;
- rollback-aware operations preserve original stack traces;
- reset/restore flows reload durable state rather than leaving stale in-memory state after a partial failure.

## Import and validation hardening

Question-bank parsing/validation includes bounded input size and question counts, strict quote handling for CSV, normalized duplicate protection, bounded question fields, and deterministic malformed-input regression coverage.

The Markdown repository checker also now matches its own regression contract and rejects repository-escaping relative links instead of only checking whether a resolved path exists.

## Recent attempt history

Statistics can show bounded newest-first completed-attempt summaries for the active local profile. The projection includes score, accuracy, question/correct counts, best streak, timestamps, and duration while intentionally omitting submitted-answer content from the summary view.

## Repository and release tooling

Version 2.7.4 adds/maintains deterministic standard-library tooling for:

- local Markdown links/reference targets and repository-boundary validation;
- ARB localization structure/key consistency;
- package/in-app/changelog/versioning release metadata;
- Drift Web database-runtime asset validation.

The maintained local quality sequence and pull-request CI run tool/validator tests before Flutter setup.

The tag workflow is now a gated six-platform release pipeline. It verifies source quality once, then independently packages Android, Web, Linux, Windows, macOS, and an explicitly unsigned iOS compile using host-appropriate runners. Publication waits for every platform job to succeed, downloads all produced artifacts, generates SHA-256 checksums, and only then creates the GitHub release.

The iOS artifact is compile evidence only. It is deliberately named as unsigned and is not represented as an App Store/device-signed package.

## Cross-platform build evidence observed during the audit

An earlier 2.7.4 candidate head, `306bee785cbebbf5b5d6bea875f8d5b4988ea175`, successfully completed:

- Android/Web Build Gate;
- Linux release build;
- Windows release build;
- macOS release build;
- iOS no-codesign release compile;
- Dependency Review;
- OSV Vulnerability Scan;
- Secret Scan.

The main CI job on that head failed before Flutter setup because the Markdown checker implementation had drifted from its regression-test contract. That concrete problem was fixed.

Those successful platform/security runs demonstrate that the previous source line compiled across all six targets, but they do **not** automatically verify the newer Web-persistence/cross-platform-release changes. The exact current head must pass again.

## Security and privacy

- No production credentials are required by the core application.
- Secret/signing files are excluded from version control.
- Full-history Gitleaks scanning is isolated to a dedicated workflow.
- Dependency Review and OSV scanning provide dependency security gates.
- Structured logging redacts secret/authentication fields and avoids raw user-authored/import/backup content.
- Imported question banks and pasted backup archives are treated as untrusted input.
- Web runtime preparation validates downloaded asset structure and uses atomic replacement rather than blindly trusting partial content.

## Compatibility notes

- Application/package version: `2.7.4+1`.
- Public Git release tag: `v2.7.4` once verified.
- In-app public version: `2.7.4`.
- Database schema version: 1; this release-number change does not itself change the SQLite schema.
- Local-backup format version: 1.
- Web runtime assets are tied to the maintained Drift compatibility line and must not be arbitrarily replaced with newer incompatible SQLite WASM assets.
- Question type/difficulty serialized identifiers remain stable domain identifiers rather than translated UI strings.
- The private-room multiplayer transport remains disabled by default and is not presented as an enabled network feature.

## Known release blockers

The following are deliberately not converted into passing claims until evidence exists on the exact final 2.7.4 head:

- final-head GitHub Actions quality/build/security checks;
- generated, reviewed, committed `pubspec.lock` plus enforced locked resolution;
- real-browser Web database create/write/read/refresh/reload and complete-backup restore checks;
- Android complete-backup/persistence smoke restore checks;
- applicable native-desktop backup/persistence smoke checks;
- manual keyboard/focus, screen-reader, large-text, reduced-motion, and contrast review;
- verified screenshots captured from actual built artifacts using fictional/demo data;
- Android/iOS/macOS distribution signing/provisioning/notarization where a release channel requires it.

See [`verification.md`](verification.md) and [`../what_changed.md`](../what_changed.md) for the authoritative evidence/handoff state.

## Release decision

Do not create or advertise `v2.7.4` as a verified release until the applicable blockers above have actually completed successfully on the exact release head. Queued, pending, cancelled, superseded, or unobserved checks are not passes.

**Made by the Sanskar**

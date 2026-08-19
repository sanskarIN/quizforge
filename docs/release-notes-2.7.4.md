# QuizForge 2.7.4 Release Notes

Release-candidate date: 2026-08-19

Package version: `2.7.4+1`

Intended public tag after verification: `v2.7.4`

Status: **release candidate — not yet release-verified**

## Overview

QuizForge 2.7.4 consolidates the maintained offline-first quiz application, authoring tools, local persistence, progress/history features, complete local backup/restore, accessibility-oriented settings, deterministic repository validation, and hardened release automation into one release-candidate line.

The version number identifies the candidate. It does not replace verification: the exact final head still requires the automated and manual evidence recorded in [`verification.md`](verification.md) before `v2.7.4` is described as a verified release.

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

## Recent attempt history

Statistics can show bounded newest-first completed-attempt summaries for the active local profile. The projection includes score, accuracy, question/correct counts, best streak, timestamps, and duration while intentionally omitting submitted-answer content from the summary view.

## Repository and release tooling

Version 2.7.4 adds/maintains deterministic standard-library repository validators for:

- local Markdown links/reference targets;
- ARB localization structure/key consistency;
- package/changelog/versioning release metadata.

`tool/check_release_metadata.py` verifies that `pubspec.yaml`, `CHANGELOG.md`, and `docs/versioning.md` agree on the maintained release identity and that stable-major compatibility documentation is not accidentally left in a pre-1.0 state. Its regression tests include historical zero-major changelog entries.

The maintained local quality sequence and pull-request CI run validator tests/validators before Flutter setup. The tag workflow repeats the repository gates, requires a reviewed committed lockfile, enforces locked dependency resolution, verifies formatting/analysis/tests, builds Android/Web release artifacts, produces checksums, and publishes only from an explicitly pushed matching tag.

## Security and privacy

- No production credentials are required by the core application.
- Secret/signing files are excluded from version control.
- Full-history Gitleaks scanning is isolated to a dedicated workflow.
- Dependency Review and OSV scanning provide dependency security gates.
- Structured logging redacts secret/authentication fields and avoids raw user-authored/import/backup content.
- Imported question banks and pasted backup archives are treated as untrusted input.

## Compatibility notes

- Application/package version: `2.7.4+1`.
- Public Git release tag: `v2.7.4` once verified.
- Database schema version: 1; this release-number change does not itself change the SQLite schema.
- Local-backup format version: 1.
- Question type/difficulty serialized identifiers remain stable domain identifiers rather than translated UI strings.
- The private-room multiplayer transport remains disabled by default and is not presented as an enabled network feature.

## Known release blockers

The following are deliberately not converted into passing claims until evidence exists on the exact final 2.7.4 head:

- final-head GitHub Actions quality/build/security checks;
- generated, reviewed, committed `pubspec.lock` plus enforced locked resolution;
- Android/Web database and complete-backup smoke restore checks;
- applicable native-desktop backup smoke check;
- manual keyboard/focus, screen-reader, large-text, reduced-motion, and contrast review;
- verified screenshots captured from actual built artifacts using fictional/demo data;
- distribution signing/provisioning where a store/channel requires it.

See [`verification.md`](verification.md) and [`../what_changed.md`](../what_changed.md) for the authoritative evidence/handoff state.

## Release decision

Do not create or advertise `v2.7.4` as a verified release until the applicable blockers above have actually completed successfully on the exact release head. Queued, pending, cancelled, superseded, or unobserved checks are not passes.

**Made by the Sanskar**

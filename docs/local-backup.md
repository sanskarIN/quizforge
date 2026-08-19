# Local Backup and Restore

QuizForge supports a **logical, versioned local backup** for users who want to preserve the complete offline application state without requiring a cloud account.

This feature is separate from the JSON/CSV question-bank interchange format. Question-bank export is intended for quiz content exchange; local backup is intended for whole-app recovery and migration.

## What a local backup contains

Backup format version 1 can contain:

- all local questions, including choices, accepted answers, categories, difficulty, tags, explanations, and optional time limits;
- all local profiles and their display names;
- quiz attempts and per-question submitted answers;
- bookmarks;
- appearance/accessibility/application settings;
- the selected local profile;
- a UTC archive-creation timestamp.

Because profile names, authored questions, and submitted answers can be present, a backup archive should be treated as **private user data**.

## Minimum restorable state

Version 1 describes a complete initialized QuizForge state, not an arbitrary partial database dump. A valid whole-app archive therefore requires:

- at least one valid question;
- at least one valid local profile;
- a non-null active-profile id that references one of the archived profiles.

These requirements match normal initialized application invariants. QuizForge seeds starter questions when the question bank is empty, creates a default profile when no profile exists, and selects a local profile during initialization. Accepting a hand-crafted archive that omitted those required records would make restore silently create/select state that was not actually present in the archive.

Failing closed is more predictable: an archive either describes a directly restorable whole-app state or is rejected before destructive replacement begins.

## What it does not contain

The current logical backup does not include:

- operating-system credentials or keychain data;
- signing/provisioning credentials;
- analytics identifiers, because the baseline application does not include behavioral analytics;
- remote account/cloud state, because QuizForge does not require a cloud account;
- generated platform caches or application binaries;
- the original per-question sequence inside a completed attempt, because schema version 1 stores attempt-answer rows by attempt/question identity rather than a separate answer-position column.

Attempt-level values that depend on original play order, such as `bestStreak`, are therefore preserved from the stored attempt summary rather than recomputed from exported answer-row order. If a future product feature requires exact historical answer sequence, the database schema and backup format must add explicit order metadata through a tested migration/versioning change.

## Format identity

The top-level archive is JSON and identifies itself with:

- `format`: `quizforge-local-backup`
- `version`: `1`
- `createdAt`: ISO-8601 timestamp

The archive is deliberately versioned so a future incompatible layout can fail closed rather than being silently misread.

## Archive size boundary

Version 1 imposes a maximum supported source length before parsing. The same boundary is applied after encoding: if the complete generated archive would exceed the supported restore limit, export fails instead of copying an archive that the same QuizForge version would immediately reject solely for size.

This is a local in-process safety boundary, not a claim that every archive below the limit is equally inexpensive on every device. Representative large-bank performance should still be profiled before changing the limit.

## Validation before restore

Restore treats the pasted archive as untrusted data. Before replacing current database state, QuizForge validates at least:

- maximum archive text size;
- JSON structure and required primitive types;
- backup format and version;
- required minimum question/profile/active-profile state;
- question domain validity;
- duplicate question ids and duplicate normalized question content;
- local profile validity and duplicate profile ids;
- attempt profile/question references;
- attempt completion timestamps;
- question/correct-count consistency;
- order-independent best-streak bounds against question/correct counts;
- finite/non-negative score values and total-score consistency;
- duplicate question answers inside one attempt;
- bookmark profile/question references and duplicate bookmarks;
- active-profile reference validity.

If validation fails, the archive is rejected before the destructive database replacement begins.

## Restore transaction and rollback boundary

Database replacement itself runs inside a Drift transaction. Questions, profiles, attempts, attempt answers, and bookmarks are rebuilt only from a validated logical snapshot.

The controller also snapshots the current database state, settings, and selected-profile preference before starting the cross-store restore. If a later settings/preference/reload step fails, QuizForge attempts to restore all three previous states and reload the controller.

This rollback path reduces the chance of ending in a partially restored state, but it is not a substitute for keeping an independent backup before an important or destructive migration.

## User workflow

1. Open **Import / export**.
2. Under **Local backup**, choose **Copy local backup**.
3. Store the copied JSON in a location you control.
4. To restore, paste a supported QuizForge local-backup JSON archive into the restore field.
5. Choose **Restore backup**.
6. Review the destructive-replacement confirmation.
7. Confirm only when you intend to replace current local questions, profiles, bookmarks, history, settings, and selected-profile state.

## Question-bank export versus local backup

| Capability | JSON/CSV question bank | Local backup |
|---|---:|---:|
| Questions | yes | yes |
| Profiles | no | yes |
| Bookmarks | no | yes |
| Quiz history | no | yes |
| Submitted answers | no | yes |
| Settings | no | yes |
| Active profile | no | yes |
| Intended for content sharing | yes | no |
| Intended for full local recovery | no | yes |

For quiz-content interchange, prefer the documented question-bank format in [`question-bank-format.md`](question-bank-format.md). For whole-app preservation, use local backup.

## Compatibility policy

Backup version 1 must continue to decode with version-1 semantics for the life of releases that claim support for it. A future breaking backup change should:

1. use a new format version;
2. retain a tested migration/conversion path when practical;
3. reject unsupported versions with a clear error;
4. update tests, `CHANGELOG.md`, release notes, privacy documentation, and this document.

## Security and privacy guidance

- Do not publish real user backup archives in issues or pull requests.
- Use fictional/demo data for tests and documentation examples.
- Never log raw backup payloads.
- Do not add automatic network upload/sync without a separate privacy/security design review.
- Treat clipboard contents as user-controlled and potentially visible to other software according to the operating system's clipboard policy.

See [`../PRIVACY.md`](../PRIVACY.md), [`../SECURITY.md`](../SECURITY.md), and [`data-lifecycle.md`](data-lifecycle.md).

## Verification requirements

Before a release candidate is described as backup-verified, the exact candidate should demonstrate:

- codec round-trip tests;
- invalid/dangling-reference rejection tests;
- required minimum-state rejection tests;
- order-independent attempt-summary validation regression coverage;
- database export/reset/restore integration coverage;
- controller rollback coverage for cross-store failures;
- widget coverage for confirmation before restore;
- a clean Android and Web restore smoke test using fictional data;
- at least one native-desktop restore smoke test on an applicable host when that target is part of the release.

Record actual evidence in [`verification.md`](verification.md); do not convert planned checks into passing claims without observing them.

**Made by the Sanskar**

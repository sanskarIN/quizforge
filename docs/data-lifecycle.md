# Local Data Lifecycle

QuizForge is offline-first. This document describes where current application data originates, how it is stored, how it can leave the application boundary, how local backups work, and how data is deleted.

## Data categories

### Question bank

Contains question ids, types, prompts, choices, accepted/correct answers, categories, difficulties, tags, explanations, and optional time limits.

Sources:

- fictional starter fixtures;
- user-authored questions;
- explicit JSON/CSV imports;
- an explicit full local-backup restore.

Storage: SQLite `questions` table.

Export: explicit JSON/CSV question-bank copy/export or explicit full local-backup copy.

Deletion: full local-data reset removes custom/imported data and starter data, after which initialization restores the deterministic starter bank.

### Local profiles

Contains a local profile id, display name, and creation timestamp.

Storage: SQLite `profiles` table. The currently selected profile id is stored as a non-sensitive preference.

Deletion:

- ordinary profile delete removes that profile and cascades its dependent activity/bookmarks;
- the UI prevents ordinary deletion of the final remaining profile;
- full reset removes every profile and then restores a default local profile during initialization.

### Quiz attempts and submitted answers

Contains timestamps/duration, scores, streak data, question references, submitted answer sets, and correct/incorrect result flags.

Storage: SQLite `attempts` and `attempt_answers` tables.

Deletion:

- clear active profile activity removes that profile's attempts and bookmarks;
- deleting a profile removes dependent activity;
- full reset removes all activity.

These records are used for local progress/category statistics and the local leaderboard.

### Bookmarks

Contains profile id + question id relationships and creation timestamps.

Storage: SQLite `bookmarks` table.

Deletion: toggle bookmark, clear active-profile activity, profile deletion, or full reset.

### Preferences

Contains appearance/accessibility settings, onboarding completion, and active local profile id.

Storage: platform preference storage through the asynchronous Shared Preferences API.

Full local-data reset removes QuizForge-managed appearance/accessibility and active-profile preference keys. Onboarding completion is intentionally separate from the backup/reset payload so restoring ordinary quiz data does not unexpectedly rerun onboarding or overwrite a first-run decision.

## Data movement

Core QuizForge does not intentionally send quiz/profile data to a QuizForge backend.

Data can cross the application boundary through explicit actions:

- copying/exporting a question bank;
- pasting/importing a question bank;
- copying a full local-backup archive;
- pasting/restoring a full local-backup archive;
- opening fixed project/support/funding URLs;
- composing support/business email through the platform mail handler.

A future networking or cloud feature requires an updated privacy policy, threat model, data lifecycle, and architecture decision before release.

## Full local backup

QuizForge supports a versioned logical JSON backup format named `quizforge-local-backup`, currently format version `1`.

The backup contains:

- questions, including authored/imported content and correct answers;
- local profile ids, display names, and creation timestamps;
- quiz-attempt summaries and submitted answer sets;
- bookmarks;
- appearance/accessibility settings;
- the active local-profile selection.

It intentionally does **not** include unrelated device data, credentials, signing material, operating-system secrets, analytics identifiers, or onboarding-completion state.

Backup archives can contain private/user-authored data. Treat them like personal files: store them only in locations you trust, review them before sharing, and do not post them publicly unless you are comfortable disclosing their content.

### Backup validation and restore behavior

Before a restore modifies current state, QuizForge parses and validates the complete archive. Validation covers format/version, field types, question/profile validity, duplicate identifiers/content, profile/question references, attempt consistency, bookmark references, and supported settings values. Oversized archive text is rejected before JSON parsing.

Database restoration is a single SQLite transaction. Questions, profiles, attempts, submitted answers, and bookmarks are replaced together so a database-level failure rolls back rather than leaving a partially restored database.

The controller additionally snapshots the current logical database state plus settings and active-profile preference before restore. If applying the restored preferences/settings or reinitializing fails, it makes a best-effort rollback to that previous snapshot and records only redacted error metadata through structured logging.

A successful restore is replacement semantics, not a merge. Export the current state first if it may need to be recovered later.

### Backup format compatibility

The format has an explicit version number. Readers reject unsupported versions rather than guessing at future/older structures. A future incompatible format change must introduce documented migration/compatibility handling instead of silently reinterpreting archives.

The current database schema does not store the original per-attempt answer ordering as a separate persisted field. Backup preserves the stored attempt aggregate (including `bestStreak`) and every stored answer/result, but should not be treated as an archival representation of UI interaction order that the database itself never recorded.

## Transactions and referential integrity

Foreign keys are enabled when SQLite opens. Multi-row writes that must remain consistent are transactional. Destructive maintenance operations and backup database replacement are grouped transactionally.

Released schema changes must use migrations and preserve or explicitly convert existing data rather than silently recreating the database.

## Logging

Structured logs are not a second persistence system for raw quiz data. The application logger redacts secret/credential fields and user-content fields such as prompts, answers, imported/exported content, profile names, and email values. Long/multiline strings are also redacted.

Backup content itself is never written to structured logs. Backup operations log only bounded metadata such as record counts and error types.

## User expectations

Because local operating-system storage is the primary store, uninstalling the application or clearing its app data can remove QuizForge state that has not been separately exported. A copied QuizForge local-backup archive is the supported portable recovery format for the local data listed above; JSON/CSV question-bank exchange remains the narrower format for sharing only questions.

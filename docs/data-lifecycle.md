# Local Data Lifecycle

QuizForge is offline-first. This document describes where current application data originates, how it is stored, how it can leave the application boundary, how complete local backups behave, and how data is deleted.

## Data categories

### Question bank

Contains question ids, types, prompts, choices, accepted/correct answers, categories, difficulties, tags, explanations, and optional time limits.

Sources:

- fictional starter fixtures;
- user-authored questions;
- explicit JSON/CSV imports;
- explicit local-backup restore.

Storage: SQLite `questions` table.

Export: explicit JSON/CSV question-bank copy/export workflow, or as part of a complete local backup.

Deletion: full local-data reset removes custom/imported data and starter data, after which initialization restores the deterministic starter bank.

### Local profiles

Contains a local profile id, display name, and creation timestamp.

Storage: SQLite `profiles` table. The currently selected profile id is stored as a non-sensitive application preference, although the display name itself is user-authored data and is treated as private when exported in a backup.

Deletion:

- ordinary profile delete removes that profile and cascades its dependent activity/bookmarks;
- when the active profile is deleted, the replacement profile preference is persisted before the database deletion is attempted;
- the UI prevents ordinary deletion of the final remaining profile;
- full reset removes every profile and then restores a default local profile during initialization.

Creation/switching use persistence-first ordering so a failed active-profile preference write does not make the UI claim another profile is active. A failed new-profile activation attempts to remove the newly inserted profile before reporting the failure.

### Quiz attempts and submitted answers

Contains timestamps/duration, scores, streak data, question references, submitted answer sets, and correct/incorrect result flags.

Storage: SQLite `attempts` and `attempt_answers` tables.

Deletion:

- clear active profile activity removes that profile's attempts and bookmarks;
- deleting a profile removes dependent activity;
- full reset removes all activity.

These records are used for local progress/category statistics, recent-attempt summaries, and the local leaderboard. After a successful attempt/activity write, derived progress/leaderboard refreshes are best-effort reads: a transient refresh error is logged rather than incorrectly reporting the already-persisted write as unsaved.

Schema version 1 does not store an explicit sequence/position column for `attempt_answers`. A local backup therefore preserves attempt-level aggregates such as `bestStreak` directly and exports answer rows in deterministic question-id order. It must not pretend that deterministic export ordering reconstructs the original play sequence.

### Bookmarks

Contains profile id + question id relationships and creation timestamps.

Storage: SQLite `bookmarks` table.

Deletion: toggle bookmark, clear active-profile activity, profile deletion, or full reset.

### Preferences

Contains appearance/accessibility settings, onboarding completion, and active local profile id.

Storage: platform preference storage through the asynchronous Shared Preferences API.

Deletion: full reset removes QuizForge-managed setting/profile preference keys; onboarding persistence remains a separate first-run preference unless specifically reset by an onboarding-reset control.

Settings are serialized as one versioned preference payload for atomic logical updates. Legacy per-setting keys remain readable for migration and are removed by reset.

## Full reset failure semantics

SQLite state, app settings, and the active-profile preference live in separate local stores, so one cross-store reset cannot be a single SQLite transaction. QuizForge therefore treats reset as a coordinated best-effort operation with explicit recovery:

1. attempt the database reset;
2. attempt the settings reset even if the database reset failed;
3. attempt the active-profile preference reset even if an earlier store failed;
4. clear stale in-memory state;
5. reload the controller from the stores that actually remain;
6. report the first reset failure after reload rather than leaving pre-reset state visible.

This means a partial platform-storage failure can produce a partially reset durable state, but the running controller is re-synchronized to that durable state before the failure is surfaced. The application does not claim that a failed reset completed successfully.

## Complete local backup and restore

QuizForge supports a versioned logical backup distinct from the question-bank interchange formats. Version 1 can contain:

- questions;
- local profiles;
- quiz attempts and submitted answers;
- bookmarks;
- settings;
- active-profile selection;
- an archive creation timestamp.

The archive does not include credentials, signing keys, unrelated operating-system data, remote account state, or generated application caches.

Restore treats the entire archive as untrusted input. Validation occurs before destructive database replacement and covers format/version, record types, question/profile validity, duplicate content/identifiers, object references, attempt aggregate invariants, score finiteness/consistency, bookmarks, and selected-profile validity.

Database replacement runs inside a Drift transaction. Because database state, settings, and active-profile selection live in separate stores, the controller also captures a pre-restore logical snapshot of all three. If a later settings/preference/reload step fails, it attempts to restore the previous database snapshot, settings, and active-profile preference, then reloads controller state. Rollback failure is logged as a distinct event without logging raw user backup data.

See [`local-backup.md`](local-backup.md) for the format contract, limitations, compatibility rules, and release verification requirements.

## Data movement

Core QuizForge does not intentionally send quiz/profile data to a QuizForge backend.

Data can cross the application boundary through explicit actions:

- copying/exporting a question bank;
- pasting/importing a question bank;
- copying a complete local backup to the clipboard;
- pasting/restoring a complete local backup;
- opening fixed project/support/funding URLs;
- composing support/business email through the platform mail handler.

Clipboard read/write failures are handled as platform-operation failures and do not crash the import/export screen or log clipboard contents.

A future networking or cloud feature requires an updated privacy policy, threat model, data lifecycle, and architecture decision before release.

## Transactions and referential integrity

Foreign keys are enabled when SQLite opens. Multi-row writes that must remain consistent are transactional. Destructive database maintenance and database backup restore operations are also grouped transactionally.

Released schema changes must use migrations and preserve or explicitly convert existing data rather than silently recreating the database. A schema change that introduces answer-order persistence must also define how backup format compatibility/migration handles the new field.

## Logging

Structured logs are not a second persistence system for raw quiz data. The application logger redacts secret/credential fields and user-content fields such as prompts, answers, imported/exported content, profile names, and email values. Long/multiline strings are also redacted.

Backup operations log event names, aggregate record counts, and error types; raw backup JSON must not be logged.

## Portable data scopes

QuizForge now has two intentionally different portable formats:

1. **Question-bank JSON/CSV** — content interchange for questions only.
2. **Local backup JSON** — versioned whole-app local-state preservation/recovery.

A question-bank export is suitable for sharing quiz content after review. A complete local backup can contain profile names and submitted answers and should be treated as private user data rather than a shareable quiz pack.

## User expectations

Because local operating-system storage is the primary store, uninstalling the application or clearing its app data can remove QuizForge state that has not been separately backed up. Clipboard contents are also subject to the operating system's clipboard behavior after QuizForge copies an export.

Users who rely on local data should keep backup archives in a storage location they control. Before a destructive restore, creating a fresh backup of the current state is recommended when rollback/recovery may be needed.

The privacy, support, backup, testing, and release documentation must remain consistent with these behaviors.

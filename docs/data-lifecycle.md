# Local Data Lifecycle

QuizForge is offline-first. This document describes where current application data originates, how it is stored, how it can leave the application boundary, and how it is deleted.

## Data categories

### Question bank

Contains question ids, types, prompts, choices, accepted/correct answers, categories, difficulties, tags, explanations, and optional time limits.

Sources:

- fictional starter fixtures;
- user-authored questions;
- explicit JSON/CSV imports.

Storage: SQLite `questions` table.

Export: explicit JSON/CSV copy/export workflow.

Deletion: full local-data reset removes custom/imported data and starter data, after which initialization restores the deterministic starter bank.

### Local profiles

Contains a local profile id, display name, and creation timestamp.

Storage: SQLite `profiles` table. The currently selected profile id is stored as a non-sensitive preference.

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

These records are used for local progress/category statistics and the local leaderboard. After a successful attempt/activity write, derived progress/leaderboard refreshes are best-effort reads: a transient refresh error is logged rather than incorrectly reporting the already-persisted write as unsaved.

### Bookmarks

Contains profile id + question id relationships and creation timestamps.

Storage: SQLite `bookmarks` table.

Deletion: toggle bookmark, clear active-profile activity, profile deletion, or full reset.

### Preferences

Contains appearance/accessibility settings, onboarding completion, and active local profile id.

Storage: platform preference storage through the asynchronous Shared Preferences API.

Deletion: full reset removes QuizForge-managed setting/profile preference keys; onboarding persistence remains a separate first-run preference unless specifically reset by a future onboarding-reset control.

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

## Data movement

Core QuizForge does not intentionally send quiz/profile data to a QuizForge backend.

Data can cross the application boundary through explicit actions:

- copying/exporting a question bank;
- pasting/importing a question bank;
- opening fixed project/support/funding URLs;
- composing support/business email through the platform mail handler.

Clipboard read/write failures are handled as platform-operation failures and do not crash the import/export screen or log clipboard contents.

A future networking or cloud feature requires an updated privacy policy, threat model, data lifecycle, and architecture decision before release.

## Transactions and referential integrity

Foreign keys are enabled when SQLite opens. Multi-row writes that must remain consistent are transactional. Destructive database maintenance operations are also grouped transactionally.

Released schema changes must use migrations and preserve or explicitly convert existing data rather than silently recreating the database.

## Logging

Structured logs are not a second persistence system for raw quiz data. The application logger redacts secret/credential fields and user-content fields such as prompts, answers, imported/exported content, profile names, and email values. Long/multiline strings are also redacted.

## Backup scope

The current supported portable interchange format is the **question bank**. It does not claim to be a full-device backup of profiles, attempt history, bookmarks, or settings.

If a future full backup/restore feature is added, it must:

- version its format;
- validate every imported record;
- preserve referential integrity;
- define conflict/duplicate rules;
- use atomic restore semantics or safe rollback;
- document which private/local data is included;
- never contain signing credentials or unrelated device data.

## User expectations

Because local operating-system storage is the primary store, uninstalling the application or clearing its app data can remove QuizForge state that has not been separately exported. The privacy/support documentation should remain consistent with this behavior.

# Local Progress and Attempt History

QuizForge keeps progress data on-device. The statistics experience is built from the same local SQLite attempt records that already power aggregate accuracy, streak, category performance, and the local leaderboard.

## Recent attempt history

The Statistics screen now shows the latest completed attempts for the active local profile. Each entry includes:

- completion date and local time;
- correct answers versus question count;
- best streak for that attempt;
- elapsed attempt time;
- attempt accuracy.

The list is intentionally bounded. `AppDatabaseProgressQueries.loadRecentAttempts()` defaults to the latest 10 attempts and accepts explicit limits from 1 through 100. The SQL query orders by `completed_at DESC, id DESC`, so equal timestamps still have deterministic newest-first ordering.

## Data source

Recent history is derived from the existing `attempts` table. No duplicate history table or cached copy is introduced. This keeps aggregate statistics and recent-attempt details tied to one source of truth.

The public domain projection is `AttemptSummary` in `lib/src/domain/profile.dart`. It exposes safe computed values for `accuracy` and `duration` while retaining the persisted score, streak, question count, and timestamps.

## UI refresh behavior

The recent-attempt panel caches its current load rather than creating a new database future on every Flutter build. Its refresh token combines the active profile id and aggregate quiz count. It reloads when:

- the active profile changes; or
- a completed quiz changes that profile's quiz count.

This avoids a `FutureBuilder` reload loop while keeping newly completed attempts visible when the Statistics screen rebuilds.

## Deletion behavior

The existing **Clear active profile activity** action deletes attempts for the active profile. Recent history therefore becomes empty together with aggregate progress and bookmarks.

Deleting a profile removes its attempts through the existing foreign-key cascade. Resetting all local data also removes every attempt before recreating starter state.

## Privacy boundary

Attempt history remains local application data. The recent-history UI does not add networking, analytics, telemetry, or cloud synchronization. Question answer contents are not displayed in the history list; detailed answer review remains part of the immediate quiz review flow.

## Verification

Automated coverage includes:

- persisted attempt projection fields;
- newest-first ordering;
- bounded query limits;
- removal after clearing profile activity;
- Statistics-screen rendering of a persisted recent attempt.

Release candidates must still pass the repository's full Flutter/SQLite verification gates on the exact release head.

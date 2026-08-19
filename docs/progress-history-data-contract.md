# Attempt History Data Contract

`AttemptSummary` is a read-only projection of the existing local `attempts` table. It is intentionally smaller than a full quiz result because the Statistics screen needs summary metadata, not submitted answers.

## Fields

| Field | Source | Meaning |
| --- | --- | --- |
| `id` | `attempts.id` | Stable local attempt row id. |
| `startedAt` | `attempts.started_at` | Local attempt start timestamp. |
| `completedAt` | `attempts.completed_at` | Local attempt completion timestamp. |
| `correctCount` | `attempts.correct_count` | Number of correct evaluations. |
| `questionCount` | `attempts.question_count` | Number of evaluated questions. |
| `bestStreak` | `attempts.best_streak` | Best consecutive-correct streak in the attempt. |
| `earnedScore` | `attempts.earned_score` | Persisted numeric score. |
| `accuracy` | computed | `correctCount / questionCount * 100`, with zero for an empty attempt. |
| `duration` | computed | `completedAt - startedAt`. |

## Ordering and bounds

`loadRecentAttempts(profileId, limit: ...)` uses:

```sql
ORDER BY completed_at DESC, id DESC
LIMIT ?
```

The second ordering key makes equal completion timestamps deterministic. The public query limit is constrained to 1–100 to prevent accidentally turning a compact Statistics panel into an unbounded database read.

## Compatibility

No database schema change is required. This feature only adds a query/projection over schema version 1. Therefore it does not create a migration requirement.

## Privacy

The projection deliberately omits `attempt_answers.submitted_json`. Statistics history can show score/progress metadata without exposing the text or choices a user submitted.

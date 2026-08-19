import 'package:drift/drift.dart';

import '../domain/profile.dart';
import 'app_database.dart';

extension AppDatabaseProgressQueries on AppDatabase {
  Future<List<CategoryProgress>> loadCategoryProgress(String profileId) async {
    final List<QueryRow> rows = await customSelect(
      '''
SELECT
  q.category AS category,
  COUNT(*) AS question_count,
  COALESCE(SUM(aa.is_correct), 0) AS correct_count
FROM attempt_answers aa
JOIN attempts a ON a.id = aa.attempt_id
JOIN questions q ON q.id = aa.question_id
WHERE a.profile_id = ?
GROUP BY q.category
ORDER BY question_count DESC, q.category COLLATE NOCASE ASC
''',
      variables: <Variable<Object>>[Variable<String>(profileId)],
    ).get();

    return rows.map((QueryRow row) {
      return CategoryProgress(
        category: row.read<String>('category'),
        questionCount: row.read<int>('question_count'),
        correctCount: row.read<int>('correct_count'),
      );
    }).toList(growable: false);
  }

  Future<List<AttemptSummary>> loadRecentAttempts(
    String profileId, {
    int limit = 10,
  }) async {
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 100.');
    }
    final List<QueryRow> rows = await customSelect(
      '''
SELECT
  id,
  started_at,
  completed_at,
  correct_count,
  question_count,
  best_streak,
  earned_score
FROM attempts
WHERE profile_id = ?
ORDER BY completed_at DESC, id DESC
LIMIT ?
''',
      variables: <Variable<Object>>[
        Variable<String>(profileId),
        Variable<int>(limit),
      ],
    ).get();

    return rows.map((QueryRow row) {
      return AttemptSummary(
        id: row.read<int>('id'),
        startedAt: DateTime.fromMillisecondsSinceEpoch(row.read<int>('started_at')),
        completedAt:
            DateTime.fromMillisecondsSinceEpoch(row.read<int>('completed_at')),
        correctCount: row.read<int>('correct_count'),
        questionCount: row.read<int>('question_count'),
        bestStreak: row.read<int>('best_streak'),
        earnedScore: row.read<double>('earned_score'),
      );
    }).toList(growable: false);
  }
}

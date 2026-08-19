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
}

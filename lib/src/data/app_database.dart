import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/profile.dart';
import '../domain/question.dart';
import '../domain/quiz_result.dart';

final class AppDatabase extends GeneratedDatabase {
  AppDatabase(QueryExecutor executor) : super(executor);

  AppDatabase.defaults()
      : super(
          driftDatabase(
            name: 'quizforge',
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  @override
  int get schemaVersion => 1;

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      const <TableInfo<Table, dynamic>>[];

  @override
  Iterable<DatabaseSchemaEntity> get allSchemaEntities =>
      const <DatabaseSchemaEntity>[];

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator migrator) async {
          await customStatement('''
CREATE TABLE questions (
  id TEXT PRIMARY KEY NOT NULL,
  type TEXT NOT NULL,
  prompt TEXT NOT NULL,
  choices_json TEXT NOT NULL,
  correct_answers_json TEXT NOT NULL,
  category TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  tags_json TEXT NOT NULL,
  explanation TEXT NOT NULL,
  time_limit_seconds INTEGER,
  fingerprint TEXT NOT NULL UNIQUE,
  created_at INTEGER NOT NULL
)
''');
          await customStatement(
            'CREATE INDEX idx_questions_category ON questions(category)',
          );
          await customStatement(
            'CREATE INDEX idx_questions_difficulty ON questions(difficulty)',
          );
          await customStatement('''
CREATE TABLE profiles (
  id TEXT PRIMARY KEY NOT NULL,
  display_name TEXT NOT NULL,
  created_at INTEGER NOT NULL
)
''');
          await customStatement('''
CREATE TABLE attempts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id TEXT NOT NULL,
  started_at INTEGER NOT NULL,
  completed_at INTEGER NOT NULL,
  correct_count INTEGER NOT NULL,
  question_count INTEGER NOT NULL,
  best_streak INTEGER NOT NULL,
  earned_score REAL NOT NULL,
  FOREIGN KEY(profile_id) REFERENCES profiles(id) ON DELETE CASCADE
)
''');
          await customStatement(
            'CREATE INDEX idx_attempts_profile ON attempts(profile_id, completed_at)',
          );
          await customStatement('''
CREATE TABLE attempt_answers (
  attempt_id INTEGER NOT NULL,
  question_id TEXT NOT NULL,
  submitted_json TEXT NOT NULL,
  is_correct INTEGER NOT NULL,
  score REAL NOT NULL,
  PRIMARY KEY(attempt_id, question_id),
  FOREIGN KEY(attempt_id) REFERENCES attempts(id) ON DELETE CASCADE,
  FOREIGN KEY(question_id) REFERENCES questions(id) ON DELETE CASCADE
)
''');
          await customStatement('''
CREATE TABLE bookmarks (
  profile_id TEXT NOT NULL,
  question_id TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  PRIMARY KEY(profile_id, question_id),
  FOREIGN KEY(profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
  FOREIGN KEY(question_id) REFERENCES questions(id) ON DELETE CASCADE
)
''');
        },
        beforeOpen: (OpeningDetails details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> upsertProfile(PlayerProfile profile) async {
    final List<String> errors = profile.validate();
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join(' '));
    }
    await customStatement(
      '''
INSERT INTO profiles(id, display_name, created_at)
VALUES(?, ?, ?)
ON CONFLICT(id) DO UPDATE SET display_name = excluded.display_name
''',
      <Object?>[
        profile.id,
        profile.displayName.trim(),
        (profile.createdAt ?? DateTime.now()).millisecondsSinceEpoch,
      ],
    );
  }

  Future<List<PlayerProfile>> loadProfiles() async {
    final List<QueryRow> rows = await customSelect(
      'SELECT id, display_name, created_at FROM profiles ORDER BY created_at ASC',
    ).get();
    return rows.map((QueryRow row) {
      return PlayerProfile(
        id: row.read<String>('id'),
        displayName: row.read<String>('display_name'),
        createdAt: DateTime.fromMillisecondsSinceEpoch(row.read<int>('created_at')),
      );
    }).toList(growable: false);
  }

  Future<void> upsertQuestions(Iterable<Question> questions) async {
    await transaction(() async {
      for (final Question question in questions) {
        final List<String> errors = question.validate();
        if (errors.isNotEmpty) {
          throw ArgumentError('Invalid question ${question.id}: ${errors.join(' ')}');
        }
        await customStatement(
          '''
INSERT INTO questions(
  id, type, prompt, choices_json, correct_answers_json, category, difficulty,
  tags_json, explanation, time_limit_seconds, fingerprint, created_at
) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT(id) DO UPDATE SET
  type = excluded.type,
  prompt = excluded.prompt,
  choices_json = excluded.choices_json,
  correct_answers_json = excluded.correct_answers_json,
  category = excluded.category,
  difficulty = excluded.difficulty,
  tags_json = excluded.tags_json,
  explanation = excluded.explanation,
  time_limit_seconds = excluded.time_limit_seconds,
  fingerprint = excluded.fingerprint
''',
          <Object?>[
            question.id,
            question.type.name,
            question.prompt,
            jsonEncode(question.choices),
            jsonEncode(question.correctAnswers.toList()..sort()),
            question.category,
            question.difficulty.name,
            jsonEncode(question.tags),
            question.explanation,
            question.timeLimitSeconds,
            question.fingerprint,
            DateTime.now().millisecondsSinceEpoch,
          ],
        );
      }
    });
  }

  Future<List<Question>> loadQuestions() async {
    final List<QueryRow> rows = await customSelect(
      '''
SELECT id, type, prompt, choices_json, correct_answers_json, category,
       difficulty, tags_json, explanation, time_limit_seconds
FROM questions
ORDER BY category COLLATE NOCASE, prompt COLLATE NOCASE
''',
    ).get();
    return rows.map(_questionFromRow).toList(growable: false);
  }

  Future<int> saveAttempt(String profileId, QuizResult result) async {
    return transaction(() async {
      final int attemptId = await customInsert(
        '''
INSERT INTO attempts(
  profile_id, started_at, completed_at, correct_count, question_count,
  best_streak, earned_score
) VALUES(?, ?, ?, ?, ?, ?, ?)
''',
        variables: <Variable<Object>>[
          Variable<String>(profileId),
          Variable<int>(result.startedAt.millisecondsSinceEpoch),
          Variable<int>(result.completedAt.millisecondsSinceEpoch),
          Variable<int>(result.correctCount),
          Variable<int>(result.totalCount),
          Variable<int>(result.bestStreak),
          Variable<double>(result.earnedScore),
        ],
      );
      for (final QuestionEvaluation evaluation in result.evaluations) {
        await customStatement(
          '''
INSERT INTO attempt_answers(attempt_id, question_id, submitted_json, is_correct, score)
VALUES(?, ?, ?, ?, ?)
''',
          <Object?>[
            attemptId,
            evaluation.questionId,
            jsonEncode(evaluation.submittedAnswers.toList()..sort()),
            evaluation.correct ? 1 : 0,
            evaluation.score,
          ],
        );
      }
      return attemptId;
    });
  }

  Future<ProgressSummary> loadProgress(String profileId) async {
    final QueryRow? row = await customSelect(
      '''
SELECT
  COUNT(*) AS quiz_count,
  COALESCE(SUM(question_count), 0) AS question_count,
  COALESCE(SUM(correct_count), 0) AS correct_count,
  COALESCE(MAX(best_streak), 0) AS best_streak,
  COALESCE(SUM((completed_at - started_at) / 1000), 0) AS total_seconds
FROM attempts
WHERE profile_id = ?
''',
      variables: <Variable<Object>>[Variable<String>(profileId)],
    ).getSingleOrNull();
    if (row == null) {
      return const ProgressSummary();
    }
    return ProgressSummary(
      quizCount: row.read<int>('quiz_count'),
      questionCount: row.read<int>('question_count'),
      correctCount: row.read<int>('correct_count'),
      bestStreak: row.read<int>('best_streak'),
      totalSeconds: row.read<int>('total_seconds'),
    );
  }

  Future<List<LeaderboardEntry>> loadLeaderboard() async {
    final List<QueryRow> rows = await customSelect(
      '''
SELECT
  p.id AS profile_id,
  p.display_name AS display_name,
  CAST(COALESCE(SUM(a.correct_count) * 100 + MAX(a.best_streak) * 10, 0) AS INTEGER) AS points,
  CAST(
    CASE
      WHEN COALESCE(SUM(a.question_count), 0) = 0 THEN 0.0
      ELSE 100.0 * SUM(a.correct_count) / SUM(a.question_count)
    END
    AS REAL
  ) AS accuracy
FROM profiles p
LEFT JOIN attempts a ON a.profile_id = p.id
GROUP BY p.id, p.display_name
ORDER BY points DESC, accuracy DESC, p.display_name COLLATE NOCASE ASC
''',
    ).get();
    return rows.map((QueryRow row) {
      return LeaderboardEntry(
        profileId: row.read<String>('profile_id'),
        displayName: row.read<String>('display_name'),
        points: row.read<int>('points'),
        accuracy: row.read<double>('accuracy'),
      );
    }).toList(growable: false);
  }

  Future<void> setBookmark({
    required String profileId,
    required String questionId,
    required bool bookmarked,
  }) async {
    if (bookmarked) {
      await customStatement(
        '''
INSERT OR IGNORE INTO bookmarks(profile_id, question_id, created_at)
VALUES(?, ?, ?)
''',
        <Object?>[
          profileId,
          questionId,
          DateTime.now().millisecondsSinceEpoch,
        ],
      );
    } else {
      await customStatement(
        'DELETE FROM bookmarks WHERE profile_id = ? AND question_id = ?',
        <Object?>[profileId, questionId],
      );
    }
  }

  Future<Set<String>> loadBookmarkIds(String profileId) async {
    final List<QueryRow> rows = await customSelect(
      'SELECT question_id FROM bookmarks WHERE profile_id = ?',
      variables: <Variable<Object>>[Variable<String>(profileId)],
    ).get();
    return rows.map((QueryRow row) => row.read<String>('question_id')).toSet();
  }

  static Question _questionFromRow(QueryRow row) {
    return Question(
      id: row.read<String>('id'),
      type: QuestionType.values.byName(row.read<String>('type')),
      prompt: row.read<String>('prompt'),
      choices: _decodeStringList(row.read<String>('choices_json')),
      correctAnswers:
          _decodeStringList(row.read<String>('correct_answers_json')).toSet(),
      category: row.read<String>('category'),
      difficulty: Difficulty.values.byName(row.read<String>('difficulty')),
      tags: _decodeStringList(row.read<String>('tags_json')),
      explanation: row.read<String>('explanation'),
      timeLimitSeconds: row.readNullable<int>('time_limit_seconds'),
    );
  }

  static List<String> _decodeStringList(String encoded) {
    final Object? value = jsonDecode(encoded);
    if (value is! List<Object?>) {
      throw const FormatException('Stored list is invalid.');
    }
    return value.cast<String>().toList(growable: false);
  }
}

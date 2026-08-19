import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/profile.dart';
import '../domain/question.dart';
import '../domain/quiz_result.dart';
import 'app_database.dart';

final class DatabaseBackupSnapshot {
  const DatabaseBackupSnapshot({
    required this.questions,
    required this.profiles,
    required this.attempts,
    required this.bookmarks,
  });

  final List<Question> questions;
  final List<PlayerProfile> profiles;
  final List<BackupAttempt> attempts;
  final List<BackupBookmark> bookmarks;

  List<String> validate() {
    final List<String> errors = <String>[];
    final Set<String> questionIds = <String>{};
    final Set<String> fingerprints = <String>{};
    for (final Question question in questions) {
      final List<String> questionErrors = question.validate();
      if (questionErrors.isNotEmpty) {
        errors.add('Invalid question ${question.id}.');
      }
      if (!questionIds.add(question.id)) {
        errors.add('Duplicate question id ${question.id}.');
      }
      if (!fingerprints.add(question.fingerprint)) {
        errors.add('Duplicate question content detected.');
      }
    }

    final Set<String> profileIds = <String>{};
    for (final PlayerProfile profile in profiles) {
      if (profile.validate().isNotEmpty) {
        errors.add('Invalid local profile ${profile.id}.');
      }
      if (!profileIds.add(profile.id)) {
        errors.add('Duplicate local profile id ${profile.id}.');
      }
    }

    for (final BackupAttempt attempt in attempts) {
      if (!profileIds.contains(attempt.profileId)) {
        errors.add('Quiz attempt references an unknown profile.');
      }
      if (attempt.completedAt.isBefore(attempt.startedAt)) {
        errors.add('Quiz attempt completion time is invalid.');
      }
      if (attempt.questionCount < 0 ||
          attempt.correctCount < 0 ||
          attempt.bestStreak < 0) {
        errors.add('Quiz attempt aggregate counts must not be negative.');
      }
      if (attempt.questionCount != attempt.evaluations.length) {
        errors.add('Quiz attempt question count does not match its answers.');
      }
      final int correctCount = attempt.evaluations
          .where((QuestionEvaluation item) => item.correct)
          .length;
      if (attempt.correctCount != correctCount) {
        errors.add('Quiz attempt correct-answer count is inconsistent.');
      }
      final int bestStreak = _bestStreak(attempt.evaluations);
      if (attempt.bestStreak != bestStreak) {
        errors.add('Quiz attempt best streak is inconsistent.');
      }
      if (!attempt.earnedScore.isFinite || attempt.earnedScore < 0) {
        errors.add('Quiz attempt total score is invalid.');
      }
      final double earnedScore = attempt.evaluations.fold<double>(
        0,
        (double total, QuestionEvaluation item) => total + item.score,
      );
      if ((attempt.earnedScore - earnedScore).abs() > 0.000001) {
        errors.add('Quiz attempt score is inconsistent.');
      }
      final Set<String> answeredQuestionIds = <String>{};
      for (final QuestionEvaluation evaluation in attempt.evaluations) {
        if (!questionIds.contains(evaluation.questionId)) {
          errors.add('Quiz attempt references an unknown question.');
        }
        if (!answeredQuestionIds.add(evaluation.questionId)) {
          errors.add('Quiz attempt contains a duplicate question answer.');
        }
        if (!evaluation.score.isFinite || evaluation.score < 0) {
          errors.add('Quiz attempt contains an invalid score.');
        }
      }
    }

    final Set<String> bookmarkKeys = <String>{};
    for (final BackupBookmark bookmark in bookmarks) {
      if (!profileIds.contains(bookmark.profileId)) {
        errors.add('Bookmark references an unknown profile.');
      }
      if (!questionIds.contains(bookmark.questionId)) {
        errors.add('Bookmark references an unknown question.');
      }
      if (!bookmarkKeys.add('${bookmark.profileId}\u0000${bookmark.questionId}')) {
        errors.add('Duplicate bookmark detected.');
      }
    }
    return errors;
  }

  static int _bestStreak(Iterable<QuestionEvaluation> evaluations) {
    int current = 0;
    int best = 0;
    for (final QuestionEvaluation evaluation in evaluations) {
      if (evaluation.correct) {
        current += 1;
        if (current > best) {
          best = current;
        }
      } else {
        current = 0;
      }
    }
    return best;
  }
}

final class BackupAttempt {
  const BackupAttempt({
    required this.profileId,
    required this.startedAt,
    required this.completedAt,
    required this.correctCount,
    required this.questionCount,
    required this.bestStreak,
    required this.earnedScore,
    required this.evaluations,
  });

  final String profileId;
  final DateTime startedAt;
  final DateTime completedAt;
  final int correctCount;
  final int questionCount;
  final int bestStreak;
  final double earnedScore;
  final List<QuestionEvaluation> evaluations;
}

final class BackupBookmark {
  const BackupBookmark({
    required this.profileId,
    required this.questionId,
  });

  final String profileId;
  final String questionId;
}

extension AppDatabaseBackup on AppDatabase {
  Future<DatabaseBackupSnapshot> exportBackupSnapshot() async {
    final List<Question> questions = await loadQuestions();
    final List<PlayerProfile> profiles = await loadProfiles();
    final List<QueryRow> attemptRows = await customSelect(
      '''
SELECT id, profile_id, started_at, completed_at, correct_count, question_count,
       best_streak, earned_score
FROM attempts
ORDER BY id ASC
''',
    ).get();
    final List<BackupAttempt> attempts = <BackupAttempt>[];
    for (final QueryRow row in attemptRows) {
      final int attemptId = row.read<int>('id');
      final List<QueryRow> answerRows = await customSelect(
        '''
SELECT question_id, submitted_json, is_correct, score
FROM attempt_answers
WHERE attempt_id = ?
ORDER BY question_id COLLATE NOCASE ASC
''',
        variables: <Variable<Object>>[Variable<int>(attemptId)],
      ).get();
      attempts.add(
        BackupAttempt(
          profileId: row.read<String>('profile_id'),
          startedAt: DateTime.fromMillisecondsSinceEpoch(
            row.read<int>('started_at'),
          ),
          completedAt: DateTime.fromMillisecondsSinceEpoch(
            row.read<int>('completed_at'),
          ),
          correctCount: row.read<int>('correct_count'),
          questionCount: row.read<int>('question_count'),
          bestStreak: row.read<int>('best_streak'),
          earnedScore: row.read<double>('earned_score'),
          evaluations: answerRows
              .map(
                (QueryRow answer) => QuestionEvaluation(
                  questionId: answer.read<String>('question_id'),
                  submittedAnswers: _decodeBackupStringSet(
                    answer.read<String>('submitted_json'),
                  ),
                  correct: answer.read<int>('is_correct') == 1,
                  score: answer.read<double>('score'),
                ),
              )
              .toList(growable: false),
        ),
      );
    }

    final List<QueryRow> bookmarkRows = await customSelect(
      '''
SELECT profile_id, question_id
FROM bookmarks
ORDER BY profile_id COLLATE NOCASE, question_id COLLATE NOCASE
''',
    ).get();
    final List<BackupBookmark> bookmarks = bookmarkRows
        .map(
          (QueryRow row) => BackupBookmark(
            profileId: row.read<String>('profile_id'),
            questionId: row.read<String>('question_id'),
          ),
        )
        .toList(growable: false);

    return DatabaseBackupSnapshot(
      questions: questions,
      profiles: profiles,
      attempts: attempts,
      bookmarks: bookmarks,
    );
  }

  Future<void> restoreBackupSnapshot(DatabaseBackupSnapshot snapshot) async {
    final List<String> errors = snapshot.validate();
    if (errors.isNotEmpty) {
      throw FormatException(errors.first);
    }

    await transaction(() async {
      await customStatement('DELETE FROM attempt_answers');
      await customStatement('DELETE FROM attempts');
      await customStatement('DELETE FROM bookmarks');
      await customStatement('DELETE FROM profiles');
      await customStatement('DELETE FROM questions');

      for (final Question question in snapshot.questions) {
        await customStatement(
          '''
INSERT INTO questions(
  id, type, prompt, choices_json, correct_answers_json, category, difficulty,
  tags_json, explanation, time_limit_seconds, fingerprint, created_at
) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
      for (final PlayerProfile profile in snapshot.profiles) {
        await upsertProfile(profile);
      }
      for (final BackupAttempt attempt in snapshot.attempts) {
        final int attemptId = await customInsert(
          '''
INSERT INTO attempts(
  profile_id, started_at, completed_at, correct_count, question_count,
  best_streak, earned_score
) VALUES(?, ?, ?, ?, ?, ?, ?)
''',
          variables: <Variable<Object>>[
            Variable<String>(attempt.profileId),
            Variable<int>(attempt.startedAt.millisecondsSinceEpoch),
            Variable<int>(attempt.completedAt.millisecondsSinceEpoch),
            Variable<int>(attempt.correctCount),
            Variable<int>(attempt.questionCount),
            Variable<int>(attempt.bestStreak),
            Variable<double>(attempt.earnedScore),
          ],
        );
        for (final QuestionEvaluation evaluation in attempt.evaluations) {
          await customStatement(
            '''
INSERT INTO attempt_answers(
  attempt_id, question_id, submitted_json, is_correct, score
) VALUES(?, ?, ?, ?, ?)
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
      }
      for (final BackupBookmark bookmark in snapshot.bookmarks) {
        await customStatement(
          '''
INSERT INTO bookmarks(profile_id, question_id, created_at)
VALUES(?, ?, ?)
''',
          <Object?>[
            bookmark.profileId,
            bookmark.questionId,
            DateTime.now().millisecondsSinceEpoch,
          ],
        );
      }
    });
  }
}

Set<String> _decodeBackupStringSet(String encoded) {
  final Object? value = jsonDecode(encoded);
  if (value is! List<Object?> || value.any((Object? item) => item is! String)) {
    throw const FormatException('Stored quiz answer list is invalid.');
  }
  return value.cast<String>().toSet();
}

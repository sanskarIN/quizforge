import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/data/app_database_backup.dart';
import 'package:quizforge/src/domain/profile.dart';
import 'package:quizforge/src/domain/question.dart';
import 'package:quizforge/src/domain/quiz_result.dart';

void main() {
  final Question question = Question(
    id: 'answer-integrity-q1',
    type: QuestionType.shortAnswer,
    prompt: 'Which word is correct?',
    correctAnswers: const <String>{'correct'},
    category: 'Backup',
    difficulty: Difficulty.easy,
  );
  const PlayerProfile profile = PlayerProfile(
    id: 'answer-integrity-profile',
    displayName: 'Integrity Player',
  );
  final DateTime startedAt = DateTime.utc(2026, 8, 19, 13);

  test('rejects a wrong submitted answer marked correct', () {
    final DatabaseBackupSnapshot snapshot = DatabaseBackupSnapshot(
      questions: <Question>[question],
      profiles: const <PlayerProfile>[profile],
      attempts: <BackupAttempt>[
        BackupAttempt(
          profileId: profile.id,
          startedAt: startedAt,
          completedAt: startedAt.add(const Duration(seconds: 1)),
          correctCount: 1,
          questionCount: 1,
          bestStreak: 1,
          earnedScore: 1,
          evaluations: const <QuestionEvaluation>[
            QuestionEvaluation(
              questionId: 'answer-integrity-q1',
              submittedAnswers: <String>{'wrong'},
              correct: true,
              score: 1,
            ),
          ],
        ),
      ],
      bookmarks: const <BackupBookmark>[],
    );

    expect(
      snapshot.validate(),
      contains(
        'Quiz attempt answer correctness is inconsistent with its question.',
      ),
    );
  });

  test('rejects a score that disagrees with evaluated correctness', () {
    final DatabaseBackupSnapshot snapshot = DatabaseBackupSnapshot(
      questions: <Question>[question],
      profiles: const <PlayerProfile>[profile],
      attempts: <BackupAttempt>[
        BackupAttempt(
          profileId: profile.id,
          startedAt: startedAt,
          completedAt: startedAt.add(const Duration(seconds: 1)),
          correctCount: 1,
          questionCount: 1,
          bestStreak: 1,
          earnedScore: 0,
          evaluations: const <QuestionEvaluation>[
            QuestionEvaluation(
              questionId: 'answer-integrity-q1',
              submittedAnswers: <String>{'correct'},
              correct: true,
              score: 0,
            ),
          ],
        ),
      ],
      bookmarks: const <BackupBookmark>[],
    );

    expect(
      snapshot.validate(),
      contains('Quiz attempt answer score is inconsistent with its question.'),
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/data/app_database_backup.dart';
import 'package:quizforge/src/domain/profile.dart';
import 'package:quizforge/src/domain/question.dart';

void main() {
  final Question question = Question(
    id: 'attempt-bounds-q1',
    type: QuestionType.shortAnswer,
    prompt: 'Which bound is valid?',
    correctAnswers: const <String>{'one'},
    category: 'Backup',
    difficulty: Difficulty.easy,
  );
  const PlayerProfile profile = PlayerProfile(
    id: 'attempt-bounds-profile',
    displayName: 'Bounds Player',
  );
  final DateTime startedAt = DateTime.utc(2026, 8, 19, 14);

  test('rejects a zero-question attempt', () {
    final DatabaseBackupSnapshot snapshot = DatabaseBackupSnapshot(
      questions: <Question>[question],
      profiles: const <PlayerProfile>[profile],
      attempts: <BackupAttempt>[
        BackupAttempt(
          profileId: profile.id,
          startedAt: startedAt,
          completedAt: startedAt,
          correctCount: 0,
          questionCount: 0,
          bestStreak: 0,
          earnedScore: 0,
          evaluations: const [],
        ),
      ],
      bookmarks: const <BackupBookmark>[],
    );

    expect(
      snapshot.validate(),
      contains('Quiz attempt question count must be between 1 and 100.'),
    );
  });

  test('rejects an attempt above the configured quiz limit', () {
    final DatabaseBackupSnapshot snapshot = DatabaseBackupSnapshot(
      questions: <Question>[question],
      profiles: const <PlayerProfile>[profile],
      attempts: <BackupAttempt>[
        BackupAttempt(
          profileId: profile.id,
          startedAt: startedAt,
          completedAt: startedAt,
          correctCount: 0,
          questionCount: 101,
          bestStreak: 0,
          earnedScore: 0,
          evaluations: const [],
        ),
      ],
      bookmarks: const <BackupBookmark>[],
    );

    expect(
      snapshot.validate(),
      contains('Quiz attempt question count must be between 1 and 100.'),
    );
  });
}

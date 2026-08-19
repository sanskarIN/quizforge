import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/data/app_database_backup.dart';
import 'package:quizforge/src/data/local_backup_codec.dart';
import 'package:quizforge/src/domain/app_settings.dart';
import 'package:quizforge/src/domain/profile.dart';
import 'package:quizforge/src/domain/question.dart';
import 'package:quizforge/src/domain/quiz_result.dart';

void main() {
  const LocalBackupCodec codec = LocalBackupCodec();
  final Question question = Question(
    id: 'codec-backup-q1',
    type: QuestionType.shortAnswer,
    prompt: 'Which word is archived?',
    correctAnswers: const <String>{'archive'},
    category: 'Backup',
    difficulty: Difficulty.hard,
    tags: const <String>['codec'],
    explanation: 'A deterministic backup fixture.',
  );
  final DateTime createdAt = DateTime.utc(2026, 8, 19, 9, 30);
  final LocalBackupPayload payload = LocalBackupPayload(
    createdAt: createdAt,
    database: DatabaseBackupSnapshot(
      questions: <Question>[question],
      profiles: <PlayerProfile>[
        PlayerProfile(
          id: 'codec-profile',
          displayName: 'Codec Player',
          createdAt: createdAt.subtract(const Duration(days: 1)),
        ),
      ],
      attempts: <BackupAttempt>[
        BackupAttempt(
          profileId: 'codec-profile',
          startedAt: createdAt.subtract(const Duration(minutes: 2)),
          completedAt: createdAt.subtract(const Duration(minutes: 1)),
          correctCount: 1,
          questionCount: 1,
          bestStreak: 1,
          earnedScore: 1,
          evaluations: const <QuestionEvaluation>[
            QuestionEvaluation(
              questionId: 'codec-backup-q1',
              submittedAnswers: <String>{'archive'},
              correct: true,
              score: 1,
            ),
          ],
        ),
      ],
      bookmarks: const <BackupBookmark>[
        BackupBookmark(
          profileId: 'codec-profile',
          questionId: 'codec-backup-q1',
        ),
      ],
    ),
    settings: const AppSettings(
      themeMode: AppThemeMode.dark,
      largeText: true,
      reducedMotion: true,
      screenReaderHints: false,
      confirmBeforeExitQuiz: false,
    ),
    activeProfileId: 'codec-profile',
  );

  test('round trips all supported local backup state', () {
    final String encoded = codec.encode(payload);
    final LocalBackupPayload decoded = codec.decode(encoded);

    expect(decoded.createdAt.toUtc(), createdAt);
    expect(decoded.activeProfileId, 'codec-profile');
    expect(decoded.settings.themeMode, AppThemeMode.dark);
    expect(decoded.settings.largeText, isTrue);
    expect(decoded.settings.reducedMotion, isTrue);
    expect(decoded.settings.screenReaderHints, isFalse);
    expect(decoded.settings.confirmBeforeExitQuiz, isFalse);
    expect(decoded.database.questions.single.id, question.id);
    expect(decoded.database.profiles.single.displayName, 'Codec Player');
    expect(decoded.database.attempts.single.correctCount, 1);
    expect(decoded.database.attempts.single.bestStreak, 1);
    expect(decoded.database.attempts.single.evaluations.single.correct, isTrue);
    expect(decoded.database.bookmarks.single.questionId, question.id);
  });

  test('rejects unsupported archive versions', () {
    final String encoded = codec.encode(payload).replaceFirst(
      '"version": 1',
      '"version": 99',
    );

    expect(() => codec.decode(encoded), throwsFormatException);
  });

  test('rejects an active profile that is not in the archive', () {
    final String encoded = codec.encode(payload).replaceFirst(
      '"activeProfileId": "codec-profile"',
      '"activeProfileId": "missing-profile"',
    );

    expect(() => codec.decode(encoded), throwsFormatException);
  });

  test('rejects inconsistent attempt aggregates from an archive', () {
    final String encoded = codec.encode(payload).replaceFirst(
      '"bestStreak": 1',
      '"bestStreak": 0',
    );

    expect(() => codec.decode(encoded), throwsFormatException);
  });

  test('rejects oversized archives before parsing', () {
    final String oversized = 'x' * (LocalBackupCodec.maxSourceCharacters + 1);
    expect(() => codec.decode(oversized), throwsFormatException);
  });
}

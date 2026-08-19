import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/app_database_backup.dart';
import 'package:quizforge/src/data/app_database_maintenance.dart';
import 'package:quizforge/src/domain/profile.dart';
import 'package:quizforge/src/domain/question.dart';
import 'package:quizforge/src/domain/quiz_result.dart';

void main() {
  test('logical backup snapshot restores questions profiles attempts and bookmarks', () async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final Question question = Question(
      id: 'backup-q1',
      type: QuestionType.shortAnswer,
      prompt: 'What word should be backed up?',
      correctAnswers: const <String>{'backup'},
      category: 'Backup',
      difficulty: Difficulty.medium,
      tags: const <String>['archive'],
      explanation: 'This is a fictional backup fixture.',
    );
    const PlayerProfile profile = PlayerProfile(
      id: 'backup-profile',
      displayName: 'Backup Player',
    );
    await database.upsertQuestions(<Question>[question]);
    await database.upsertProfile(profile);
    await database.setBookmark(
      profileId: profile.id,
      questionId: question.id,
      bookmarked: true,
    );
    final DateTime startedAt = DateTime.utc(2026, 8, 19, 9);
    await database.saveAttempt(
      profile.id,
      QuizResult(
        startedAt: startedAt,
        completedAt: startedAt.add(const Duration(seconds: 7)),
        evaluations: const <QuestionEvaluation>[
          QuestionEvaluation(
            questionId: 'backup-q1',
            submittedAnswers: <String>{'backup'},
            correct: true,
            score: 1,
          ),
        ],
      ),
    );

    final DatabaseBackupSnapshot snapshot = await database.exportBackupSnapshot();
    expect(snapshot.validate(), isEmpty);
    expect(snapshot.questions, hasLength(1));
    expect(snapshot.profiles, hasLength(1));
    expect(snapshot.attempts, hasLength(1));
    expect(snapshot.bookmarks, hasLength(1));

    await database.resetAllLocalData();
    expect(await database.loadQuestions(), isEmpty);
    expect(await database.loadProfiles(), isEmpty);

    await database.restoreBackupSnapshot(snapshot);

    expect((await database.loadQuestions()).single.id, question.id);
    expect((await database.loadProfiles()).single.displayName, profile.displayName);
    expect(await database.loadBookmarkIds(profile.id), <String>{question.id});
    final progress = await database.loadProgress(profile.id);
    expect(progress.quizCount, 1);
    expect(progress.questionCount, 1);
    expect(progress.correctCount, 1);
    expect(progress.bestStreak, 1);
    expect(progress.totalSeconds, 7);
  });

  test('restore rejects snapshots with dangling bookmark references', () async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    const DatabaseBackupSnapshot snapshot = DatabaseBackupSnapshot(
      questions: <Question>[],
      profiles: <PlayerProfile>[],
      attempts: <BackupAttempt>[],
      bookmarks: <BackupBookmark>[
        BackupBookmark(profileId: 'missing-profile', questionId: 'missing-question'),
      ],
    );

    await expectLater(
      database.restoreBackupSnapshot(snapshot),
      throwsFormatException,
    );
  });
}

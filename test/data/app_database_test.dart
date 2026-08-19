import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/domain/profile.dart';
import 'package:quizforge/src/domain/question.dart';
import 'package:quizforge/src/domain/quiz_result.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('stores questions profiles bookmarks and progress', () async {
    final Question question = Question(
      id: 'db-q1',
      type: QuestionType.shortAnswer,
      prompt: 'What is 2 + 2?',
      correctAnswers: const <String>{'4'},
      category: 'Math',
      difficulty: Difficulty.easy,
    );
    const PlayerProfile profile = PlayerProfile(
      id: 'profile-1',
      displayName: 'Tester',
    );

    await database.upsertQuestions(<Question>[question]);
    await database.upsertProfile(profile);

    expect((await database.loadQuestions()).single.id, question.id);
    expect((await database.loadProfiles()).single.displayName, 'Tester');

    await database.setBookmark(
      profileId: profile.id,
      questionId: question.id,
      bookmarked: true,
    );
    expect(await database.loadBookmarkIds(profile.id), <String>{question.id});

    final DateTime start = DateTime(2026, 8, 19, 8);
    final QuizResult result = QuizResult(
      startedAt: start,
      completedAt: start.add(const Duration(seconds: 42)),
      evaluations: const <QuestionEvaluation>[
        QuestionEvaluation(
          questionId: 'db-q1',
          submittedAnswers: <String>{'4'},
          correct: true,
          score: 1,
        ),
      ],
    );
    await database.saveAttempt(profile.id, result);

    final ProgressSummary progress = await database.loadProgress(profile.id);
    expect(progress.quizCount, 1);
    expect(progress.questionCount, 1);
    expect(progress.correctCount, 1);
    expect(progress.bestStreak, 1);
    expect(progress.totalSeconds, 42);

    final List<LeaderboardEntry> leaderboard = await database.loadLeaderboard();
    expect(leaderboard.single.profileId, profile.id);
    expect(leaderboard.single.points, 110);
    expect(leaderboard.single.accuracy, 100);
  });
}

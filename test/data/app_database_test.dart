import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/app_database_maintenance.dart';
import 'package:quizforge/src/data/app_database_progress.dart';
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

  test('stores questions profiles bookmarks progress and category stats', () async {
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

    final List<CategoryProgress> categoryProgress =
        await database.loadCategoryProgress(profile.id);
    expect(categoryProgress, hasLength(1));
    expect(categoryProgress.single.category, 'Math');
    expect(categoryProgress.single.questionCount, 1);
    expect(categoryProgress.single.correctCount, 1);
    expect(categoryProgress.single.accuracy, 100);

    final List<LeaderboardEntry> leaderboard = await database.loadLeaderboard();
    expect(leaderboard.single.profileId, profile.id);
    expect(leaderboard.single.points, 110);
    expect(leaderboard.single.accuracy, 100);
  });

  test('question batch rolls back when a later item is invalid', () async {
    final Question valid = Question(
      id: 'batch-valid',
      type: QuestionType.shortAnswer,
      prompt: 'Valid question?',
      correctAnswers: const <String>{'yes'},
      category: 'Testing',
      difficulty: Difficulty.easy,
    );
    final Question invalid = Question(
      id: 'batch-invalid',
      type: QuestionType.shortAnswer,
      prompt: 'x',
      correctAnswers: const <String>{'yes'},
      category: 'Testing',
      difficulty: Difficulty.easy,
    );

    await expectLater(
      database.upsertQuestions(<Question>[valid, invalid]),
      throwsA(isA<ArgumentError>()),
    );

    expect(await database.loadQuestions(), isEmpty);
  });

  test('attempt write rolls back when an answer references unknown question', () async {
    const PlayerProfile profile = PlayerProfile(
      id: 'rollback-profile',
      displayName: 'Rollback Tester',
    );
    await database.upsertProfile(profile);
    final DateTime start = DateTime(2026, 8, 19, 8);
    final QuizResult invalidResult = QuizResult(
      startedAt: start,
      completedAt: start.add(const Duration(seconds: 5)),
      evaluations: const <QuestionEvaluation>[
        QuestionEvaluation(
          questionId: 'missing-question',
          submittedAnswers: <String>{'answer'},
          correct: true,
          score: 1,
        ),
      ],
    );

    await expectLater(
      database.saveAttempt(profile.id, invalidResult),
      throwsA(anything),
    );

    final ProgressSummary progress = await database.loadProgress(profile.id);
    expect(progress.quizCount, 0);
    expect(progress.questionCount, 0);
    expect(progress.correctCount, 0);
  });

  test('clear profile activity preserves profile and questions', () async {
    final Question question = Question(
      id: 'activity-q1',
      type: QuestionType.shortAnswer,
      prompt: 'Name one?',
      correctAnswers: const <String>{'one'},
      category: 'Demo',
      difficulty: Difficulty.easy,
    );
    const PlayerProfile profile = PlayerProfile(
      id: 'activity-profile',
      displayName: 'Activity Tester',
    );
    await database.upsertQuestions(<Question>[question]);
    await database.upsertProfile(profile);
    await database.setBookmark(
      profileId: profile.id,
      questionId: question.id,
      bookmarked: true,
    );
    final DateTime start = DateTime(2026, 8, 19, 9);
    await database.saveAttempt(
      profile.id,
      QuizResult(
        startedAt: start,
        completedAt: start.add(const Duration(seconds: 5)),
        evaluations: const <QuestionEvaluation>[
          QuestionEvaluation(
            questionId: 'activity-q1',
            submittedAnswers: <String>{'one'},
            correct: true,
            score: 1,
          ),
        ],
      ),
    );

    await database.clearProfileActivity(profile.id);

    expect(await database.loadProfiles(), hasLength(1));
    expect(await database.loadQuestions(), hasLength(1));
    expect(await database.loadBookmarkIds(profile.id), isEmpty);
    expect((await database.loadProgress(profile.id)).quizCount, 0);
    expect(await database.loadCategoryProgress(profile.id), isEmpty);
  });

  test('profile rename and delete respect foreign-key cleanup', () async {
    const PlayerProfile first = PlayerProfile(
      id: 'profile-a',
      displayName: 'First Player',
    );
    const PlayerProfile second = PlayerProfile(
      id: 'profile-b',
      displayName: 'Second Player',
    );
    await database.upsertProfile(first);
    await database.upsertProfile(second);

    await database.renameProfile(
      profileId: first.id,
      displayName: 'Renamed Player',
    );
    expect(
      (await database.loadProfiles())
          .firstWhere((PlayerProfile item) => item.id == first.id)
          .displayName,
      'Renamed Player',
    );

    await database.deleteProfile(second.id);
    expect(
      (await database.loadProfiles()).map((PlayerProfile item) => item.id),
      <String>[first.id],
    );
  });

  test('reset all local data clears every persisted domain table', () async {
    final Question question = Question(
      id: 'reset-q1',
      type: QuestionType.shortAnswer,
      prompt: 'Reset question?',
      correctAnswers: const <String>{'yes'},
      category: 'Demo',
      difficulty: Difficulty.easy,
    );
    const PlayerProfile profile = PlayerProfile(
      id: 'reset-profile',
      displayName: 'Reset Tester',
    );
    await database.upsertQuestions(<Question>[question]);
    await database.upsertProfile(profile);
    await database.setBookmark(
      profileId: profile.id,
      questionId: question.id,
      bookmarked: true,
    );

    await database.resetAllLocalData();

    expect(await database.loadQuestions(), isEmpty);
    expect(await database.loadProfiles(), isEmpty);
    expect(await database.loadLeaderboard(), isEmpty);
  });
}

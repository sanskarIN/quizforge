import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/core/logging/app_logger.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/domain/app_settings.dart';
import 'package:quizforge/src/domain/profile.dart';
import 'package:quizforge/src/domain/question.dart';
import 'package:quizforge/src/domain/quiz_result.dart';

import 'controller_fakes.dart';

void main() {
  late AppDatabase database;
  late FakeQuestionStore questionStore;
  late FakeSettingsStore settingsStore;
  late FakeProfileSelectionStore profileSelectionStore;
  late QuizForgeController controller;

  final Question seedQuestion = Question(
    id: 'controller-q1',
    type: QuestionType.shortAnswer,
    prompt: 'What word completes this test?',
    correctAnswers: const <String>{'pass'},
    category: 'Testing',
    difficulty: Difficulty.easy,
    tags: const <String>['controller', 'unit'],
  );

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    questionStore = FakeQuestionStore(<Question>[seedQuestion]);
    settingsStore = FakeSettingsStore(
      const AppSettings(
        themeMode: AppThemeMode.dark,
        largeText: true,
      ),
    );
    profileSelectionStore = FakeProfileSelectionStore();
    controller = QuizForgeController(
      database: database,
      questionRepository: questionStore,
      settingsRepository: settingsStore,
      profilePreferences: profileSelectionStore,
      logger: AppLogger(sink: (_) {}),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('initialize loads stores and creates a default local profile', () async {
    await controller.initialize();

    expect(controller.loading, isFalse);
    expect(controller.errorMessage, isNull);
    expect(controller.questions, <Question>[seedQuestion]);
    expect(controller.settings.themeMode, AppThemeMode.dark);
    expect(controller.settings.largeText, isTrue);
    expect(controller.profiles, hasLength(1));
    expect(controller.activeProfile?.id, 'local-default');
    expect(profileSelectionStore.activeProfileId, 'local-default');
  });

  test('initialize honors a persisted active profile selection', () async {
    await database.upsertProfile(
      const PlayerProfile(
        id: 'profile-a',
        displayName: 'Alpha Player',
      ),
    );
    await database.upsertProfile(
      const PlayerProfile(
        id: 'profile-b',
        displayName: 'Beta Player',
      ),
    );
    profileSelectionStore.activeProfileId = 'profile-b';

    await controller.initialize();

    expect(controller.activeProfile?.id, 'profile-b');
    expect(profileSelectionStore.activeProfileId, 'profile-b');
  });

  test('initialize exposes a safe error when a storage dependency fails', () async {
    questionStore.failLoad = true;

    await controller.initialize();

    expect(controller.loading, isFalse);
    expect(
      controller.errorMessage,
      'Unable to initialize QuizForge. Please try again.',
    );
    expect(controller.questions, isEmpty);
  });

  test('search normalizes query and matches prompt category and tags', () async {
    await controller.initialize();

    expect(controller.searchQuestions('  TEST  '), <Question>[seedQuestion]);
    expect(controller.searchQuestions('testing'), <Question>[seedQuestion]);
    expect(controller.searchQuestions('UNIT'), <Question>[seedQuestion]);
    expect(controller.searchQuestions('missing'), isEmpty);
    expect(
      controller.searchQuestions('test', difficulty: Difficulty.hard),
      isEmpty,
    );
  });

  test('addQuestion persists a unique valid question and rejects duplicate content', () async {
    await controller.initialize();
    final Question newQuestion = Question(
      id: 'controller-q2',
      type: QuestionType.trueFalse,
      prompt: 'Controller storage contracts are injectable.',
      correctAnswers: const <String>{'true'},
      category: 'Testing',
      difficulty: Difficulty.medium,
    );

    await controller.addQuestion(newQuestion);

    expect(controller.questions, hasLength(2));
    expect(controller.questions.last, same(newQuestion));
    expect((await questionStore.loadAll()).last, same(newQuestion));

    final Question duplicateContent = Question(
      id: 'controller-q3',
      type: QuestionType.trueFalse,
      prompt: '  controller STORAGE contracts ARE injectable. ',
      correctAnswers: const <String>{'true'},
      category: ' testing ',
      difficulty: Difficulty.hard,
    );
    await expectLater(
      controller.addQuestion(duplicateContent),
      throwsArgumentError,
    );
  });

  test('updateSettings writes through the injected settings store', () async {
    await controller.initialize();
    const AppSettings updated = AppSettings(
      themeMode: AppThemeMode.light,
      reducedMotion: true,
      screenReaderHints: false,
      confirmBeforeExitQuiz: false,
    );

    await controller.updateSettings(updated);

    expect(controller.settings, same(updated));
    expect(settingsStore.value, same(updated));
  });

  test('profile create rename select and delete stay synchronized', () async {
    await controller.initialize();

    await controller.createProfile('Second Player');
    final PlayerProfile second = controller.activeProfile!;
    expect(second.displayName, 'Second Player');
    expect(controller.profiles, hasLength(2));
    expect(profileSelectionStore.activeProfileId, second.id);

    await controller.renameActiveProfile('Renamed Player');
    expect(controller.activeProfile?.displayName, 'Renamed Player');
    expect(
      (await database.loadProfiles())
          .firstWhere((PlayerProfile profile) => profile.id == second.id)
          .displayName,
      'Renamed Player',
    );

    await controller.selectProfile('local-default');
    expect(controller.activeProfile?.id, 'local-default');

    await controller.deleteProfile(second.id);
    expect(controller.profiles, hasLength(1));
    expect(controller.profiles.single.id, 'local-default');
  });

  test('deleteProfile refuses to remove the final local profile', () async {
    await controller.initialize();

    await expectLater(
      controller.deleteProfile('local-default'),
      throwsStateError,
    );
    expect(controller.profiles, hasLength(1));
  });

  test('bookmark changes are persisted and reflected in search filters', () async {
    await database.upsertQuestions(<Question>[seedQuestion]);
    await controller.initialize();

    await controller.toggleBookmark(seedQuestion.id);

    expect(controller.bookmarkIds, <String>{seedQuestion.id});
    expect(
      await database.loadBookmarkIds(controller.activeProfile!.id),
      <String>{seedQuestion.id},
    );
    expect(
      controller.searchQuestions('', bookmarkedOnly: true),
      <Question>[seedQuestion],
    );

    await controller.toggleBookmark(seedQuestion.id);
    expect(controller.bookmarkIds, isEmpty);
    expect(controller.searchQuestions('', bookmarkedOnly: true), isEmpty);
  });

  test('recordResult refreshes progress category stats and leaderboard', () async {
    await database.upsertQuestions(<Question>[seedQuestion]);
    await controller.initialize();
    final DateTime startedAt = DateTime(2026, 8, 19, 12);
    final QuizResult result = QuizResult(
      startedAt: startedAt,
      completedAt: startedAt.add(const Duration(seconds: 9)),
      evaluations: const <QuestionEvaluation>[
        QuestionEvaluation(
          questionId: 'controller-q1',
          submittedAnswers: <String>{'pass'},
          correct: true,
          score: 1,
        ),
      ],
    );

    await controller.recordResult(result);

    expect(controller.progress.quizCount, 1);
    expect(controller.progress.correctCount, 1);
    expect(controller.progress.totalSeconds, 9);
    expect(controller.categoryProgress, hasLength(1));
    expect(controller.categoryProgress.single.category, 'Testing');
    expect(controller.categoryProgress.single.accuracy, 100);
    expect(controller.leaderboard.single.points, 110);
  });

  test('clear activity removes profile progress and bookmarks only', () async {
    await database.upsertQuestions(<Question>[seedQuestion]);
    await controller.initialize();
    await controller.toggleBookmark(seedQuestion.id);
    final DateTime startedAt = DateTime(2026, 8, 19, 13);
    await controller.recordResult(
      QuizResult(
        startedAt: startedAt,
        completedAt: startedAt.add(const Duration(seconds: 4)),
        evaluations: const <QuestionEvaluation>[
          QuestionEvaluation(
            questionId: 'controller-q1',
            submittedAnswers: <String>{'pass'},
            correct: true,
            score: 1,
          ),
        ],
      ),
    );

    await controller.clearActiveProfileActivity();

    expect(controller.progress.quizCount, 0);
    expect(controller.categoryProgress, isEmpty);
    expect(controller.bookmarkIds, isEmpty);
    expect(controller.questions, <Question>[seedQuestion]);
    expect(controller.profiles, hasLength(1));
  });

  test('resetAllLocalData resets injected preferences and recreates defaults', () async {
    await controller.initialize();
    await controller.createProfile('Temporary Player');
    await controller.updateSettings(
      const AppSettings(
        themeMode: AppThemeMode.light,
        reducedMotion: true,
      ),
    );

    await controller.resetAllLocalData();

    expect(settingsStore.resetCount, 1);
    expect(profileSelectionStore.clearCount, 1);
    expect(controller.settings.themeMode, AppThemeMode.system);
    expect(controller.settings.reducedMotion, isFalse);
    expect(controller.profiles, hasLength(1));
    expect(controller.activeProfile?.id, 'local-default');
    expect(profileSelectionStore.activeProfileId, 'local-default');
  });
}

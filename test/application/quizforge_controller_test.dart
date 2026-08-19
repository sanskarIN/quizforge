import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/core/logging/app_logger.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/domain/app_settings.dart';
import 'package:quizforge/src/domain/profile.dart';
import 'package:quizforge/src/domain/question.dart';

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
    expect(
      () => controller.addQuestion(duplicateContent),
      throwsArgumentError,
    );
  });
}

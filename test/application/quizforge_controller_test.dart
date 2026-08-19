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
}

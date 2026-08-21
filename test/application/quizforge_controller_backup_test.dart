import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/core/logging/app_logger.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/data/settings_repository.dart';
import 'package:quizforge/src/domain/app_settings.dart';
import 'package:quizforge/src/domain/question.dart';
import 'package:quizforge/src/domain/quiz_result.dart';

void main() {
  test(
    'local backup restores profiles settings questions bookmarks and progress',
    () async {
      final AppDatabase database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final _FakeSettingsStore settingsStore = _FakeSettingsStore();
      final _FakeProfilePreferences profilePreferences =
          _FakeProfilePreferences();
      final QuizForgeController controller = QuizForgeController(
        database: database,
        questionRepository: QuestionRepository(database),
        settingsRepository: settingsStore,
        profilePreferences: profilePreferences,
        logger: AppLogger(sink: (_) {}),
      );
      await controller.initialize();

      final Question customQuestion = Question(
        id: 'backup-controller-q1',
        type: QuestionType.shortAnswer,
        prompt: 'Which word proves restore worked?',
        correctAnswers: const <String>{'restored'},
        category: 'Backup',
        difficulty: Difficulty.medium,
        tags: const <String>['restore'],
      );
      await controller.addQuestion(customQuestion);
      await controller.createProfile('Archive Player');
      final String archivedProfileId = controller.activeProfile!.id;
      await controller.toggleBookmark(customQuestion.id);
      final DateTime startedAt = DateTime.utc(2026, 8, 19, 10);
      await controller.recordResult(
        QuizResult(
          startedAt: startedAt,
          completedAt: startedAt.add(const Duration(seconds: 6)),
          evaluations: const <QuestionEvaluation>[
            QuestionEvaluation(
              questionId: 'backup-controller-q1',
              submittedAnswers: <String>{'restored'},
              correct: true,
              score: 1,
            ),
          ],
        ),
      );
      await controller.updateSettings(
        const AppSettings(
          themeMode: AppThemeMode.dark,
          largeText: true,
          reducedMotion: true,
        ),
      );

      final String archive = await controller.exportLocalBackup();
      await controller.resetAllLocalData();
      expect(controller.profiles, hasLength(1));
      expect(controller.settings.themeMode, AppThemeMode.system);

      await controller.restoreLocalBackup(archive);

      expect(
        controller.questions.any(
          (Question item) => item.id == customQuestion.id,
        ),
        isTrue,
      );
      expect(controller.profiles, hasLength(2));
      expect(controller.activeProfile?.id, archivedProfileId);
      expect(controller.activeProfile?.displayName, 'Archive Player');
      expect(controller.settings.themeMode, AppThemeMode.dark);
      expect(controller.settings.largeText, isTrue);
      expect(controller.settings.reducedMotion, isTrue);
      expect(controller.bookmarkIds, contains(customQuestion.id));
      expect(controller.progress.quizCount, 1);
      expect(controller.progress.correctCount, 1);
    },
  );

  test('malformed backup is rejected without mutating current state', () async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final QuizForgeController controller = QuizForgeController(
      database: database,
      questionRepository: QuestionRepository(database),
      settingsRepository: _FakeSettingsStore(),
      profilePreferences: _FakeProfilePreferences(),
      logger: AppLogger(sink: (_) {}),
    );
    await controller.initialize();
    final List<String> questionIds = controller.questions
        .map((Question question) => question.id)
        .toList(growable: false);
    final String activeProfileId = controller.activeProfile!.id;

    await expectLater(
      controller.restoreLocalBackup('{not valid json'),
      throwsFormatException,
    );

    expect(
      controller.questions.map((Question question) => question.id),
      orderedEquals(questionIds),
    );
    expect(controller.activeProfile?.id, activeProfileId);
  });

  test(
    'failed cross-store restore rolls database and preferences back',
    () async {
      final AppDatabase database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final _FakeSettingsStore settingsStore = _FakeSettingsStore();
      final _FakeProfilePreferences profilePreferences =
          _FakeProfilePreferences();
      final QuizForgeController controller = QuizForgeController(
        database: database,
        questionRepository: QuestionRepository(database),
        settingsRepository: settingsStore,
        profilePreferences: profilePreferences,
        logger: AppLogger(sink: (_) {}),
      );
      await controller.initialize();

      final String olderArchive = await controller.exportLocalBackup();
      await controller.createProfile('Current Player');
      final String currentProfileId = controller.activeProfile!.id;
      await controller.updateSettings(
        const AppSettings(themeMode: AppThemeMode.dark),
      );

      settingsStore.failNextSave = true;
      await expectLater(
        controller.restoreLocalBackup(olderArchive),
        throwsA(isA<StateError>()),
      );

      expect(controller.activeProfile?.id, currentProfileId);
      expect(controller.activeProfile?.displayName, 'Current Player');
      expect(controller.profiles, hasLength(2));
      expect(controller.settings.themeMode, AppThemeMode.dark);
      expect(profilePreferences.value, currentProfileId);
    },
  );
}

final class _FakeSettingsStore implements AppSettingsStore {
  AppSettings value = const AppSettings();
  bool failNextSave = false;

  @override
  Future<AppSettings> load() async => value;

  @override
  Future<void> save(AppSettings settings) async {
    if (failNextSave) {
      failNextSave = false;
      throw StateError('simulated settings save failure');
    }
    value = settings;
  }

  @override
  Future<void> reset() async {
    value = const AppSettings();
  }
}

final class _FakeProfilePreferences implements ActiveProfilePreferences {
  String? value;

  @override
  Future<void> clearActiveProfileId() async {
    value = null;
  }

  @override
  Future<String?> loadActiveProfileId() async => value;

  @override
  Future<void> saveActiveProfileId(String profileId) async {
    value = profileId;
  }
}

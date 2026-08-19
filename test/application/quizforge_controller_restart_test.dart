import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/data/settings_repository.dart';
import 'package:quizforge/src/domain/app_settings.dart';

void main() {
  test('settings and active profile reload across controller instances', () async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final _MemorySettingsStore settingsStore = _MemorySettingsStore();
    final _MemoryProfilePreferences profilePreferences =
        _MemoryProfilePreferences();

    final QuizForgeController first = QuizForgeController(
      database: database,
      questionRepository: QuestionRepository(database),
      settingsRepository: settingsStore,
      profilePreferences: profilePreferences,
    );
    await first.initialize();
    await first.createProfile('Second Player');
    final String selectedProfileId = first.activeProfile!.id;
    await first.updateSettings(
      first.settings.copyWith(
        themeMode: AppThemeMode.dark,
        largeText: true,
        reducedMotion: true,
      ),
    );

    final QuizForgeController restarted = QuizForgeController(
      database: database,
      questionRepository: QuestionRepository(database),
      settingsRepository: settingsStore,
      profilePreferences: profilePreferences,
    );
    await restarted.initialize();

    expect(restarted.errorMessage, isNull);
    expect(restarted.activeProfile?.id, selectedProfileId);
    expect(restarted.settings.themeMode, AppThemeMode.dark);
    expect(restarted.settings.largeText, isTrue);
    expect(restarted.settings.reducedMotion, isTrue);
    expect(restarted.profiles, hasLength(2));
  });
}

final class _MemorySettingsStore implements AppSettingsStore {
  AppSettings value = const AppSettings();

  @override
  Future<AppSettings> load() async => value;

  @override
  Future<void> reset() async {
    value = const AppSettings();
  }

  @override
  Future<void> save(AppSettings settings) async {
    value = settings;
  }
}

final class _MemoryProfilePreferences implements ActiveProfilePreferences {
  String? activeProfileId;

  @override
  Future<void> clearActiveProfileId() async {
    activeProfileId = null;
  }

  @override
  Future<String?> loadActiveProfileId() async => activeProfileId;

  @override
  Future<void> saveActiveProfileId(String profileId) async {
    activeProfileId = profileId;
  }
}

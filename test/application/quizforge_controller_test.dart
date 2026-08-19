import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/data/settings_repository.dart';
import 'package:quizforge/src/domain/app_settings.dart';
import 'package:quizforge/src/domain/profile.dart';

void main() {
  group('QuizForgeController persistence ordering', () {
    test('failed active-profile persistence keeps current profile selected', () async {
      final AppDatabase database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database.upsertProfile(
        PlayerProfile(
          id: 'profile-a',
          displayName: 'Player A',
          createdAt: DateTime(2026),
        ),
      );
      await database.upsertProfile(
        PlayerProfile(
          id: 'profile-b',
          displayName: 'Player B',
          createdAt: DateTime(2026, 1, 2),
        ),
      );

      final _FakeProfilePreferences profilePreferences =
          _FakeProfilePreferences(activeProfileId: 'profile-a');
      final QuizForgeController controller = QuizForgeController(
        database: database,
        questionRepository: QuestionRepository(database),
        settingsRepository: _FakeSettingsStore(),
        profilePreferences: profilePreferences,
      );
      await controller.initialize();
      expect(controller.activeProfile?.id, 'profile-a');

      profilePreferences.failSaves = true;
      await expectLater(
        controller.selectProfile('profile-b'),
        throwsA(isA<StateError>()),
      );

      expect(controller.activeProfile?.id, 'profile-a');
      expect(profilePreferences.activeProfileId, 'profile-a');
    });

    test('failed profile creation preference save rolls back new profile', () async {
      final AppDatabase database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final _FakeProfilePreferences profilePreferences =
          _FakeProfilePreferences();
      final QuizForgeController controller = QuizForgeController(
        database: database,
        questionRepository: QuestionRepository(database),
        settingsRepository: _FakeSettingsStore(),
        profilePreferences: profilePreferences,
      );
      await controller.initialize();

      final String originalProfileId = controller.activeProfile!.id;
      final int originalProfileCount = controller.profiles.length;
      profilePreferences.failSaves = true;

      await expectLater(
        controller.createProfile('Player B'),
        throwsA(isA<StateError>()),
      );

      expect(controller.profiles, hasLength(originalProfileCount));
      expect(controller.activeProfile?.id, originalProfileId);
      expect(profilePreferences.activeProfileId, originalProfileId);
      final List<PlayerProfile> storedProfiles = await database.loadProfiles();
      expect(storedProfiles, hasLength(originalProfileCount));
      expect(
        storedProfiles.map((PlayerProfile profile) => profile.id),
        contains(originalProfileId),
      );
    });

    test('failed active-profile deletion preference save leaves profile intact', () async {
      final AppDatabase database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database.upsertProfile(
        PlayerProfile(
          id: 'profile-a',
          displayName: 'Player A',
          createdAt: DateTime(2026),
        ),
      );
      await database.upsertProfile(
        PlayerProfile(
          id: 'profile-b',
          displayName: 'Player B',
          createdAt: DateTime(2026, 1, 2),
        ),
      );

      final _FakeProfilePreferences profilePreferences =
          _FakeProfilePreferences(activeProfileId: 'profile-a');
      final QuizForgeController controller = QuizForgeController(
        database: database,
        questionRepository: QuestionRepository(database),
        settingsRepository: _FakeSettingsStore(),
        profilePreferences: profilePreferences,
      );
      await controller.initialize();
      profilePreferences.failSaves = true;

      await expectLater(
        controller.deleteProfile('profile-a'),
        throwsA(isA<StateError>()),
      );

      expect(controller.profiles, hasLength(2));
      expect(controller.activeProfile?.id, 'profile-a');
      expect(profilePreferences.activeProfileId, 'profile-a');
      final List<PlayerProfile> storedProfiles = await database.loadProfiles();
      expect(
        storedProfiles.map((PlayerProfile profile) => profile.id).toSet(),
        <String>{'profile-a', 'profile-b'},
      );
    });

    test('failed settings persistence keeps in-memory settings unchanged', () async {
      final AppDatabase database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final _FakeSettingsStore settingsStore = _FakeSettingsStore();
      final QuizForgeController controller = QuizForgeController(
        database: database,
        questionRepository: QuestionRepository(database),
        settingsRepository: settingsStore,
        profilePreferences: _FakeProfilePreferences(),
      );
      await controller.initialize();
      expect(controller.settings.themeMode, AppThemeMode.system);

      settingsStore.failSaves = true;
      await expectLater(
        controller.updateSettings(
          controller.settings.copyWith(themeMode: AppThemeMode.dark),
        ),
        throwsA(isA<StateError>()),
      );

      expect(controller.settings.themeMode, AppThemeMode.system);
      expect(settingsStore.value.themeMode, AppThemeMode.system);
    });
  });
}

final class _FakeProfilePreferences implements ActiveProfilePreferences {
  _FakeProfilePreferences({String? activeProfileId})
      : activeProfileId = activeProfileId;

  String? activeProfileId;
  bool failSaves = false;

  @override
  Future<void> clearActiveProfileId() async {
    activeProfileId = null;
  }

  @override
  Future<String?> loadActiveProfileId() async => activeProfileId;

  @override
  Future<void> saveActiveProfileId(String profileId) async {
    if (failSaves) {
      throw StateError('simulated profile preference failure');
    }
    activeProfileId = profileId;
  }
}

final class _FakeSettingsStore implements AppSettingsStore {
  AppSettings value = const AppSettings();
  bool failSaves = false;

  @override
  Future<AppSettings> load() async => value;

  @override
  Future<void> reset() async {
    value = const AppSettings();
  }

  @override
  Future<void> save(AppSettings settings) async {
    if (failSaves) {
      throw StateError('simulated settings persistence failure');
    }
    value = settings;
  }
}

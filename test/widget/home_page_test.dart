import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/data/settings_repository.dart';
import 'package:quizforge/src/domain/app_settings.dart';
import 'package:quizforge/src/presentation/home_page.dart';

import '../test_app.dart';

void main() {
  testWidgets('opens the dedicated About page from the app bar', (
    WidgetTester tester,
  ) async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final QuizForgeController controller = QuizForgeController(
      database: database,
      questionRepository: QuestionRepository(database),
      settingsRepository: _MemorySettingsStore(),
      profilePreferences: _MemoryProfilePreferences(),
    );
    await controller.initialize();

    await tester.pumpWidget(buildTestApp(HomePage(controller: controller)));

    await tester.tap(find.byTooltip('About'));
    await tester.pumpAndSettle();

    expect(find.text('Installed version: 0.1.0'), findsOneWidget);
    expect(find.text('Made by the Sanskar'), findsOneWidget);
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

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/data/settings_repository.dart';
import 'package:quizforge/src/presentation/settings_page.dart';

import '../test_app.dart';

void main() {
  testWidgets('shows localized settings sections and project credit', (
    WidgetTester tester,
  ) async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final QuizForgeController controller = QuizForgeController(
      database: database,
      questionRepository: QuestionRepository(database),
      settingsRepository: SettingsRepository(),
      profilePreferences: ProfilePreferences(),
    );

    await tester.pumpWidget(buildTestApp(SettingsPage(controller: controller)));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Profiles'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Accessibility'), findsOneWidget);
    expect(find.text('Privacy and data'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Made by the Sanskar'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Made by the Sanskar'), findsOneWidget);
  });
}

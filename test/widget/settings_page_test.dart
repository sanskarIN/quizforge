import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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

    final Finder scrollable = find.byType(Scrollable).first;
    for (final String section in <String>[
      'Appearance',
      'Accessibility',
      'Privacy and data',
      'Updates',
      'About',
      'Made by the Sanskar',
    ]) {
      await tester.scrollUntilVisible(
        find.text(section),
        400,
        scrollable: scrollable,
      );
      expect(find.text(section), findsOneWidget);
    }
  });
}

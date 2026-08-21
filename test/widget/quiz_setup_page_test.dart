import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/data/settings_repository.dart';
import 'package:quizforge/src/presentation/quiz_setup_page.dart';

import '../test_app.dart';

void main() {
  testWidgets('disables start when no questions match', (
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

    await tester.pumpWidget(
      buildTestApp(QuizSetupPage(controller: controller)),
    );

    expect(find.text('Choose your practice set'), findsOneWidget);
    expect(
      find.text(
        'No local questions match these filters. Remove a filter or add/import matching questions.',
      ),
      findsOneWidget,
    );

    final Finder startButton = find.widgetWithText(
      FilledButton,
      'Start custom quiz',
    );
    expect(startButton, findsOneWidget);
    expect(tester.widget<FilledButton>(startButton).onPressed, isNull);
  });
}

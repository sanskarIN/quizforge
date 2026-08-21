import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/data/settings_repository.dart';
import 'package:quizforge/src/presentation/creator_page.dart';

import '../test_app.dart';

void main() {
  testWidgets('creates a valid multiple-choice question', (
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

    await tester.pumpWidget(buildTestApp(CreatorPage(controller: controller)));

    final List<Finder> fields = <Finder>[
      find.widgetWithText(TextField, 'Prompt'),
      find.widgetWithText(TextField, 'Category'),
      find.widgetWithText(TextField, 'Choices'),
      find.widgetWithText(TextField, 'Correct answers'),
    ];
    for (final Finder field in fields) {
      expect(field, findsOneWidget);
    }

    await tester.enterText(fields[0], 'Which value is the answer?');
    await tester.enterText(fields[1], 'Testing');
    await tester.enterText(fields[2], 'Alpha\nBeta');
    await tester.enterText(fields[3], 'Alpha');
    await tester.tap(find.widgetWithText(FilledButton, 'Add to question bank'));
    await tester.pumpAndSettle();

    expect(controller.questions, hasLength(1));
    expect(controller.questions.single.category, 'Testing');
    expect(controller.questions.single.correctAnswers, <String>{'Alpha'});
    expect(find.text('Question added to the local bank.'), findsOneWidget);
  });

  testWidgets('rejects a non-numeric optional time limit', (
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

    await tester.pumpWidget(buildTestApp(CreatorPage(controller: controller)));

    await tester.enterText(
      find.widgetWithText(TextField, 'Prompt'),
      'Which value is the answer?',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Category'),
      'Testing',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Choices'),
      'Alpha\nBeta',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Correct answers'),
      'Alpha',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Optional time limit (seconds)'),
      'not-a-number',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add to question bank'));
    await tester.pump();

    expect(controller.questions, isEmpty);
    expect(find.text('Time limit must be greater than zero.'), findsOneWidget);
  });

  testWidgets('duplicate accepted answers stay visible until corrected', (
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

    await tester.pumpWidget(buildTestApp(CreatorPage(controller: controller)));

    await tester.enterText(
      find.widgetWithText(TextField, 'Prompt'),
      'Which value is the answer?',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Category'),
      'Testing',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Choices'),
      'Alpha\nBeta',
    );
    final Finder answerField = find.widgetWithText(
      TextField,
      'Correct answers',
    );
    await tester.enterText(answerField, 'Alpha\n alpha ');
    await tester.pump();

    expect(
      find.text('Correct answers must be non-empty and unique.'),
      findsOneWidget,
    );

    await tester.enterText(answerField, 'Alpha');
    await tester.pump();

    expect(
      find.text('Correct answers must be non-empty and unique.'),
      findsNothing,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Add to question bank'));
    await tester.pumpAndSettle();

    expect(controller.questions, hasLength(1));
    expect(controller.questions.single.correctAnswers, <String>{'Alpha'});
  });
}

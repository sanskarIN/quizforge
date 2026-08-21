import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/data/settings_repository.dart';
import 'package:quizforge/src/domain/question.dart';
import 'package:quizforge/src/presentation/quiz_page.dart';

import '../test_app.dart';

void main() {
  testWidgets('renders localized question metadata and answer choices', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.ensureSemantics().dispose);
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final QuizForgeController controller = QuizForgeController(
      database: database,
      questionRepository: QuestionRepository(database),
      settingsRepository: SettingsRepository(),
      profilePreferences: ProfilePreferences(),
    );
    final Question question = Question(
      id: 'widget-q1',
      type: QuestionType.multipleChoice,
      prompt: 'Which option is correct?',
      choices: const <String>['Alpha', 'Beta'],
      correctAnswers: const <String>{'Alpha'},
      category: 'Widget',
      difficulty: Difficulty.easy,
    );

    await tester.pumpWidget(
      buildTestApp(
        QuizPage(
          controller: controller,
          questions: <Question>[question],
          title: 'Widget Quiz',
        ),
      ),
    );

    expect(find.text('Widget Quiz'), findsOneWidget);
    expect(find.text('Which option is correct?'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Multiple choice'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
    expect(find.bySemanticsLabel('Question 1 of 1'), findsOneWidget);
  });
}

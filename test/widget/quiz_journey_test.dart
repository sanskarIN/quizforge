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
  testWidgets('completes a one-question quiz and opens review', (
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
    final Question question = Question(
      id: 'journey-q1',
      type: QuestionType.multipleChoice,
      prompt: 'Which fixture answer is correct?',
      choices: const <String>['Alpha', 'Beta'],
      correctAnswers: const <String>{'Alpha'},
      category: 'Testing',
      difficulty: Difficulty.easy,
      explanation: 'Alpha is the deterministic fixture answer.',
    );

    await tester.pumpWidget(
      buildTestApp(
        QuizPage(
          controller: controller,
          questions: <Question>[question],
          title: 'Journey Quiz',
        ),
      ),
    );

    await tester.tap(find.text('Alpha'));
    await tester.tap(find.text('Finish quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Review'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Correct answer: Alpha'), findsOneWidget);
    expect(
      find.text('Alpha is the deterministic fixture answer.'),
      findsOneWidget,
    );
  });
}

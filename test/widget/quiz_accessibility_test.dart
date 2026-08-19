import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/data/settings_repository.dart';
import 'package:quizforge/src/domain/question.dart';
import 'package:quizforge/src/domain/quiz_config.dart';
import 'package:quizforge/src/presentation/quiz_page.dart';

import '../test_app.dart';

void main() {
  testWidgets('exposes localized quiz progress and timer semantics', (
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
      id: 'a11y-q1',
      type: QuestionType.trueFalse,
      prompt: 'This is a deterministic accessibility fixture.',
      correctAnswers: const <String>{'true'},
      category: 'Accessibility',
      difficulty: Difficulty.easy,
    );

    await tester.pumpWidget(
      buildTestApp(
        QuizPage(
          controller: controller,
          questions: <Question>[question],
          title: 'Accessible Quiz',
          config: const QuizConfig(
            questionCount: 1,
            timed: true,
            defaultSecondsPerQuestion: 20,
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Question 1 of 1'), findsOneWidget);
    expect(find.bySemanticsLabel('20 seconds remaining'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.bySemanticsLabel('19 seconds remaining'), findsOneWidget);
  });
}

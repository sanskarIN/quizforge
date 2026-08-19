import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/core/logging/app_logger.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/domain/question.dart';
import 'package:quizforge/src/domain/quiz_result.dart';
import 'package:quizforge/src/presentation/review_page.dart';

import '../application/controller_fakes.dart';
import '../test_app.dart';

void main() {
  testWidgets('shows localized review labels and answer details', (tester) async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final Question question = Question(
      id: 'review-q1',
      type: QuestionType.shortAnswer,
      prompt: 'Review this answer.',
      correctAnswers: const <String>{'yes'},
      category: 'Review',
      difficulty: Difficulty.easy,
      explanation: 'A short explanation.',
    );
    final QuizForgeController controller = QuizForgeController(
      database: database,
      questionRepository: FakeQuestionStore(<Question>[question]),
      settingsRepository: FakeSettingsStore(),
      profilePreferences: FakeProfileSelectionStore(),
      logger: AppLogger(sink: (_) {}),
    );
    await controller.initialize();
    final DateTime startedAt = DateTime(2026, 8, 19, 14);
    final QuizResult result = QuizResult(
      startedAt: startedAt,
      completedAt: startedAt.add(const Duration(seconds: 3)),
      evaluations: const <QuestionEvaluation>[
        QuestionEvaluation(
          questionId: 'review-q1',
          submittedAnswers: <String>{'yes'},
          correct: true,
          score: 1,
        ),
      ],
    );

    await tester.pumpWidget(
      buildTestApp(
        ReviewPage(
          controller: controller,
          questions: <Question>[question],
          result: result,
        ),
      ),
    );

    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Answer review'), findsOneWidget);
    expect(find.text('Score'), findsOneWidget);
    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('Your answer: yes'), findsOneWidget);
    expect(find.text('Correct answer: yes'), findsOneWidget);
    expect(find.byTooltip('Bookmark question'), findsOneWidget);
  });
}

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/core/logging/app_logger.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/domain/question.dart';
import 'package:quizforge/src/presentation/question_bank_page.dart';

import '../application/controller_fakes.dart';
import '../test_app.dart';

void main() {
  testWidgets('shows localized bank labels and localized enum chips', (tester) async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final Question question = Question(
      id: 'bank-q1',
      type: QuestionType.multipleChoice,
      prompt: 'Which option is correct?',
      choices: const <String>['Alpha', 'Beta'],
      correctAnswers: const <String>{'Alpha'},
      category: 'Testing',
      difficulty: Difficulty.easy,
      tags: const <String>['bank'],
    );
    final QuizForgeController controller = QuizForgeController(
      database: database,
      questionRepository: FakeQuestionStore(<Question>[question]),
      settingsRepository: FakeSettingsStore(),
      profilePreferences: FakeProfileSelectionStore(),
      logger: AppLogger(sink: (_) {}),
    );
    await controller.initialize();

    await tester.pumpWidget(
      buildTestApp(QuestionBankPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Question bank'), findsOneWidget);
    expect(find.text('Import / export'), findsOneWidget);
    expect(find.text('Search questions, categories, or tags'), findsOneWidget);
    expect(find.text('1 question'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Multiple choice'), findsOneWidget);
    expect(find.byTooltip('Bookmark question'), findsOneWidget);
  });
}

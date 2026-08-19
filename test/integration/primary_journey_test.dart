import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/app.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/core/logging/app_logger.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/onboarding_store.dart';
import 'package:quizforge/src/domain/question.dart';

import '../application/controller_fakes.dart';

void main() {
  testWidgets(
    'primary journey starts app plays quiz and persists result',
    (WidgetTester tester) async {
      final AppDatabase database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final Question question = Question(
        id: 'journey-q1',
        type: QuestionType.shortAnswer,
        prompt: 'Type pass to complete the journey.',
        correctAnswers: const <String>{'pass'},
        category: 'Journey',
        difficulty: Difficulty.easy,
      );
      await database.upsertQuestions(<Question>[question]);

      final QuizForgeController controller = QuizForgeController(
        database: database,
        questionRepository: FakeQuestionStore(<Question>[question]),
        settingsRepository: FakeSettingsStore(),
        profilePreferences: FakeProfileSelectionStore(),
        logger: AppLogger(sink: (_) {}),
      );
      await controller.initialize();

      await tester.pumpWidget(
        QuizForgeApp(
          controller: controller,
          onboardingStore: _CompletedOnboardingStore(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ready to forge your next score?'), findsOneWidget);
      final Finder startPractice = find.text('Start practice');
      await tester.ensureVisible(startPractice);
      await tester.tap(startPractice);
      await tester.pumpAndSettle();

      expect(find.text('Random Practice'), findsOneWidget);
      expect(find.text(question.prompt), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'pass');
      await tester.tap(find.text('Finish quiz'));
      await tester.pumpAndSettle();

      expect(find.text('Review'), findsOneWidget);
      expect(controller.progress.quizCount, 1);
      expect(controller.progress.correctCount, 1);
      expect(controller.progress.accuracy, 100);

      final stored = await database.loadProgress(controller.activeProfile!.id);
      expect(stored.quizCount, 1);
      expect(stored.correctCount, 1);
    },
  );
}

final class _CompletedOnboardingStore implements OnboardingStore {
  @override
  Future<bool> isCompleted() async => true;

  @override
  Future<void> markCompleted() async {}

  @override
  Future<void> reset() async {}
}

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/data/settings_repository.dart';
import 'package:quizforge/src/domain/quiz_result.dart';
import 'package:quizforge/src/presentation/stats_page.dart';

import '../test_app.dart';

void main() {
  testWidgets('renders a persisted recent attempt in statistics', (
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
    await controller.initialize();

    final String questionId = controller.questions.first.id;
    final DateTime startedAt = DateTime(2026, 8, 19, 10, 15);
    await controller.recordResult(
      QuizResult(
        startedAt: startedAt,
        completedAt: startedAt.add(const Duration(seconds: 18)),
        evaluations: <QuestionEvaluation>[
          QuestionEvaluation(
            questionId: questionId,
            submittedAnswers: const <String>{'test'},
            correct: true,
            score: 1,
          ),
        ],
      ),
    );

    await tester.pumpWidget(buildTestApp(StatsPage(controller: controller)));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.history_outlined), findsOneWidget);
    expect(find.textContaining('1/1'), findsOneWidget);
    expect(find.textContaining('100%'), findsWidgets);
    expect(find.textContaining('18s'), findsOneWidget);
  });
}

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/core/logging/app_logger.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/presentation/stats_page.dart';

import '../application/controller_fakes.dart';
import '../test_app.dart';

void main() {
  testWidgets('shows localized statistics labels for a new profile', (tester) async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final QuizForgeController controller = QuizForgeController(
      database: database,
      questionRepository: FakeQuestionStore(),
      settingsRepository: FakeSettingsStore(),
      profilePreferences: FakeProfileSelectionStore(),
      logger: AppLogger(sink: (_) {}),
    );
    await controller.initialize();

    await tester.pumpWidget(buildTestApp(StatsPage(controller: controller)));
    await tester.pumpAndSettle();

    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Statistics for Local Player.'), findsOneWidget);
    expect(find.text('Quizzes completed'), findsOneWidget);
    expect(find.text('Questions answered'), findsOneWidget);
    expect(find.text('Category performance'), findsOneWidget);
    expect(find.text('Complete a quiz to see category-level statistics.'), findsOneWidget);
    expect(find.text('Local leaderboard'), findsOneWidget);
    expect(find.text('Complete a quiz to populate the leaderboard.'), findsOneWidget);
  });
}

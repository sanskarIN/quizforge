import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/core/logging/app_logger.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/presentation/settings_page.dart';

import '../application/controller_fakes.dart';
import '../test_app.dart';

void main() {
  testWidgets('shows localized settings and accessibility labels', (tester) async {
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

    await tester.pumpWidget(buildTestApp(SettingsPage(controller: controller)));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Profiles'), findsOneWidget);
    expect(find.text('Active local profile'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Accessibility'), findsOneWidget);
    expect(find.text('Large text'), findsOneWidget);
    expect(find.text('Reduced motion'), findsOneWidget);
    expect(find.text('Screen-reader hints'), findsOneWidget);
    expect(find.text('Confirm before leaving a quiz'), findsOneWidget);
  });
}

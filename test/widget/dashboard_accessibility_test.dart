import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/data/settings_repository.dart';
import 'package:quizforge/src/presentation/dashboard_page.dart';

import '../test_app.dart';

void main() {
  testWidgets('dashboard cards do not overflow at narrow large text layout', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final QuizForgeController controller = QuizForgeController(
      database: database,
      questionRepository: QuestionRepository(database),
      settingsRepository: SettingsRepository(),
      profilePreferences: ProfilePreferences(),
    );

    await tester.pumpWidget(
      buildTestApp(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 800),
            textScaler: TextScaler.linear(2),
          ),
          child: DashboardPage(controller: controller),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Daily quiz'), findsOneWidget);
    expect(find.text('Random practice'), findsOneWidget);
    expect(find.text('Timed sprint'), findsOneWidget);
    expect(find.text('Build a quiz'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

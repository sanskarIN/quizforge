import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/data/settings_repository.dart';
import 'package:quizforge/src/presentation/import_export_page.dart';

import '../test_app.dart';

void main() {
  testWidgets('imports a valid JSON question bank', (WidgetTester tester) async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final QuizForgeController controller = QuizForgeController(
      database: database,
      questionRepository: QuestionRepository(database),
      settingsRepository: SettingsRepository(),
      profilePreferences: ProfilePreferences(),
    );

    const String source = '''
{
  "questions": [
    {
      "id": "import-widget-1",
      "type": "shortAnswer",
      "prompt": "What word is used by this fixture?",
      "choices": [],
      "correctAnswers": ["fixture"],
      "category": "Testing",
      "difficulty": "easy",
      "tags": ["widget"],
      "explanation": "A deterministic fictional fixture.",
      "timeLimitSeconds": null
    }
  ]
}
''';

    await tester.pumpWidget(
      buildTestApp(ImportExportPage(controller: controller)),
    );

    final Finder importField = find.byType(TextField);
    expect(importField, findsOneWidget);
    await tester.enterText(importField, source);
    await tester.tap(find.widgetWithText(FilledButton, 'Validate and import'));
    await tester.pumpAndSettle();

    expect(controller.questions, hasLength(1));
    expect(controller.questions.single.id, 'import-widget-1');
    expect(find.text('Import report'), findsOneWidget);
    expect(find.text('Import: 1'), findsOneWidget);
  });
}

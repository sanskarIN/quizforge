import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/core/logging/app_logger.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/data/question_repository.dart';
import 'package:quizforge/src/presentation/import_export_page.dart';

import '../application/controller_fakes.dart';
import '../test_app.dart';

void main() {
  testWidgets('valid local backup requires confirmation and restores successfully', (
    WidgetTester tester,
  ) async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final QuizForgeController controller = QuizForgeController(
      database: database,
      questionRepository: QuestionRepository(database),
      settingsRepository: FakeSettingsStore(),
      profilePreferences: FakeProfileSelectionStore(),
      logger: AppLogger(sink: (_) {}),
    );
    await controller.initialize();
    final String archive = await controller.exportLocalBackup();

    await tester.pumpWidget(
      buildTestApp(ImportExportPage(controller: controller)),
    );

    final Finder backupField = find.byWidgetPredicate(
      (Widget widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Paste local backup JSON',
    );
    expect(backupField, findsOneWidget);
    await tester.enterText(backupField, archive);

    final Finder restoreButton =
        find.widgetWithText(FilledButton, 'Restore backup');
    await tester.ensureVisible(restoreButton);
    await tester.tap(restoreButton);
    await tester.pumpAndSettle();

    expect(find.text('Replace current local data?'), findsOneWidget);
    final Finder confirmRestore = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, 'Restore backup'),
    );
    expect(confirmRestore, findsOneWidget);
    await tester.tap(confirmRestore);
    await tester.pumpAndSettle();

    expect(find.text('Local backup restored.'), findsOneWidget);
    expect(controller.activeProfile?.id, 'local-default');
  });
}

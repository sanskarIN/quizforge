import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/application/quizforge_controller.dart';
import 'package:quizforge/src/core/logging/app_logger.dart';
import 'package:quizforge/src/data/app_database.dart';
import 'package:quizforge/src/domain/profile.dart';

import 'controller_fakes.dart';

void main() {
  test('selectProfile keeps the current profile when preference save fails', () async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.upsertProfile(
      const PlayerProfile(id: 'profile-a', displayName: 'Alpha Player'),
    );
    await database.upsertProfile(
      const PlayerProfile(id: 'profile-b', displayName: 'Beta Player'),
    );
    final FakeProfileSelectionStore profileSelectionStore =
        FakeProfileSelectionStore(activeProfileId: 'profile-a');
    final QuizForgeController controller = QuizForgeController(
      database: database,
      questionRepository: FakeQuestionStore(),
      settingsRepository: FakeSettingsStore(),
      profilePreferences: profileSelectionStore,
      logger: AppLogger(sink: (_) {}),
    );
    await controller.initialize();
    expect(controller.activeProfile?.id, 'profile-a');

    profileSelectionStore.failSave = true;
    await expectLater(
      controller.selectProfile('profile-b'),
      throwsStateError,
    );

    expect(controller.activeProfile?.id, 'profile-a');
  });
}

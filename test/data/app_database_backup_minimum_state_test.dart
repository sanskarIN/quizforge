import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/data/app_database_backup.dart';
import 'package:quizforge/src/domain/profile.dart';
import 'package:quizforge/src/domain/question.dart';

void main() {
  test('whole-app backup requires at least one question', () {
    const DatabaseBackupSnapshot snapshot = DatabaseBackupSnapshot(
      questions: <Question>[],
      profiles: <PlayerProfile>[
        PlayerProfile(id: 'profile-1', displayName: 'Local Player'),
      ],
      attempts: <BackupAttempt>[],
      bookmarks: <BackupBookmark>[],
    );

    expect(
      snapshot.validate(),
      contains('Local backup must contain at least one question.'),
    );
  });
}

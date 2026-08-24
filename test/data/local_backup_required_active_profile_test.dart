import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/data/app_database_backup.dart';
import 'package:quizforge/src/data/local_backup_codec.dart';
import 'package:quizforge/src/domain/app_settings.dart';
import 'package:quizforge/src/domain/profile.dart';
import 'package:quizforge/src/domain/question.dart';

void main() {
  const LocalBackupCodec codec = LocalBackupCodec();
  final Question question = Question(
    id: 'required-active-q1',
    type: QuestionType.shortAnswer,
    prompt: 'Which profile must be selected?',
    correctAnswers: const <String>{'active'},
    category: 'Backup',
    difficulty: Difficulty.easy,
  );
  final DateTime createdAt = DateTime.utc(2026, 8, 19, 12);
  final DatabaseBackupSnapshot database = DatabaseBackupSnapshot(
    questions: <Question>[question],
    profiles: const <PlayerProfile>[
      PlayerProfile(id: 'profile-1', displayName: 'Local Player'),
    ],
    attempts: const <BackupAttempt>[],
    bookmarks: const <BackupBookmark>[],
  );

  test('encoder rejects a missing active profile', () {
    final LocalBackupPayload payload = LocalBackupPayload(
      createdAt: createdAt,
      database: database,
      settings: const AppSettings(),
      activeProfileId: null,
    );

    expect(() => codec.encode(payload), throwsStateError);
  });

  test('decoder rejects an archive with a null active profile', () {
    final String validArchive = codec.encode(
      LocalBackupPayload(
        createdAt: createdAt,
        database: database,
        settings: const AppSettings(),
        activeProfileId: 'profile-1',
      ),
    );
    final String invalidArchive = validArchive.replaceFirst(
      '"activeProfileId": "profile-1"',
      '"activeProfileId": null',
    );

    expect(() => codec.decode(invalidArchive), throwsFormatException);
  });
}

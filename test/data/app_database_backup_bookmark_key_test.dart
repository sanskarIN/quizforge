import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/data/app_database_backup.dart';
import 'package:quizforge/src/domain/profile.dart';
import 'package:quizforge/src/domain/question.dart';

void main() {
  test('distinct bookmark pairs cannot collide through string delimiters', () {
    final List<Question> questions = <Question>[
      Question(
        id: 'c',
        type: QuestionType.shortAnswer,
        prompt: 'First bookmark key fixture?',
        correctAnswers: const <String>{'yes'},
        category: 'Backup',
        difficulty: Difficulty.easy,
      ),
      Question(
        id: 'b\u0000c',
        type: QuestionType.shortAnswer,
        prompt: 'Second bookmark key fixture?',
        correctAnswers: const <String>{'yes'},
        category: 'Backup',
        difficulty: Difficulty.easy,
      ),
    ];
    const List<PlayerProfile> profiles = <PlayerProfile>[
      PlayerProfile(id: 'a\u0000b', displayName: 'First Player'),
      PlayerProfile(id: 'a', displayName: 'Second Player'),
    ];
    final DatabaseBackupSnapshot snapshot = DatabaseBackupSnapshot(
      questions: questions,
      profiles: profiles,
      attempts: const <BackupAttempt>[],
      bookmarks: const <BackupBookmark>[
        BackupBookmark(profileId: 'a\u0000b', questionId: 'c'),
        BackupBookmark(profileId: 'a', questionId: 'b\u0000c'),
      ],
    );

    expect(snapshot.validate(), isEmpty);
  });
}

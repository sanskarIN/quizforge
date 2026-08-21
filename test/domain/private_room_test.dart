import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/domain/private_room.dart';
import 'package:quizforge/src/domain/question.dart';

void main() {
  const DisabledPrivateRoomTransport transport = DisabledPrivateRoomTransport();
  const RoomPlayer player = RoomPlayer(
    id: 'player-1',
    displayName: 'Player One',
  );

  test('create room fails closed while networking is disabled', () async {
    final Question question = Question(
      id: 'q1',
      type: QuestionType.trueFalse,
      prompt: 'Offline mode is enabled.',
      correctAnswers: const <String>{'true'},
      category: 'Demo',
      difficulty: Difficulty.easy,
    );

    await expectLater(
      transport.createRoom(host: player, questions: <Question>[question]),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test(
    'joining and submitting fail closed while networking is disabled',
    () async {
      await expectLater(
        transport.joinRoom(roomCode: 'ABC123', player: player),
        throwsA(isA<UnsupportedError>()),
      );
      await expectLater(
        transport.submitAnswer(
          roomCode: 'ABC123',
          playerId: player.id,
          questionId: 'q1',
          answers: const <String>{'true'},
        ),
        throwsA(isA<UnsupportedError>()),
      );
    },
  );

  test('room watcher emits an unsupported error', () async {
    await expectLater(
      transport.watchRoom('ABC123'),
      emitsError(isA<UnsupportedError>()),
    );
  });
}

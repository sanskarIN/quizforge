import 'question.dart';

final class RoomPlayer {
  const RoomPlayer({
    required this.id,
    required this.displayName,
    this.score = 0,
  });

  final String id;
  final String displayName;
  final int score;
}

final class PrivateRoomSnapshot {
  const PrivateRoomSnapshot({
    required this.roomCode,
    required this.hostPlayerId,
    required this.players,
    required this.questionIds,
    required this.started,
  });

  final String roomCode;
  final String hostPlayerId;
  final List<RoomPlayer> players;
  final List<String> questionIds;
  final bool started;
}

abstract interface class PrivateRoomTransport {
  Stream<PrivateRoomSnapshot> watchRoom(String roomCode);

  Future<PrivateRoomSnapshot> createRoom({
    required RoomPlayer host,
    required List<Question> questions,
  });

  Future<void> joinRoom({required String roomCode, required RoomPlayer player});

  Future<void> submitAnswer({
    required String roomCode,
    required String playerId,
    required String questionId,
    required Set<String> answers,
  });

  Future<void> leaveRoom({required String roomCode, required String playerId});
}

/// Intentionally local-only until an explicit, privacy-reviewed transport is
/// configured. This keeps multiplayer concerns out of core quiz logic.
final class DisabledPrivateRoomTransport implements PrivateRoomTransport {
  const DisabledPrivateRoomTransport();

  static UnsupportedError _disabled() => UnsupportedError(
    'Private-room networking is not enabled in this offline build.',
  );

  @override
  Future<PrivateRoomSnapshot> createRoom({
    required RoomPlayer host,
    required List<Question> questions,
  }) async => throw _disabled();

  @override
  Future<void> joinRoom({
    required String roomCode,
    required RoomPlayer player,
  }) async => throw _disabled();

  @override
  Future<void> leaveRoom({
    required String roomCode,
    required String playerId,
  }) async => throw _disabled();

  @override
  Future<void> submitAnswer({
    required String roomCode,
    required String playerId,
    required String questionId,
    required Set<String> answers,
  }) async => throw _disabled();

  @override
  Stream<PrivateRoomSnapshot> watchRoom(String roomCode) =>
      Stream<PrivateRoomSnapshot>.error(_disabled());
}

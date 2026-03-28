import 'package:equatable/equatable.dart';

/// Outcome of [JoinRoomUseCase] — Bloc maps this to [RoomState].
sealed class JoinRoomResult extends Equatable {
  const JoinRoomResult();

  @override
  List<Object?> get props => [];
}

final class JoinRoomSuccessResult extends JoinRoomResult {
  const JoinRoomSuccessResult({
    required this.roomId,
    required this.roomCode,
    required this.userId,
    required this.userName,
    required this.avatar,
    required this.joinedAt,
  });

  final String roomId;
  final String roomCode;
  final String userId;
  final String userName;
  final String avatar;
  final DateTime joinedAt;

  @override
  List<Object?> get props => [
    roomId,
    roomCode,
    userId,
    userName,
    avatar,
    joinedAt,
  ];
}

final class JoinRoomFailureResult extends JoinRoomResult {
  const JoinRoomFailureResult(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

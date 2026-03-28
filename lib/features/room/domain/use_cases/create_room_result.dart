import 'package:equatable/equatable.dart';

sealed class CreateRoomResult extends Equatable {
  const CreateRoomResult();

  @override
  List<Object?> get props => [];
}

final class CreateRoomSuccessResult extends CreateRoomResult {
  const CreateRoomSuccessResult({
    required this.roomId,
    required this.roomCode,
    required this.roomName,
    required this.userId,
    required this.userName,
    required this.avatar,
    required this.joinedAt,
  });

  final String roomId;
  final String roomCode;
  final String roomName;
  final String userId;
  final String userName;
  final String avatar;
  final DateTime joinedAt;

  @override
  List<Object?> get props => [
    roomId,
    roomCode,
    roomName,
    userId,
    userName,
    avatar,
    joinedAt,
  ];
}

final class CreateRoomFailureResult extends CreateRoomResult {
  const CreateRoomFailureResult(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

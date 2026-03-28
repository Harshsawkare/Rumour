import 'package:equatable/equatable.dart';

/// Arguments for [AppRoutePaths.chat] — identity is resolved on-device via [roomId].
final class ChatRouteArgs extends Equatable {
  const ChatRouteArgs({
    required this.roomId,
    required this.roomCode,
    this.roomName,
  });

  final String roomId;
  final String roomCode;
  final String? roomName;

  @override
  List<Object?> get props => [roomId, roomCode, roomName];
}

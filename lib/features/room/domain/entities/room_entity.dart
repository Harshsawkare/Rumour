import 'package:equatable/equatable.dart';

/// Domain room aggregate (no Firestore types).
final class Room extends Equatable {
  const Room({
    required this.id,
    required this.roomCode,
    required this.roomName,
    required this.createdAt,
  });

  final String id;
  final String roomCode;
  final String roomName;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, roomCode, roomName, createdAt];
}

import 'package:equatable/equatable.dart';

/// Chat line persisted in Firestore (distinct from UI-only [ChatMessage]).
final class RoomMessage extends Equatable {
  const RoomMessage({
    required this.id,
    required this.text,
    required this.userId,
    required this.userName,
    required this.avatar,
    required this.createdAt,
  });

  final String id;
  final String text;
  final String userId;
  final String userName;
  final String avatar;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, text, userId, userName, avatar, createdAt];
}

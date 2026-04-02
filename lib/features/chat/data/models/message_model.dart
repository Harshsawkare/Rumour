import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:room_chat/core/constants/firestore_field_keys.dart';

/// Firestore DTO for `rooms/{roomId}/messages/{messageId}`.
final class MessageModel extends Equatable {
  const MessageModel({
    required this.id,
    required this.text,
    required this.userId,
    required this.userName,
    required this.avatar,
    required this.createdAt,
    this.isPendingSync = false,
  });

  final String id;
  final String text;
  final String userId;
  final String userName;
  final String avatar;
  final DateTime createdAt;

  /// True when [createdAt] was inferred locally (server time not in snapshot yet).
  final bool isPendingSync;

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    final created = map[FirestoreFieldKeys.createdAt];
    if (created is Timestamp) {
      return MessageModel(
        id: id,
        text: map[FirestoreFieldKeys.text] as String? ?? '',
        userId: map[FirestoreFieldKeys.userId] as String? ?? '',
        userName: map[FirestoreFieldKeys.userName] as String? ?? '',
        avatar: map[FirestoreFieldKeys.avatar] as String? ?? '',
        createdAt: created.toDate(),
        isPendingSync: false,
      );
    }
    // Pending writes with serverTimestamp() often omit a Timestamp until sync — use "now"
    // so ordering matches newest-at-bottom; epoch would sort as oldest and jump to the top.
    return MessageModel(
      id: id,
      text: map[FirestoreFieldKeys.text] as String? ?? '',
      userId: map[FirestoreFieldKeys.userId] as String? ?? '',
      userName: map[FirestoreFieldKeys.userName] as String? ?? '',
      avatar: map[FirestoreFieldKeys.avatar] as String? ?? '',
      createdAt: DateTime.now(),
      isPendingSync: true,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      FirestoreFieldKeys.text: text,
      FirestoreFieldKeys.userId: userId,
      FirestoreFieldKeys.userName: userName,
      FirestoreFieldKeys.avatar: avatar,
      FirestoreFieldKeys.createdAt: Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props =>
      [id, text, userId, userName, avatar, createdAt, isPendingSync];
}

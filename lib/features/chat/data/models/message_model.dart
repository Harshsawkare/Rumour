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
  });

  final String id;
  final String text;
  final String userId;
  final String userName;
  final String avatar;
  final DateTime createdAt;

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    final created = map[FirestoreFieldKeys.createdAt];
    return MessageModel(
      id: id,
      text: map[FirestoreFieldKeys.text] as String? ?? '',
      userId: map[FirestoreFieldKeys.userId] as String? ?? '',
      userName: map[FirestoreFieldKeys.userName] as String? ?? '',
      avatar: map[FirestoreFieldKeys.avatar] as String? ?? '',
      createdAt: created is Timestamp
          ? created.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
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
  List<Object?> get props => [id, text, userId, userName, avatar, createdAt];
}

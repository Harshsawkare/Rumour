import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:room_chat/core/constants/firestore_field_keys.dart';

/// Firestore DTO for `rooms/{roomId}`.
final class RoomModel extends Equatable {
  const RoomModel({
    required this.id,
    required this.roomCode,
    required this.roomName,
    required this.createdAt,
  });

  final String id;
  final String roomCode;
  final String roomName;
  final DateTime createdAt;

  factory RoomModel.fromMap(String id, Map<String, dynamic> map) {
    final created = map[FirestoreFieldKeys.createdAt];
    return RoomModel(
      id: id,
      roomCode: map[FirestoreFieldKeys.roomCode] as String? ?? '',
      roomName: map[FirestoreFieldKeys.roomName] as String? ?? '',
      createdAt: created is Timestamp
          ? created.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      FirestoreFieldKeys.roomCode: roomCode,
      FirestoreFieldKeys.roomName: roomName,
      FirestoreFieldKeys.createdAt: Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [id, roomCode, roomName, createdAt];
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:room_chat/core/constants/firestore_field_keys.dart';

/// Firestore DTO for `rooms/{roomId}/participants/{deviceId}`.
///
/// Document id is [deviceId]; [userId] is the profile id used on messages.
final class ParticipantModel extends Equatable {
  const ParticipantModel({
    required this.deviceId,
    required this.userId,
    required this.joinedAt,
    required this.userName,
    required this.avatar,
  });

  /// Same as Firestore document id.
  final String deviceId;
  final String userId;
  final DateTime joinedAt;
  final String userName;
  final String avatar;

  factory ParticipantModel.fromMap(String deviceId, Map<String, dynamic> map) {
    final joined = map[FirestoreFieldKeys.joinedAt];
    return ParticipantModel(
      deviceId: deviceId,
      userId: map[FirestoreFieldKeys.userId] as String? ?? '',
      joinedAt: joined is Timestamp
          ? joined.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      userName: map[FirestoreFieldKeys.userName] as String? ?? '',
      avatar: map[FirestoreFieldKeys.avatar] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap({bool joinedAtServerTimestamp = false}) {
    return <String, dynamic>{
      FirestoreFieldKeys.userId: userId,
      FirestoreFieldKeys.userName: userName,
      FirestoreFieldKeys.avatar: avatar,
      FirestoreFieldKeys.joinedAt: joinedAtServerTimestamp
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(joinedAt),
    };
  }

  @override
  List<Object?> get props => [deviceId, userId, joinedAt, userName, avatar];
}

import 'package:equatable/equatable.dart';

/// Participant in a room (document id = device id).
final class Participant extends Equatable {
  const Participant({
    required this.deviceId,
    required this.userId,
    required this.joinedAt,
    required this.userName,
    required this.avatar,
  });

  final String deviceId;
  final String userId;
  final DateTime joinedAt;
  final String userName;
  final String avatar;

  @override
  List<Object?> get props => [deviceId, userId, joinedAt, userName, avatar];
}

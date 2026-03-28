import 'package:room_chat/features/room/data/models/participant_model.dart';
import 'package:room_chat/features/room/domain/entities/participant_entity.dart';

extension ParticipantModelMapper on ParticipantModel {
  Participant toEntity() => Participant(
        deviceId: deviceId,
        userId: userId,
        joinedAt: joinedAt,
        userName: userName,
        avatar: avatar,
      );
}

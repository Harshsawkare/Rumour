import 'package:room_chat/features/chat/data/models/message_model.dart';
import 'package:room_chat/features/chat/domain/entities/room_message_entity.dart';

extension MessageModelMapper on MessageModel {
  RoomMessage toEntity() => RoomMessage(
    id: id,
    text: text,
    userId: userId,
    userName: userName,
    avatar: avatar,
    createdAt: createdAt,
  );
}

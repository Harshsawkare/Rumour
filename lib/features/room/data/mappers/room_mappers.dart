import 'package:room_chat/features/room/data/models/room_model.dart';
import 'package:room_chat/features/room/domain/entities/room_entity.dart';

extension RoomModelMapper on RoomModel {
  Room toEntity() => Room(
    id: id,
    roomCode: roomCode,
    roomName: roomName,
    createdAt: createdAt,
  );
}

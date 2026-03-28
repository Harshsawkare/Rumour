import 'package:equatable/equatable.dart';

import 'package:room_chat/features/chat/domain/entities/room_message_entity.dart';

/// One page of older messages (pagination). [hasMore] is true when the batch is full.
final class RoomMessagePage extends Equatable {
  const RoomMessagePage({required this.messages, required this.hasMore});

  final List<RoomMessage> messages;
  final bool hasMore;

  @override
  List<Object?> get props => [messages, hasMore];
}

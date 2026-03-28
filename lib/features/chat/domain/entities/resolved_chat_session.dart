import 'package:room_chat/features/room/domain/entities/participant_entity.dart';

/// Result of [ResolveChatSessionUseCase]: participant row + whether it was created in this call.
final class ResolvedChatSession {
  const ResolvedChatSession({
    required this.participant,
    required this.isNewParticipant,
  });

  final Participant participant;

  /// `true` only when a new `participants/{deviceId}` document was written in this session.
  final bool isNewParticipant;
}

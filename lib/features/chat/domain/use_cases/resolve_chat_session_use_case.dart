import 'package:room_chat/core/services/device_id_service.dart';
import 'package:room_chat/core/services/user_identity_service.dart';
import 'package:room_chat/core/utils/repository_result.dart';
import 'package:room_chat/features/chat/domain/entities/resolved_chat_session.dart';
import 'package:room_chat/features/room/domain/repositories/room_repository.dart';

/// Resolves or creates `participants/{deviceId}` for the chat screen.
final class ResolveChatSessionUseCase {
  ResolveChatSessionUseCase({
    required RoomRepository roomRepository,
    required UserIdentityService identityService,
    DeviceIdService? deviceIdService,
  })  : _roomRepository = roomRepository,
        _identityService = identityService,
        _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  final RoomRepository _roomRepository;
  final UserIdentityService _identityService;
  final DeviceIdService _deviceIdService;

  /// Returns existing participant or creates one with RandomUser + server `joinedAt`.
  ///
  /// [ResolvedChatSession.isNewParticipant] is `true` only when this flow created the doc (first-time join).
  Future<RepositoryResult<ResolvedChatSession>> execute(String roomId) async {
    final deviceId = _deviceIdService.deviceId;

    final existing = await _roomRepository.getParticipant(
      roomId: roomId,
      deviceId: deviceId,
    );
    switch (existing) {
      case RepositorySuccess(:final data):
        final p = data;
        if (p != null) {
          return RepositorySuccess(
            ResolvedChatSession(participant: p, isNewParticipant: false),
          );
        }
        break;
      case RepositoryFailure(:final message, :final cause):
        return RepositoryFailure(message, cause);
    }

    final profile = await _identityService.createAnonymousProfileOrFallback();
    final upsert = await _roomRepository.createParticipantIfAbsent(
      roomId: roomId,
      deviceId: deviceId,
      userId: profile.userId,
      userName: profile.userName,
      avatar: profile.avatarUrl,
    );
    switch (upsert) {
      case RepositorySuccess(:final data):
        return RepositorySuccess(
          ResolvedChatSession(
            participant: data.participant,
            isNewParticipant: data.isNew,
          ),
        );
      case RepositoryFailure(:final message, :final cause):
        return RepositoryFailure(message, cause);
    }
  }
}

import 'package:room_chat/core/utils/repository_result.dart';
import 'package:room_chat/features/room/domain/entities/participant_entity.dart';
import 'package:room_chat/features/room/domain/entities/room_entity.dart';

/// Room lifecycle and participants — implemented in [features/room/data].
abstract class RoomRepository {
  /// Server-allocated room code (legacy / simple create).
  Future<RepositoryResult<Room>> createRoom(String roomName);

  /// Caller-resolved unique [roomCode] (create flow with collision retries in use case).
  Future<RepositoryResult<Room>> createRoomWithCode({
    required String roomCode,
    required String roomName,
  });

  Future<RepositoryResult<Room?>> getRoomByCode(String roomCode);

  /// Single room document `rooms/{roomId}` (e.g. for title + metadata).
  Future<RepositoryResult<Room?>> getRoomById(String roomId);

  /// Updates when participants join/leave.
  Stream<int> watchParticipantCount(String roomId);

  /// `true` if [roomName] is already stored on a room document.
  Future<RepositoryResult<bool>> isRoomNameTaken(String roomName);

  /// Document path: `participants/{deviceId}`.
  Future<RepositoryResult<void>> addParticipant({
    required String roomId,
    required String deviceId,
    required String userId,
    required String userName,
    required String avatar,
    required bool useServerJoinedAt,
    DateTime? joinedAt,
  });

  Future<RepositoryResult<Participant?>> getParticipant({
    required String roomId,
    required String deviceId,
  });

  /// Transactional create for `participants/{deviceId}` when missing. [isNew] is `true` only when this call created the doc.
  Future<RepositoryResult<({Participant participant, bool isNew})>>
      createParticipantIfAbsent({
    required String roomId,
    required String deviceId,
    required String userId,
    required String userName,
    required String avatar,
  });
}

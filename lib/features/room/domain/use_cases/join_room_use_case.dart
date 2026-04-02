import 'package:room_chat/core/constants/app_strings.dart';
import 'package:room_chat/core/services/device_id_service.dart';
import 'package:room_chat/core/services/user_identity_service.dart';
import 'package:room_chat/core/services/visited_room_code_store.dart';
import 'package:room_chat/core/utils/repository_result.dart';
import 'package:room_chat/features/room/domain/entities/room_entity.dart';
import 'package:room_chat/features/room/domain/repositories/room_repository.dart';
import 'package:room_chat/features/room/domain/use_cases/join_room_result.dart';
import 'package:room_chat/features/room/domain/validators/join_room_code_validator.dart';

/// Join room: validate code → load room → identity → participant row.
final class JoinRoomUseCase {
  JoinRoomUseCase({
    required RoomRepository roomRepository,
    required UserIdentityService identityService,
    DeviceIdService? deviceIdService,
    VisitedRoomCodeStore? visitedRoomCodeStore,
  })  : _roomRepository = roomRepository,
        _identityService = identityService,
        _deviceIdService = deviceIdService ?? DeviceIdService.instance,
        _visitedRoomCodeStore =
            visitedRoomCodeStore ?? VisitedRoomCodeStore.instance;

  final RoomRepository _roomRepository;
  final UserIdentityService _identityService;
  final DeviceIdService _deviceIdService;
  final VisitedRoomCodeStore _visitedRoomCodeStore;

  Future<JoinRoomResult> execute(String rawCode) async {
    final normalized = JoinRoomCodeValidator.normalize(rawCode);
    if (!JoinRoomCodeValidator.isValid(normalized)) {
      return const JoinRoomFailureResult(AppStrings.joinRoomInvalidCode);
    }

    final roomLookup = await _resolveRoom(normalized);
    switch (roomLookup) {
      case RepositorySuccess(:final data):
        final room = data;
        if (room == null) {
          return const JoinRoomFailureResult(AppStrings.joinRoomNotFound);
        }
        return _joinWithRoom(roomId: room.id, roomCode: normalized);
      case RepositoryFailure():
        return const JoinRoomFailureResult(AppStrings.joinRoomGenericError);
    }
  }

  /// Prefer persisted id + [getRoomById] (works offline with doc cache) over query-by-code.
  Future<RepositoryResult<Room?>> _resolveRoom(String normalized) async {
    final cachedId = await _visitedRoomCodeStore.getRoomIdForCode(normalized);
    if (cachedId != null && cachedId.isNotEmpty) {
      final byId = await _roomRepository.getRoomById(cachedId);
      switch (byId) {
        case RepositorySuccess(:final data):
          final room = data;
          if (room != null &&
              JoinRoomCodeValidator.normalize(room.roomCode) == normalized) {
            return RepositorySuccess(room);
          }
          await _visitedRoomCodeStore.clearForCode(normalized);
          break;
        case RepositoryFailure():
          break;
      }
    }

    return _roomRepository.getRoomByCode(normalized);
  }

  Future<JoinRoomResult> _joinWithRoom({
    required String roomId,
    required String roomCode,
  }) async {
    final deviceId = _deviceIdService.deviceId;
    final existing = await _roomRepository.getParticipant(
      roomId: roomId,
      deviceId: deviceId,
    );
    switch (existing) {
      case RepositorySuccess(:final data):
        final p = data;
        if (p != null) {
          await _visitedRoomCodeStore.remember(roomCode, roomId);
          return JoinRoomSuccessResult(
            roomId: roomId,
            roomCode: roomCode,
            userId: p.userId,
            userName: p.userName,
            avatar: p.avatar,
            joinedAt: p.joinedAt,
          );
        }
        break;
      case RepositoryFailure():
        return const JoinRoomFailureResult(AppStrings.joinRoomGenericError);
    }

    final profile = await _identityService.createAnonymousProfileOrFallback();
    final joinedAt = DateTime.now();

    final add = await _roomRepository.addParticipant(
      roomId: roomId,
      deviceId: deviceId,
      userId: profile.userId,
      userName: profile.userName,
      avatar: profile.avatarUrl,
      useServerJoinedAt: false,
      joinedAt: joinedAt,
    );

    switch (add) {
      case RepositorySuccess():
        await _visitedRoomCodeStore.remember(roomCode, roomId);
        return JoinRoomSuccessResult(
          roomId: roomId,
          roomCode: roomCode,
          userId: profile.userId,
          userName: profile.userName,
          avatar: profile.avatarUrl,
          joinedAt: joinedAt,
        );
      case RepositoryFailure():
        return const JoinRoomFailureResult(AppStrings.joinRoomGenericError);
    }
  }
}

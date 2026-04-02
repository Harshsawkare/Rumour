import 'dart:math';

import 'package:room_chat/core/constants/app_strings.dart';
import 'package:room_chat/core/constants/room_code_constants.dart';
import 'package:room_chat/core/constants/room_name_constants.dart';
import 'package:room_chat/core/services/device_id_service.dart';
import 'package:room_chat/core/services/user_identity_service.dart';
import 'package:room_chat/core/services/visited_room_code_store.dart';
import 'package:room_chat/core/utils/repository_result.dart';
import 'package:room_chat/features/room/domain/repositories/room_repository.dart';
import 'package:room_chat/features/room/domain/use_cases/create_room_result.dart';

/// Creates a room with a client-generated code (collision retries) and adds the creator as participant.
final class CreateRoomUseCase {
  CreateRoomUseCase({
    required RoomRepository roomRepository,
    required UserIdentityService identityService,
    DeviceIdService? deviceIdService,
    Random? random,
    VisitedRoomCodeStore? visitedRoomCodeStore,
  })  : _roomRepository = roomRepository,
        _identityService = identityService,
        _deviceIdService = deviceIdService ?? DeviceIdService.instance,
        _random = random ?? Random.secure(),
        _visitedRoomCodeStore =
            visitedRoomCodeStore ?? VisitedRoomCodeStore.instance;

  final RoomRepository _roomRepository;
  final UserIdentityService _identityService;
  final DeviceIdService _deviceIdService;
  final Random _random;
  final VisitedRoomCodeStore _visitedRoomCodeStore;

  /// Picks a `Room #NNNN` label not yet used in Firestore (for the create-room preview).
  Future<RepositoryResult<String>> resolveUniqueRoomNameForPreview() async {
    for (var attempt = 0; attempt < RoomNameConstants.maxCollisionRetries; attempt++) {
      final candidate = generateRoomName();
      final taken = await _roomRepository.isRoomNameTaken(candidate);
      switch (taken) {
        case RepositorySuccess(:final data):
          if (!data) {
            return RepositorySuccess(candidate);
          }
          break;
        case RepositoryFailure(:final message, :final cause):
          return RepositoryFailure(message, cause);
      }
    }
    return const RepositoryFailure(AppStrings.createRoomUniqueNameFailed);
  }

  /// [roomName] must match the validated preview (re-checked here for races before write).
  Future<CreateRoomResult> execute({required String roomName}) async {
    final nameCheck = await _roomRepository.isRoomNameTaken(roomName);
    switch (nameCheck) {
      case RepositorySuccess(:final data):
        if (data) {
          return const CreateRoomFailureResult(AppStrings.createRoomUniqueNameFailed);
        }
        break;
      case RepositoryFailure():
        return const CreateRoomFailureResult(AppStrings.joinRoomGenericError);
    }

    String? code;
    for (var attempt = 0; attempt < RoomCodeConstants.maxCollisionRetries; attempt++) {
      final candidate = generateRoomCode();
      final lookup = await _roomRepository.getRoomByCode(candidate);
      switch (lookup) {
        case RepositorySuccess(:final data):
          if (data == null) {
            code = candidate;
          }
          break;
        case RepositoryFailure():
          return const CreateRoomFailureResult(AppStrings.joinRoomGenericError);
      }
      if (code != null) {
        break;
      }
    }
    if (code == null) {
      return const CreateRoomFailureResult(AppStrings.createRoomCollisionError);
    }

    final created = await _roomRepository.createRoomWithCode(
      roomCode: code,
      roomName: roomName,
    );

    switch (created) {
      case RepositorySuccess(:final data):
        final room = data;
        // GET randomuser.me/api/ right after the room doc exists; persist on participant.
        final profile = await _identityService.createAnonymousProfileOrFallback();
        final joinedAt = DateTime.now();

        final add = await _roomRepository.addParticipant(
          roomId: room.id,
          deviceId: _deviceIdService.deviceId,
          userId: profile.userId,
          userName: profile.userName,
          avatar: profile.avatarUrl,
          useServerJoinedAt: false,
          joinedAt: joinedAt,
        );

        switch (add) {
          case RepositorySuccess():
            await _visitedRoomCodeStore.remember(room.roomCode, room.id);
            return CreateRoomSuccessResult(
              roomId: room.id,
              roomCode: room.roomCode,
              roomName: room.roomName,
              userId: profile.userId,
              userName: profile.userName,
              avatar: profile.avatarUrl,
              joinedAt: joinedAt,
            );
          case RepositoryFailure():
            return const CreateRoomFailureResult(AppStrings.joinRoomGenericError);
        }
      case RepositoryFailure():
        return const CreateRoomFailureResult(AppStrings.joinRoomGenericError);
    }
  }

  /// Six uppercase alphanumeric characters (same charset as Firestore).
  String generateRoomCode() {
    final buf = StringBuffer();
    for (var i = 0; i < RoomCodeConstants.length; i++) {
      final idx = _random.nextInt(RoomCodeConstants.alphabet.length);
      buf.write(RoomCodeConstants.alphabet[idx]);
    }
    return buf.toString();
  }

  /// Display label e.g. `Room #4821`.
  String generateRoomName() {
    final n = _random.nextInt(10000);
    return 'Room #${n.toString().padLeft(4, '0')}';
  }
}

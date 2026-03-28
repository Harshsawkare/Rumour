import 'package:room_chat/core/constants/app_strings.dart';
import 'package:room_chat/core/services/device_id_service.dart';
import 'package:room_chat/core/services/user_identity_service.dart';
import 'package:room_chat/core/utils/repository_result.dart';
import 'package:room_chat/features/room/domain/repositories/room_repository.dart';
import 'package:room_chat/features/room/domain/use_cases/join_room_result.dart';
import 'package:room_chat/features/room/domain/validators/join_room_code_validator.dart';

/// Join room: validate code → load room → identity → participant row.
final class JoinRoomUseCase {
  JoinRoomUseCase({
    required RoomRepository roomRepository,
    required UserIdentityService identityService,
    DeviceIdService? deviceIdService,
  })  : _roomRepository = roomRepository,
        _identityService = identityService,
        _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  final RoomRepository _roomRepository;
  final UserIdentityService _identityService;
  final DeviceIdService _deviceIdService;

  Future<JoinRoomResult> execute(String rawCode) async {
    final normalized = JoinRoomCodeValidator.normalize(rawCode);
    if (!JoinRoomCodeValidator.isValid(normalized)) {
      return const JoinRoomFailureResult(AppStrings.joinRoomInvalidCode);
    }

    final roomLookup = await _roomRepository.getRoomByCode(normalized);
    switch (roomLookup) {
      case RepositorySuccess(:final data):
        final room = data;
        if (room == null) {
          return const JoinRoomFailureResult(AppStrings.joinRoomNotFound);
        }

        final deviceId = _deviceIdService.deviceId;
        final existing = await _roomRepository.getParticipant(
          roomId: room.id,
          deviceId: deviceId,
        );
        switch (existing) {
          case RepositorySuccess(:final data):
            final p = data;
            if (p != null) {
              return JoinRoomSuccessResult(
                roomId: room.id,
                roomCode: normalized,
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

        final profile = await _identityService
            .createAnonymousProfileOrFallback();
        final joinedAt = DateTime.now();

        final add = await _roomRepository.addParticipant(
          roomId: room.id,
          deviceId: deviceId,
          userId: profile.userId,
          userName: profile.userName,
          avatar: profile.avatarUrl,
          useServerJoinedAt: false,
          joinedAt: joinedAt,
        );

        switch (add) {
          case RepositorySuccess():
            return JoinRoomSuccessResult(
              roomId: room.id,
              roomCode: normalized,
              userId: profile.userId,
              userName: profile.userName,
              avatar: profile.avatarUrl,
              joinedAt: joinedAt,
            );
          case RepositoryFailure():
            return const JoinRoomFailureResult(AppStrings.joinRoomGenericError);
        }
      case RepositoryFailure():
        return const JoinRoomFailureResult(AppStrings.joinRoomGenericError);
    }
  }
}

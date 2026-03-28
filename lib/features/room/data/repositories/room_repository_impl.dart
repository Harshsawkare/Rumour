import 'package:room_chat/core/errors/data_layer_exception.dart';
import 'package:room_chat/core/services/firestore_service.dart';
import 'package:room_chat/core/utils/repository_result.dart';
import 'package:room_chat/features/room/data/mappers/participant_mappers.dart';
import 'package:room_chat/features/room/data/mappers/room_mappers.dart';
import 'package:room_chat/features/room/domain/entities/participant_entity.dart';
import 'package:room_chat/features/room/domain/entities/room_entity.dart';
import 'package:room_chat/features/room/domain/repositories/room_repository.dart';

final class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService.instance;

  final FirestoreService _firestore;

  @override
  Future<RepositoryResult<Room>> createRoom(String roomName) async {
    try {
      final model = await _firestore.createRoom(roomName: roomName.trim());
      return RepositorySuccess(model.toEntity());
    } on DataLayerException catch (e) {
      return RepositoryFailure(e.message, e.cause);
    } catch (e) {
      return RepositoryFailure('createRoom failed', e);
    }
  }

  @override
  Future<RepositoryResult<Room>> createRoomWithCode({
    required String roomCode,
    required String roomName,
  }) async {
    try {
      final model = await _firestore.createRoomWithRoomCode(
        roomCode: roomCode,
        roomName: roomName,
      );
      return RepositorySuccess(model.toEntity());
    } on DataLayerException catch (e) {
      return RepositoryFailure(e.message, e.cause);
    } catch (e) {
      return RepositoryFailure('createRoomWithCode failed', e);
    }
  }

  @override
  Future<RepositoryResult<Room?>> getRoomByCode(String roomCode) async {
    try {
      final found = await _firestore.getRoomByCode(roomCode);
      if (found == null) {
        return const RepositorySuccess(null);
      }
      return RepositorySuccess(found.model.toEntity());
    } on DataLayerException catch (e) {
      return RepositoryFailure(e.message, e.cause);
    } catch (e) {
      return RepositoryFailure('getRoomByCode failed', e);
    }
  }

  @override
  Future<RepositoryResult<Room?>> getRoomById(String roomId) async {
    try {
      final model = await _firestore.getRoomById(roomId);
      if (model == null) {
        return const RepositorySuccess(null);
      }
      return RepositorySuccess(model.toEntity());
    } on DataLayerException catch (e) {
      return RepositoryFailure(e.message, e.cause);
    } catch (e) {
      return RepositoryFailure('getRoomById failed', e);
    }
  }

  @override
  Stream<int> watchParticipantCount(String roomId) {
    return _firestore.watchParticipantCount(roomId);
  }

  @override
  Future<RepositoryResult<bool>> isRoomNameTaken(String roomName) async {
    try {
      final taken = await _firestore.isRoomNameTaken(roomName);
      return RepositorySuccess(taken);
    } on DataLayerException catch (e) {
      return RepositoryFailure(e.message, e.cause);
    } catch (e) {
      return RepositoryFailure('isRoomNameTaken failed', e);
    }
  }

  @override
  Future<RepositoryResult<void>> addParticipant({
    required String roomId,
    required String deviceId,
    required String userId,
    required String userName,
    required String avatar,
    required bool useServerJoinedAt,
    DateTime? joinedAt,
  }) async {
    try {
      await _firestore.addParticipant(
        roomId: roomId,
        deviceId: deviceId,
        userId: userId,
        userName: userName,
        avatar: avatar,
        useServerJoinedAt: useServerJoinedAt,
        joinedAt: joinedAt,
      );
      return const RepositorySuccess(null);
    } on DataLayerException catch (e) {
      return RepositoryFailure(e.message, e.cause);
    } catch (e) {
      return RepositoryFailure('addParticipant failed', e);
    }
  }

  @override
  Future<RepositoryResult<Participant?>> getParticipant({
    required String roomId,
    required String deviceId,
  }) async {
    try {
      final model = await _firestore.getParticipant(
        roomId: roomId,
        deviceId: deviceId,
      );
      return RepositorySuccess(model?.toEntity());
    } on DataLayerException catch (e) {
      return RepositoryFailure(e.message, e.cause);
    } catch (e) {
      return RepositoryFailure('getParticipant failed', e);
    }
  }

  @override
  Future<RepositoryResult<({Participant participant, bool isNew})>>
      createParticipantIfAbsent({
    required String roomId,
    required String deviceId,
    required String userId,
    required String userName,
    required String avatar,
  }) async {
    try {
      final r = await _firestore.ensureParticipantWithProfile(
        roomId: roomId,
        deviceId: deviceId,
        userId: userId,
        userName: userName,
        avatar: avatar,
      );
      if (!r.created) {
        return RepositorySuccess((participant: r.model.toEntity(), isNew: false));
      }
      final refreshed = await _firestore.getParticipant(
        roomId: roomId,
        deviceId: deviceId,
      );
      if (refreshed == null) {
        return const RepositoryFailure('Participant missing after create');
      }
      return RepositorySuccess((participant: refreshed.toEntity(), isNew: true));
    } on DataLayerException catch (e) {
      return RepositoryFailure(e.message, e.cause);
    } catch (e) {
      return RepositoryFailure('createParticipantIfAbsent failed', e);
    }
  }
}

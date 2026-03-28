import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:room_chat/core/constants/firestore_field_keys.dart';
import 'package:room_chat/core/constants/room_code_constants.dart';
import 'package:room_chat/core/errors/data_layer_exception.dart';
import 'package:room_chat/features/chat/data/models/message_model.dart';
import 'package:room_chat/features/room/data/models/participant_model.dart';
import 'package:room_chat/features/room/data/models/room_model.dart';

/// Low-level Firestore access: queries, writes, and streams.
/// No business logic; service methods use [try/catch] and throw [DataLayerException].
///
/// **Messages:** list queries order by `createdAt` descending (full room history).
final class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  static const int _maxUniqueCodeAttempts = 40;

  /// Throws if Firebase failed to start — data layer should surface as failure.
  FirebaseFirestore get db {
    if (Firebase.apps.isEmpty) {
      throw StateError(
        'Firebase is not initialized. Configure Firebase before using FirestoreService.db.',
      );
    }
    return FirebaseFirestore.instance;
  }

  /// Enables client persistence and an unlimited cache (mobile + desktop SDKs).
  void applyOfflinePersistenceSettings() {
    if (Firebase.apps.isEmpty) {
      return;
    }

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  CollectionReference<Map<String, dynamic>> _roomsCol() {
    return db.collection(FirestoreCollectionNames.rooms);
  }

  CollectionReference<Map<String, dynamic>> _participantsCol(String roomId) {
    return _roomsCol()
        .doc(roomId)
        .collection(FirestoreCollectionNames.participants);
  }

  CollectionReference<Map<String, dynamic>> _messagesCol(String roomId) {
    return _roomsCol()
        .doc(roomId)
        .collection(FirestoreCollectionNames.messages);
  }

  /// Creates a room with a unique [FirestoreFieldKeys.roomCode] and returns the stored model.
  Future<RoomModel> createRoom({required String roomName}) async {
    try {
      final roomRef = _roomsCol().doc();
      final roomCode = await _allocateUniqueRoomCode();
      return _writeRoomDoc(
        roomRef: roomRef,
        roomCode: roomCode,
        roomName: roomName,
      );
    } catch (e, st) {
      if (e is DataLayerException) rethrow;
      throw DataLayerException('createRoom failed', e, st);
    }
  }

  /// Creates a room with a caller-chosen [roomCode] (caller must ensure uniqueness).
  Future<RoomModel> createRoomWithRoomCode({
    required String roomCode,
    required String roomName,
  }) async {
    try {
      final roomRef = _roomsCol().doc();
      return _writeRoomDoc(
        roomRef: roomRef,
        roomCode: roomCode.trim().toUpperCase(),
        roomName: roomName.trim(),
      );
    } catch (e, st) {
      if (e is DataLayerException) rethrow;
      throw DataLayerException('createRoomWithRoomCode failed', e, st);
    }
  }

  Future<RoomModel> _writeRoomDoc({
    required DocumentReference<Map<String, dynamic>> roomRef,
    required String roomCode,
    required String roomName,
  }) async {
    await roomRef.set(<String, dynamic>{
      FirestoreFieldKeys.roomCode: roomCode,
      FirestoreFieldKeys.roomName: roomName,
      FirestoreFieldKeys.createdAt: FieldValue.serverTimestamp(),
    });
    final snap = await roomRef.get();
    final data = snap.data();
    if (data == null) {
      throw DataLayerException('createRoom: empty snapshot after write');
    }
    return RoomModel.fromMap(roomRef.id, data);
  }

  /// Returns the room id and model, or `null` if no room matches [roomCode].
  Future<({String id, RoomModel model})?> getRoomByCode(String roomCode) async {
    try {
      final trimmed = roomCode.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      final snap = await _roomsCol()
          .where(FirestoreFieldKeys.roomCode, isEqualTo: trimmed)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        return null;
      }
      final doc = snap.docs.first;
      return (id: doc.id, model: RoomModel.fromMap(doc.id, doc.data()));
    } catch (e, st) {
      throw DataLayerException('getRoomByCode failed', e, st);
    }
  }

  /// Returns `null` if `rooms/{roomId}` does not exist.
  Future<RoomModel?> getRoomById(String roomId) async {
    try {
      final trimmed = roomId.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      final snap = await _roomsCol().doc(trimmed).get();
      if (!snap.exists || snap.data() == null) {
        return null;
      }
      return RoomModel.fromMap(snap.id, snap.data()!);
    } catch (e, st) {
      throw DataLayerException('getRoomById failed', e, st);
    }
  }

  /// Live count of documents in `rooms/{roomId}/participants`.
  Stream<int> watchParticipantCount(String roomId) {
    return _participantsCol(roomId).snapshots().map((s) => s.docs.length);
  }

  /// `true` if any `rooms` document has [FirestoreFieldKeys.roomName] == [roomName] (trimmed).
  Future<bool> isRoomNameTaken(String roomName) async {
    try {
      final trimmed = roomName.trim();
      if (trimmed.isEmpty) {
        return false;
      }
      final snap = await _roomsCol()
          .where(FirestoreFieldKeys.roomName, isEqualTo: trimmed)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e, st) {
      throw DataLayerException('isRoomNameTaken failed', e, st);
    }
  }

  /// Participant doc id is [deviceId]. [useServerJoinedAt] writes [FieldValue.serverTimestamp] for `joinedAt`.
  Future<void> addParticipant({
    required String roomId,
    required String deviceId,
    required String userId,
    required String userName,
    required String avatar,
    required bool useServerJoinedAt,
    DateTime? joinedAt,
  }) async {
    try {
      if (!useServerJoinedAt && joinedAt == null) {
        throw DataLayerException('addParticipant: joinedAt required when not server timestamp');
      }
      final model = ParticipantModel(
        deviceId: deviceId,
        userId: userId,
        joinedAt: joinedAt ?? DateTime.now(),
        userName: userName,
        avatar: avatar,
      );
      await _participantsCol(roomId).doc(deviceId).set(
            model.toMap(joinedAtServerTimestamp: useServerJoinedAt),
          );
    } catch (e, st) {
      if (e is DataLayerException) rethrow;
      throw DataLayerException('addParticipant failed', e, st);
    }
  }

  /// Returns `null` if the participant doc does not exist.
  Future<ParticipantModel?> getParticipant({
    required String roomId,
    required String deviceId,
  }) async {
    try {
      final snap = await _participantsCol(roomId).doc(deviceId).get();
      if (!snap.exists || snap.data() == null) {
        return null;
      }
      return ParticipantModel.fromMap(deviceId, snap.data()!);
    } catch (e, st) {
      throw DataLayerException('getParticipant failed', e, st);
    }
  }

  /// Atomically reads `participants/{deviceId}` and creates it only if absent (prevents duplicate / race overwrites).
  ///
  /// When [created] is `true`, caller should re-fetch with [getParticipant] so [joinedAt] reflects the server timestamp.
  Future<({bool created, ParticipantModel model})> ensureParticipantWithProfile({
    required String roomId,
    required String deviceId,
    required String userId,
    required String userName,
    required String avatar,
  }) async {
    try {
      return await db.runTransaction<({bool created, ParticipantModel model})>(
        (transaction) async {
          final ref = _participantsCol(roomId).doc(deviceId);
          final snap = await transaction.get(ref);
          if (snap.exists && snap.data() != null) {
            return (
              created: false,
              model: ParticipantModel.fromMap(deviceId, snap.data()!),
            );
          }
          final model = ParticipantModel(
            deviceId: deviceId,
            userId: userId,
            joinedAt: DateTime.now(),
            userName: userName,
            avatar: avatar,
          );
          transaction.set(
            ref,
            model.toMap(joinedAtServerTimestamp: true),
          );
          return (
            created: true,
            model: model,
          );
        },
      );
    } catch (e, st) {
      throw DataLayerException('ensureParticipantWithProfile failed', e, st);
    }
  }

  /// Raw query snapshots for the newest [limit] messages (full history; pagination loads older).
  /// Repositories use [QuerySnapshot.docs.last] as `startAfter` for older pages.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessageQuerySnapshots({
    required String roomId,
    int limit = 50,
  }) {
    return _messagesCol(roomId)
        .orderBy(FirestoreFieldKeys.createdAt, descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Maps [watchMessageQuerySnapshots] to models (Bloc consumes via repository only).
  Stream<List<MessageModel>> listenToMessages({
    required String roomId,
    int limit = 50,
  }) {
    return watchMessageQuerySnapshots(
      roomId: roomId,
      limit: limit,
    ).map(
      (snapshot) => snapshot.docs
          .map((d) => MessageModel.fromMap(d.id, d.data()))
          .toList(growable: false),
    );
  }

  /// Older messages: pass [startAfter] = oldest doc from the realtime batch or previous page.
  Future<
    ({
      List<MessageModel> messages,
      QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc,
    })
  >
  fetchMoreMessages({
    required String roomId,
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _messagesCol(roomId)
          .orderBy(FirestoreFieldKeys.createdAt, descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      final snap = await query.get();
      final docs = snap.docs;
      final messages = docs
          .map((d) => MessageModel.fromMap(d.id, d.data()))
          .toList(growable: false);
      final lastDoc = docs.isEmpty ? null : docs.last;
      return (messages: messages, lastDoc: lastDoc);
    } catch (e, st) {
      throw DataLayerException('fetchMoreMessages failed', e, st);
    }
  }

  Future<void> sendMessage({
    required String roomId,
    required String text,
    required String userId,
    required String userName,
    required String avatar,
  }) async {
    try {
      await _messagesCol(roomId).add(<String, dynamic>{
        FirestoreFieldKeys.text: text,
        FirestoreFieldKeys.userId: userId,
        FirestoreFieldKeys.userName: userName,
        FirestoreFieldKeys.avatar: avatar,
        FirestoreFieldKeys.createdAt: FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      throw DataLayerException('sendMessage failed', e, st);
    }
  }

  Future<String> _allocateUniqueRoomCode() async {
    final random = Random.secure();
    for (var attempt = 0; attempt < _maxUniqueCodeAttempts; attempt++) {
      final code = _randomRoomCode(random);
      final existing = await getRoomByCode(code);
      if (existing == null) {
        return code;
      }
    }
    throw DataLayerException(
      'Could not allocate a unique room code after $_maxUniqueCodeAttempts tries',
    );
  }

  String _randomRoomCode(Random random) {
    final buf = StringBuffer();
    for (var i = 0; i < RoomCodeConstants.length; i++) {
      buf.write(
        RoomCodeConstants.alphabet[random.nextInt(
          RoomCodeConstants.alphabet.length,
        )],
      );
    }
    return buf.toString();
  }
}

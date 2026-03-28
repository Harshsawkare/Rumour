import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:room_chat/core/errors/data_layer_exception.dart';
import 'package:room_chat/core/services/firestore_service.dart';
import 'package:room_chat/core/utils/repository_result.dart';
import 'package:room_chat/features/chat/data/mappers/message_mappers.dart';
import 'package:room_chat/features/chat/data/models/message_model.dart';
import 'package:room_chat/features/chat/domain/entities/room_message_entity.dart';
import 'package:room_chat/features/chat/domain/entities/room_message_page.dart';
import 'package:room_chat/features/chat/domain/repositories/chat_repository.dart';

/// Maps Firestore streams to [RoomMessage] and keeps pagination cursors internal.
final class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService.instance;

  final FirestoreService _firestore;

  /// Oldest document in the current realtime snapshot (desc order) — `startAfter` anchor for older pages.
  QueryDocumentSnapshot<Map<String, dynamic>>? _realtimeOldestDoc;

  /// Last doc from the most recent [fetchMoreMessages] call (chain older pages).
  QueryDocumentSnapshot<Map<String, dynamic>>? _olderPageCursor;

  @override
  void resetPaginationState() {
    _realtimeOldestDoc = null;
    _olderPageCursor = null;
  }

  @override
  Stream<List<RoomMessage>> watchMessages({
    required String roomId,
    int limit = 50,
  }) {
    resetPaginationState();
    return _firestore
        .watchMessageQuerySnapshots(
          roomId: roomId,
          limit: limit,
        )
        .map((snapshot) {
          final docs = snapshot.docs;
          _realtimeOldestDoc = docs.isEmpty ? null : docs.last;
          return docs
              .map((d) => MessageModel.fromMap(d.id, d.data()).toEntity())
              .toList(growable: false);
        });
  }

  @override
  Future<RepositoryResult<RoomMessagePage>> fetchMoreMessages({
    required String roomId,
    int limit = 20,
  }) async {
    try {
      final startAfter = _olderPageCursor ?? _realtimeOldestDoc;
      if (startAfter == null) {
        return const RepositorySuccess(
          RoomMessagePage(messages: [], hasMore: false),
        );
      }
      final page = await _firestore.fetchMoreMessages(
        roomId: roomId,
        limit: limit,
        startAfter: startAfter,
      );
      _olderPageCursor = page.lastDoc;
      final entities = page.messages
          .map((m) => m.toEntity())
          .toList(growable: false);
      final hasMore = entities.length >= limit;
      return RepositorySuccess(
        RoomMessagePage(messages: entities, hasMore: hasMore),
      );
    } on DataLayerException catch (e) {
      return RepositoryFailure(e.message, e.cause);
    } catch (e) {
      return RepositoryFailure('fetchMoreMessages failed', e);
    }
  }

  @override
  Future<RepositoryResult<void>> sendMessage({
    required String roomId,
    required String text,
    required String userId,
    required String userName,
    required String avatar,
  }) async {
    try {
      await _firestore.sendMessage(
        roomId: roomId,
        text: text.trim(),
        userId: userId,
        userName: userName,
        avatar: avatar,
      );
      return const RepositorySuccess(null);
    } on DataLayerException catch (e) {
      return RepositoryFailure(e.message, e.cause);
    } catch (e) {
      return RepositoryFailure('sendMessage failed', e);
    }
  }
}

import 'package:room_chat/core/utils/repository_result.dart';
import 'package:room_chat/features/chat/domain/entities/room_message_entity.dart';
import 'package:room_chat/features/chat/domain/entities/room_message_page.dart';

/// Chat messages — streams are consumed only by Bloc (subscribe / cancel there).
abstract class ChatRepository {
  /// Newest [limit] messages in the room (full history window; older pages via [fetchMoreMessages]).
  ///
  /// **Bloc:** subscribe with [StreamSubscription], cancel on `close` / room change.
  Stream<List<RoomMessage>> watchMessages({
    required String roomId,
    int limit = 50,
  });

  /// Loads the next **older** page. Internally uses Firestore cursors; Bloc never sees [DocumentSnapshot].
  ///
  /// **Bloc:** call when the user scrolls up; merge into state (prepend by time).
  Future<RepositoryResult<RoomMessagePage>> fetchMoreMessages({
    required String roomId,
    int limit = 20,
  });

  Future<RepositoryResult<void>> sendMessage({
    required String roomId,
    required String text,
    required String userId,
    required String userName,
    required String avatar,
  });

  /// Clears pagination cursors when switching rooms or resubscribing.
  void resetPaginationState();
}

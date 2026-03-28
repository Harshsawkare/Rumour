/// Firestore collection segment names (paths: `rooms/{id}/...`).
abstract final class FirestoreCollectionNames {
  static const String rooms = 'rooms';
  static const String participants = 'participants';
  static const String messages = 'messages';
}

/// Firestore field names for `rooms`, `participants`, and `messages` documents.
///
/// Use these constants everywhere maps are built or parsed — no string literals.
abstract final class FirestoreFieldKeys {
  // --- rooms/{roomId} ---
  static const String roomCode = 'roomCode';
  static const String roomName = 'roomName';
  static const String createdAt = 'createdAt';

  // --- rooms/{roomId}/participants/{userId} ---
  static const String joinedAt = 'joinedAt';
  /// RandomUser `login.username` (handler key `login.username`).
  static const String username = 'username';

  // --- rooms/{roomId}/messages/{messageId} ---
  static const String text = 'text';
  static const String userId = 'userId';
  /// Also used on participant docs: `name.first` + `name.last` from RandomUser.
  static const String userName = 'userName';
  static const String avatar = 'avatar';
}

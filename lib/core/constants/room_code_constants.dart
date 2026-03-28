/// Shared with [FirestoreService] allocation and client-side code generation.
abstract final class RoomCodeConstants {
  /// Same charset as Firestore internal room codes (ambiguous chars omitted).
  static const String alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static const int length = 6;

  /// Retries when [getRoomByCode] finds an existing document for a candidate code.
  static const int maxCollisionRetries = 5;
}

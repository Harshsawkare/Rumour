/// Client-side retries when generating a unique `roomName` for the create preview.
abstract final class RoomNameConstants {
  static const int maxCollisionRetries = 32;
}

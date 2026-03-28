/// User-visible copy. Avoid magic strings in widgets.
abstract final class AppStrings {
  static const String appName = 'Rumour';

  static const String splashHeadline = 'Room Chat';
  static const String splashSubtitle =
      'Join or create a room with a code. Foundation screens only.';

  static const String navToJoinRoom = 'Join a room';
  static const String navToCreateRoom = 'Create a room';
  static const String navToChat = 'Open chat (preview)';

  static const String joinRoomTitle = 'Join A Room';
  static const String joinRoomBody =
      'Enter the code to join the anon chat room';
  static const String joinRoomCta = 'Join room';
  static const String joinRoomInvalidCode = 'Enter a valid 6-character code';
  static const String joinRoomNotFound = 'Room not found';
  static const String joinRoomGenericError = 'Something went wrong';

  static const String createRoomTitle = 'Create Room';
  static const String createRoomSubtitle = 'Start a new anonymous conversation';
  static const String createRoomPreviewMock = 'Room #1234';
  static const String createRoomPrimaryCta = 'Create Room';
  static const String createRoomCollisionError =
      'Unable to create room. Try again.';
  static const String createRoomUniqueNameFailed =
      'Could not find an available room name. Try again.';
  static const String createRoomPreviewRetry = 'Try again';

  static const String chatTitle = 'Room';
  static const String chatBody = 'Messages will appear here.';
}

import 'package:flutter/material.dart';

/// [Key] constants for tests and semantics — no inline [Key] literals in features.
abstract final class SplashKeys {
  static const Key joinButton = Key('splash_join_room');
  static const Key createButton = Key('splash_create_room');
  static const Key chatButton = Key('splash_chat_preview');
}

abstract final class JoinRoomKeys {
  static const Key screen = Key('join_room_screen');
  static const Key navToCreateRoom = Key('join_room_nav_create_room');
  static const Key joinCta = Key('join_room_join_cta');
}

abstract final class CreateRoomKeys {
  static const Key screen = Key('create_room_screen');
  static const Key primaryCta = Key('create_room_primary_cta');
}

abstract final class ChatKeys {
  static const Key screen = Key('chat_screen');
}

abstract final class ThemeModeKeys {
  static const Key menuButton = Key('theme_mode_menu');
}

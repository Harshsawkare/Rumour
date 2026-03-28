import 'package:flutter/material.dart';

import 'package:room_chat/core/constants/app_route_paths.dart';
import 'package:room_chat/core/constants/widget_keys.dart';
import 'package:room_chat/features/chat/presentation/screens/chat_screen.dart';
import 'package:room_chat/features/room/presentation/screens/create_room_screen.dart';
import 'package:room_chat/features/room/presentation/screens/join_room_screen.dart';
import 'package:room_chat/features/splash/presentation/screens/splash_screen.dart';

/// Central place for named routes and generation logic.
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutePaths.splash:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case AppRoutePaths.joinRoom:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => JoinRoomScreen(key: JoinRoomKeys.screen),
        );
      case AppRoutePaths.createRoom:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => CreateRoomScreen(key: CreateRoomKeys.screen),
        );
      case AppRoutePaths.chat:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ChatScreen(
            key: ChatKeys.screen,
            roomCode:
                settings.arguments is String ? settings.arguments as String : null,
          ),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
    }
  }
}

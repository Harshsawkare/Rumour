import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:room_chat/core/constants/app_route_paths.dart';
import 'package:room_chat/core/routing/app_router.dart';
import 'package:room_chat/core/theme/app_spacing.dart';
import 'package:room_chat/core/theme/app_theme.dart';
import 'package:room_chat/core/theme/theme_mode_scope.dart';
import 'package:room_chat/core/utils/responsive_layout.dart';

class RoomChatApp extends StatefulWidget {
  const RoomChatApp({super.key});

  @override
  State<RoomChatApp> createState() => _RoomChatAppState();
}

class _RoomChatAppState extends State<RoomChatApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeModeScope(
      themeMode: _themeMode,
      setThemeMode: _setThemeMode,
      child: MaterialApp(
        title: AppTheme.title,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _themeMode,
        initialRoute: AppRoutePaths.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) {
          final scaled = MediaQuery.withClampedTextScaling(
            minScaleFactor: 1,
            maxScaleFactor: 1.3,
            child: child ?? const SizedBox.shrink(),
          );
          if (!kIsWeb) return scaled;
          return Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.webTopPadding),
              child: ResponsiveLayout.constrainedContent(
                context: context,
                child: scaled,
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:room_chat/core/constants/widget_keys.dart';
import 'package:room_chat/core/theme/theme_mode_scope.dart';
import 'package:room_chat/core/theme/theme_extensions.dart';

/// Toggles between light and dark theme on each tap.
class ThemeModeSwitcherButton extends StatelessWidget {
  const ThemeModeSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = ThemeModeScope.of(context);
    final isDark = scope.themeMode == ThemeMode.dark;
    final colors = context.appColors;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: colors.secondaryText2,
        shape: BoxShape.circle,
      ),
      child: GestureDetector(
        key: ThemeModeKeys.menuButton,
        onTap: () =>
            scope.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: colors.icon,
          size: 24,
        ),
      ),
    );
  }
}

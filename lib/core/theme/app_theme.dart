import 'package:flutter/material.dart';

import 'package:room_chat/core/constants/app_strings.dart';
import 'package:room_chat/core/theme/app_colors_extension.dart';

/// Light and dark [ThemeData] with [AppColors] registered as a [ThemeExtension].
abstract final class AppTheme {
  static ThemeData light() {
    final appColors = AppColors.light;
    final colorScheme = ColorScheme.light(
      surface: appColors.secondaryText2,
      onSurface: appColors.primaryHeading1,
      primary: appColors.primaryAccent,
      onPrimary: appColors.secondaryText1,
      secondary: appColors.secondaryText2,
      onSecondary: appColors.primaryHeading1,
      outline: appColors.hintText.withValues(alpha: 0.55),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: appColors.background,
      extensions: <ThemeExtension<dynamic>>[appColors],
      appBarTheme: AppBarTheme(
        backgroundColor: appColors.background,
        foregroundColor: appColors.primaryHeading1,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      dividerTheme: DividerThemeData(color: appColors.divider, thickness: 1),
      cardTheme: CardThemeData(
        color: appColors.secondaryText2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: appColors.divider.withValues(alpha: 0.6)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final appColors = AppColors.dark;
    final colorScheme = ColorScheme.dark(
      surface: appColors.secondaryText2,
      onSurface: appColors.primaryHeading1,
      primary: appColors.primaryAccent,
      onPrimary: appColors.secondaryText1,
      secondary: appColors.secondaryText2,
      onSecondary: appColors.primaryHeading1,
      outline: appColors.hintText.withValues(alpha: 0.55),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: appColors.background,
      extensions: <ThemeExtension<dynamic>>[appColors],
      appBarTheme: AppBarTheme(
        backgroundColor: appColors.background,
        foregroundColor: appColors.primaryHeading1,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      dividerTheme: DividerThemeData(color: appColors.divider, thickness: 1),
      cardTheme: CardThemeData(
        color: appColors.secondaryText2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: appColors.divider.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  static String get title => AppStrings.appName;
}

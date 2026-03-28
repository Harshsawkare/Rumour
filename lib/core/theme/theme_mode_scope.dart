import 'package:flutter/material.dart';

/// Provides [ThemeMode] and a setter for the app root; must wrap [MaterialApp].
class ThemeModeScope extends InheritedWidget {
  const ThemeModeScope({
    super.key,
    required this.themeMode,
    required this.setThemeMode,
    required super.child,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> setThemeMode;

  static ThemeModeScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeModeScope>();
    assert(scope != null, 'ThemeModeScope not found above context');
    return scope!;
  }

  @override
  bool updateShouldNotify(ThemeModeScope oldWidget) =>
      themeMode != oldWidget.themeMode;
}

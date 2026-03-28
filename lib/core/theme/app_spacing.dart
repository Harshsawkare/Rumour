import 'package:flutter/material.dart';

import 'package:room_chat/core/utils/responsive_layout.dart';

/// Layout spacing scale — use via [AppSpacing] methods in builds (no magic numbers).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 30;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 86;

  static const double contentMaxWidth = 600;

  /// Extra top inset for Flutter web (e.g. browser chrome / in-app webview).
  static const double webTopPadding = 20;

  /// Horizontal inset that scales slightly on wider viewports.
  static EdgeInsets pageHorizontal(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pad = ResponsiveLayout.isCompactWidth(width) ? md : lg;
    return EdgeInsets.symmetric(horizontal: pad);
  }

  static EdgeInsets pageVerticalCompact(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final base = ResponsiveLayout.isShortViewport(height) ? sm : md;
    return EdgeInsets.symmetric(vertical: base);
  }
}

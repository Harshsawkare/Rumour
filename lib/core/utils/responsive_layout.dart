import 'package:flutter/material.dart';

import 'package:room_chat/core/theme/app_spacing.dart';

/// Breakpoint helpers for adaptive layouts (no fixed pixel widths in widgets).
abstract final class ResponsiveLayout {
  static const double compactWidthUpperBound = 600;
  static const double mediumWidthUpperBound = 900;
  static const double shortViewportUpperBound = 480;

  static bool isCompactWidth(double width) => width < compactWidthUpperBound;

  static bool isMediumWidth(double width) =>
      width >= compactWidthUpperBound && width < mediumWidthUpperBound;

  static bool isShortViewport(double height) =>
      height < shortViewportUpperBound;

  /// Puts [child] in a centered column with max width for readability on large screens.
  static Widget constrainedContent({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveMax = maxWidth ?? AppSpacing.contentMaxWidth;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: effectiveMax,
              minWidth: 0,
              maxHeight: constraints.maxHeight,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

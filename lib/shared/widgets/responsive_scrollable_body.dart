import 'package:flutter/material.dart';

import 'package:room_chat/core/theme/app_spacing.dart';
import 'package:room_chat/core/utils/responsive_layout.dart';

/// Shared scrollable page body with horizontal padding and max content width.
class ResponsiveScrollableBody extends StatelessWidget {
  const ResponsiveScrollableBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.pageHorizontal(
          context,
        ).add(AppSpacing.pageVerticalCompact(context)),
        child: ResponsiveLayout.constrainedContent(
          context: context,
          child: child,
        ),
      ),
    );
  }
}

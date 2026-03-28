import 'package:flutter/material.dart';

import 'package:room_chat/core/theme/theme_extensions.dart';

/// Circular back control that pops the current route when possible.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key, this.onPressed});

  /// When null, calls [Navigator.maybePop]. Use a custom handler when the
  /// navigator stack may contain duplicate routes of the same name.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.secondaryText2,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.expand(),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: colors.icon,
          size: 24,
        ),
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

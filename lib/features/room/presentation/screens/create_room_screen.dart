import 'package:flutter/material.dart';

import 'package:room_chat/core/constants/app_strings.dart';
import 'package:room_chat/core/constants/widget_keys.dart';
import 'package:room_chat/core/theme/app_spacing.dart';
import 'package:room_chat/core/theme/theme_extensions.dart';
import 'package:room_chat/shared/widgets/responsive_scrollable_body.dart';
import 'package:room_chat/shared/widgets/theme_mode_switcher_button.dart';

/// Create-room flow — UI only; wire actions via [CreateRoomScreen.onCreatePressed]
/// when integrating BLoC.
class CreateRoomScreen extends StatelessWidget {
  const CreateRoomScreen({super.key, this.onCreatePressed});

  /// No-op until BLoC is connected; kept for a single integration point.
  final VoidCallback? onCreatePressed;

  static const double _roomCardRadius = 16;
  static const double _primaryButtonRadius = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: const BackButton(),
        actions: const [ThemeModeSwitcherButton()],
      ),
      body: ResponsiveScrollableBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeaderSection(),
            SizedBox(height: AppSpacing.xl),
            _RoomPreviewCard(
              previewLabel: AppStrings.createRoomPreviewMock,
              borderRadius: _roomCardRadius,
            ),
            SizedBox(height: AppSpacing.xl),
            _CreateButton(
              borderRadius: _primaryButtonRadius,
              onPressed: onCreatePressed ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.createRoomTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colors.primaryHeading1,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.createRoomSubtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.primarySubheading1,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _RoomPreviewCard extends StatelessWidget {
  const _RoomPreviewCard({
    required this.previewLabel,
    required this.borderRadius,
  });

  final String previewLabel;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondaryText2,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colors.divider.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: colors.primaryHeading1.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Icon(
              Icons.meeting_room_outlined,
              color: colors.primarySubheading1,
              size: 28,
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                previewLabel,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.primaryHeading1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.borderRadius, required this.onPressed});

  final double borderRadius;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: colors.secondaryText1,
      fontWeight: FontWeight.w600,
    );

    return FilledButton(
      key: CreateRoomKeys.primaryCta,
      onPressed: onPressed,
      style:
          FilledButton.styleFrom(
            backgroundColor: colors.secondaryAccent,
            foregroundColor: colors.secondaryText1,
            disabledBackgroundColor: colors.hintText.withValues(alpha: 0.45),
            disabledForegroundColor: colors.secondaryText1.withValues(
              alpha: 0.65,
            ),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return colors.secondaryText1.withValues(alpha: 0.12);
              }
              if (states.contains(WidgetState.hovered)) {
                return colors.secondaryText1.withValues(alpha: 0.08);
              }
              return null;
            }),
          ),
      child: Text(AppStrings.createRoomPrimaryCta, style: labelStyle),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:room_chat/core/constants/app_route_paths.dart';
import 'package:room_chat/core/constants/app_strings.dart';
import 'package:room_chat/core/constants/widget_keys.dart';
import 'package:room_chat/core/routing/chat_route_args.dart';
import 'package:room_chat/core/services/user_identity_service.dart';
import 'package:room_chat/core/theme/app_spacing.dart';
import 'package:room_chat/core/theme/theme_extensions.dart';
import 'package:room_chat/features/room/data/repositories/room_repository_impl.dart';
import 'package:room_chat/features/room/domain/use_cases/create_room_use_case.dart';
import 'package:room_chat/features/room/domain/use_cases/join_room_use_case.dart';
import 'package:room_chat/features/room/presentation/bloc/room_bloc.dart';
import 'package:room_chat/shared/widgets/responsive_scrollable_body.dart';
import 'package:room_chat/shared/widgets/theme_mode_switcher_button.dart';

class CreateRoomScreen extends StatelessWidget {
  const CreateRoomScreen({super.key});

  static const double _roomCardRadius = 16;
  static const double _primaryButtonRadius = 14;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repo = RoomRepositoryImpl();
        final bloc = RoomBloc(
          joinRoomUseCase: JoinRoomUseCase(
            roomRepository: repo,
            identityService: UserIdentityService.instance,
          ),
          createRoomUseCase: CreateRoomUseCase(
            roomRepository: repo,
            identityService: UserIdentityService.instance,
          ),
        );
        bloc.add(const CreateRoomPreviewRequested());
        return bloc;
      },
      child: const _CreateRoomView(
        roomCardRadius: _roomCardRadius,
        primaryButtonRadius: _primaryButtonRadius,
      ),
    );
  }
}

class _CreateRoomView extends StatelessWidget {
  const _CreateRoomView({
    required this.roomCardRadius,
    required this.primaryButtonRadius,
  });

  final double roomCardRadius;
  final double primaryButtonRadius;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomBloc, RoomState>(
      listenWhen: (previous, current) =>
          current is RoomCreateSuccess || current is RoomError,
      listener: (context, state) {
        if (state is RoomCreateSuccess) {
          final args = ChatRouteArgs(
            roomId: state.roomId,
            roomCode: state.roomCode,
            roomName: state.roomName,
          );
          Navigator.of(context)
              .pushNamed(AppRoutePaths.chat, arguments: args)
              .then((_) {
            if (context.mounted) {
              context.read<RoomBloc>()
                ..add(const RoomReset())
                ..add(const CreateRoomPreviewRequested());
            }
          });
        } else if (state is RoomError) {
          _showCreateRoomAlert(context, state.message);
        }
      },
      builder: (context, state) {
        final colors = context.appColors;

        final previewLoading = state is RoomCreatePreviewLoading;
        final previewError = state is RoomCreatePreviewLoadError;
        final previewErrorMessage =
            state is RoomCreatePreviewLoadError ? state.message : null;

        final loadingState = state is RoomLoading ? state : null;
        final submittingCreate =
            loadingState != null && loadingState.retainCreatePreviewName != null;

        String? previewLabel;
        if (state is RoomCreatePreviewReady) {
          previewLabel = state.previewRoomName;
        } else if (loadingState?.retainCreatePreviewName != null) {
          previewLabel = loadingState!.retainCreatePreviewName;
        }

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
                  previewLabel: previewLabel,
                  previewLoading: previewLoading,
                  previewError: previewError,
                  previewErrorMessage: previewErrorMessage,
                  borderRadius: roomCardRadius,
                  onRetryPreview: previewError
                      ? () => context
                          .read<RoomBloc>()
                          .add(const CreateRoomPreviewRequested())
                      : null,
                ),
                SizedBox(height: AppSpacing.xl),
                _CreateButton(
                  borderRadius: primaryButtonRadius,
                  loading: submittingCreate,
                  onPressed: submittingCreate
                      ? null
                      : _createRoomButtonAction(
                          context,
                          state,
                          previewLoading,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Primary CTA stays tappable when preview failed (e.g. offline): shows [AlertDialog] instead of a dead button.
  VoidCallback? _createRoomButtonAction(
    BuildContext context,
    RoomState state,
    bool previewLoading,
  ) {
    if (previewLoading) {
      return null;
    }
    if (state is RoomCreatePreviewLoadError) {
      return () => _showCreateRoomAlert(context, state.message);
    }
    if (state is RoomCreatePreviewReady) {
      final name = state.previewRoomName;
      return () =>
          context.read<RoomBloc>().add(CreateRoomRequested(name));
    }
    return null;
  }
}

void _showCreateRoomAlert(BuildContext context, String message) {
  final theme = Theme.of(context);
  final colors = context.appColors;
  final isNeedOnline = message == AppStrings.createRoomNeedOnline;
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        isNeedOnline
            ? AppStrings.createRoomNeedOnlineTitle
            : AppStrings.createRoomTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          color: colors.primaryHeading1,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        message,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colors.primarySubheading1,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(
            MaterialLocalizations.of(ctx).okButtonLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.primaryAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
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
    required this.previewLoading,
    required this.previewError,
    required this.previewErrorMessage,
    required this.borderRadius,
    required this.onRetryPreview,
  });

  final String? previewLabel;
  final bool previewLoading;
  final bool previewError;
  final String? previewErrorMessage;
  final double borderRadius;
  final VoidCallback? onRetryPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    Widget titleContent;
    if (previewLoading) {
      // [Expanded] in the parent [Row] passes a wide max width; without [Align] the
      // indicator stretches horizontally and draws as an oval.
      titleContent = Align(
        alignment: Alignment.centerLeft,
        child: SizedBox.square(
          dimension: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.primaryHeading1,
          ),
        ),
      );
    } else if (previewError) {
      titleContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            previewErrorMessage ?? AppStrings.joinRoomGenericError,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.primarySubheading1,
            ),
          ),
          if (onRetryPreview != null) ...[
            SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onRetryPreview,
              child: Text(
                AppStrings.createRoomPreviewRetry,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      );
    } else {
      titleContent = Text(
        previewLabel ?? '—',
        style: theme.textTheme.titleLarge?.copyWith(
          color: colors.primaryHeading1,
          fontWeight: FontWeight.w600,
        ),
      );
    }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.meeting_room_outlined,
              color: colors.primarySubheading1,
              size: 28,
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(child: titleContent),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({
    required this.borderRadius,
    required this.loading,
    required this.onPressed,
  });

  final double borderRadius;
  final bool loading;
  final VoidCallback? onPressed;

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
      child: loading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.secondaryText1,
              ),
            )
          : Text(AppStrings.createRoomPrimaryCta, style: labelStyle),
    );
  }
}

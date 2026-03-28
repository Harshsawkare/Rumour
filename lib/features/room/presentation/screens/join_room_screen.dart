import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:room_chat/features/room/domain/validators/join_room_code_validator.dart';
import 'package:room_chat/features/room/presentation/bloc/room_bloc.dart';
import 'package:room_chat/shared/widgets/theme_mode_switcher_button.dart';

class JoinRoomScreen extends StatelessWidget {
  const JoinRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repo = RoomRepositoryImpl();
        return RoomBloc(
          joinRoomUseCase: JoinRoomUseCase(
            roomRepository: repo,
            identityService: UserIdentityService.instance,
          ),
          createRoomUseCase: CreateRoomUseCase(
            roomRepository: repo,
            identityService: UserIdentityService.instance,
          ),
        );
      },
      child: const _JoinRoomView(),
    );
  }
}

/// Uppercase A–Z / 0–9 only, max [JoinRoomCodeValidator.requiredLength].
final class _RoomCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buf = StringBuffer();
    for (final c in newValue.text.toUpperCase().split('')) {
      if (RegExp('[A-Z0-9]').hasMatch(c)) {
        buf.write(c);
      }
    }
    var text = buf.toString();
    if (text.length > JoinRoomCodeValidator.requiredLength) {
      text = text.substring(0, JoinRoomCodeValidator.requiredLength);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _JoinRoomView extends StatefulWidget {
  const _JoinRoomView();

  @override
  State<_JoinRoomView> createState() => _JoinRoomViewState();
}

class _JoinRoomViewState extends State<_JoinRoomView> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool get _canSubmit {
    final normalized = JoinRoomCodeValidator.normalize(_codeController.text);
    return JoinRoomCodeValidator.isValid(normalized);
  }

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() => setState(() {}));
  }

  void _onJoinPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<RoomBloc>().add(JoinRoomRequested(_codeController.text));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    final inputFillColor = colors.iconBg;
    final dashColor = colors.hintText;
    final digitColor = colors.primaryHeading1;

    return BlocConsumer<RoomBloc, RoomState>(
      listenWhen: (previous, current) =>
          current is RoomJoinSuccess || current is RoomError,
      listener: (context, state) {
        if (state is RoomJoinSuccess) {
          final args = ChatRouteArgs(
            roomId: state.roomId,
            roomCode: state.roomCode,
          );
          Navigator.of(
            context,
          ).pushNamed(AppRoutePaths.chat, arguments: args).then((_) {
            if (context.mounted) {
              context.read<RoomBloc>().add(const RoomReset());
            }
          });
        } else if (state is RoomError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final loading = state is RoomLoading;

        return Scaffold(
          backgroundColor: colors.background,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: AppSpacing.pageHorizontal(context),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.joinRoomTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                color: colors.primaryHeading2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              AppStrings.joinRoomBody,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: colors.primarySubheading1,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xl),
                            Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 64,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.lg,
                                  ),
                                  decoration: BoxDecoration(
                                    color: inputFillColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List<Widget>.generate(6, (index) {
                                      final code = _codeController.text;
                                      final char = index < code.length
                                          ? code[index]
                                          : null;
                                      return Expanded(
                                        child: Center(
                                          child: Text(
                                            char ?? '—',
                                            style: theme.textTheme.headlineSmall
                                                ?.copyWith(
                                                  color: char != null
                                                      ? digitColor
                                                      : dashColor,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1,
                                                  fontSize: 16,
                                                ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0,
                                    child: TextField(
                                      controller: _codeController,
                                      focusNode: _focusNode,
                                      keyboardType: TextInputType.text,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      textInputAction: TextInputAction.done,
                                      maxLength:
                                          JoinRoomCodeValidator.requiredLength,
                                      showCursor: false,
                                      enableSuggestions: false,
                                      autocorrect: false,
                                      inputFormatters: [_RoomCodeFormatter()],
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.lg),
                            FilledButton(
                              key: JoinRoomKeys.joinCta,
                              onPressed: loading || !_canSubmit
                                  ? null
                                  : () => _onJoinPressed(context),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: colors.secondaryAccent,
                              ),
                              child: loading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    )
                                  : Text(
                                      AppStrings.joinRoomCta,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color:
                                                _codeController.text.length ==
                                                    JoinRoomCodeValidator
                                                        .requiredLength
                                                ? colors.secondaryText1
                                                : colors.primaryHeading1,
                                          ),
                                    ),
                            ),
                            SizedBox(height: AppSpacing.md),
                            TextButton(
                              key: JoinRoomKeys.navToCreateRoom,
                              onPressed: loading
                                  ? null
                                  : () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed(AppRoutePaths.createRoom);
                                    },
                              style: TextButton.styleFrom(
                                foregroundColor: colors.primaryAccent,
                              ),
                              child: Text(
                                AppStrings.navToCreateRoom,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxxl),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/app-logo.png',
                        width: 88,
                        height: 88,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 0,
                  right: 30,
                  child: ThemeModeSwitcherButton(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:room_chat/core/constants/app_route_paths.dart';
import 'package:room_chat/core/constants/app_strings.dart';
import 'package:room_chat/core/constants/widget_keys.dart';
import 'package:room_chat/core/theme/app_spacing.dart';
import 'package:room_chat/core/theme/theme_extensions.dart';
import 'package:room_chat/features/room/presentation/bloc/join_room/join_room_bloc.dart';
import 'package:room_chat/shared/widgets/theme_mode_switcher_button.dart';

class JoinRoomScreen extends StatelessWidget {
  const JoinRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JoinRoomBloc()..add(const JoinRoomStarted()),
      child: const _JoinRoomView(),
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

  /// Avoids stacking duplicate `/chat` routes when the code field notifies twice (e.g. web paste).
  bool _hasPushedChat = false;

  bool get _isValid => _codeController.text.trim().length == 6;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
  }

  void _onCodeChanged() {
    setState(() {});
    if (_isValid) {
      _submitIfValid();
    }
  }

  void _submitIfValid() {
    final code = _codeController.text.trim();
    if (code.length != 6) return;
    if (!mounted || _hasPushedChat) return;
    _hasPushedChat = true;
    Navigator.of(context)
        .pushNamed(AppRoutePaths.chat, arguments: code)
        .whenComplete(() {
      if (mounted) _hasPushedChat = false;
    });
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
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
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  maxLength: 6,
                                  showCursor: false,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
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
                        TextButton(
                          key: JoinRoomKeys.navToCreateRoom,
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AppRoutePaths.createRoom);
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
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:room_chat/core/constants/app_route_paths.dart';
import 'package:room_chat/core/theme/app_spacing.dart';
import 'package:room_chat/core/theme/theme_extensions.dart';
import 'package:room_chat/features/chat/domain/entities/chat_message.dart';
import 'package:room_chat/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:room_chat/shared/widgets/circle_back_button.dart';
import 'package:room_chat/shared/widgets/theme_mode_switcher_button.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, this.roomCode});

  final String? roomCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc()..add(const ChatStarted()),
      child: _ChatView(roomCode: roomCode),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({required this.roomCode});

  final String? roomCode;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _hasAcknowledged = false;

  final List<ChatMessage> _messages = <ChatMessage>[
    ChatMessage(
      text: 'Hey! Room is live.',
      isMe: false,
      sentAt: DateTime(2026, 3, 23, 10, 30),
    ),
    ChatMessage(
      text: 'Nice. Send a message 👇',
      isMe: false,
      sentAt: DateTime(2026, 3, 27, 10, 31),
    ),
    ChatMessage(
      text: 'Hello!',
      isMe: true,
      sentAt: DateTime(2026, 3, 28, 9, 0),
    ),
  ];

  bool get _canSend => _messageController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _send() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isMe: true, sentAt: DateTime.now()),
      );
    });
    _messageController.clear();
    _scrollToBottom();
  }

  void _acknowledgeAndContinue() {
    setState(() {
      _hasAcknowledged = true;
    });
    _scrollToBottom();
  }

  /// Pops every stacked `/chat` route (e.g. duplicate pushes from web) so back returns to join/create.
  void _exitChat(BuildContext context) {
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name != AppRoutePaths.chat);
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    final isMe = message.isMe;
    final bubbleColor = isMe ? colors.secondaryAccent : colors.textBg;
    final textColor = isMe ? colors.secondaryText1 : colors.primaryHeading2;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 8),
              bottomRight: Radius.circular(isMe ? 8 : 16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static DateTime _calendarDay(DateTime sentAt) =>
      DateTime(sentAt.year, sentAt.month, sentAt.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      _calendarDay(a) == _calendarDay(b);

  String _formatDateSeparatorLabel(DateTime day, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(day.year, day.month, day.day);
    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[day.month - 1]} ${day.day}, ${day.year}';
  }

  Widget _buildDateSeparator(BuildContext context, DateTime day) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final label = _formatDateSeparatorLabel(day, DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.secondaryText2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.primarySubheading2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Chronological order: index 0 = oldest, [length - 1] = newest (also at the bottom of the screen).
  /// A date separator is shown for each message that starts a new calendar day, using that message's [ChatMessage.sentAt].
  List<Widget> _buildChatListChildren(BuildContext context) {
    final n = _messages.length;
    if (n == 0) return const [];

    final children = <Widget>[];
    for (var i = 0; i < n; i++) {
      final startsNewDay =
          i == 0 || !_isSameDay(_messages[i - 1].sentAt, _messages[i].sentAt);

      if (i > 0 && !startsNewDay) {
        children.add(SizedBox(height: AppSpacing.sm));
      }
      if (startsNewDay) {
        children.add(
          _buildDateSeparator(context, _calendarDay(_messages[i].sentAt)),
        );
      }
      children.add(_buildMessageBubble(context, _messages[i]));
    }
    return children;
  }

  /// Ascending message order with content aligned to the bottom when the thread is short.
  Widget _buildChatMessageScrollArea(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildChatListChildren(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComposer(BuildContext context) {
    final colors = context.appColors;
    final canSend = _canSend;

    return SizedBox(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.textBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (canSend) _send();
                },
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Write a message...',
                  hintStyle: TextStyle(color: colors.hintText),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colors.primaryHeading1),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.secondaryAccent,
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment(0.2, -0.2),
                  child: Transform.rotate(
                    angle: pi / -4,
                    child: Icon(
                      Icons.send_outlined,
                      size: 22,
                      color: colors.secondaryText2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcknowledgementView(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _exitChat(context);
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.pageHorizontal(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleBackButton(onPressed: () => _exitChat(context)),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Room #8656',
                            style: TextStyle(
                              fontSize: 20,
                              color: colors.primaryHeading2,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            '4 members',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.primarySubheading2,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    ThemeModeSwitcherButton(),
                  ],
                ),

                if (!_hasAcknowledged) ...[
                  const Spacer(),

                  // Badge card
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.textBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'For this room, you are',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.primarySubheading2,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppSpacing.sm),
                              ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                    colors: [
                                      colors.primaryAccent,
                                      colors.secondaryAccent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.srcIn,
                                child: Text(
                                  'Brave\nBadger',
                                  style: TextStyle(
                                    fontSize: 60,
                                    color: colors.primaryHeading2,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                'This is your anonymous identifier, visible only to others in this room.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.primarySubheading3,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.md),

                  // CTA button
                  FilledButton(
                    onPressed: _acknowledgeAndContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.secondaryAccent,
                      foregroundColor: colors.background,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Acknowledge and continue',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.background,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.md),
                ],
                if (_hasAcknowledged) ...[
                  Expanded(child: _buildChatMessageScrollArea(context)),
                  const SizedBox(height: AppSpacing.sm),
                  _buildComposer(context),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildAcknowledgementView(context);
  }
}

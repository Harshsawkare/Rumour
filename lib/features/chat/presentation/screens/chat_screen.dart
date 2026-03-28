import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:room_chat/core/constants/app_route_paths.dart';
import 'package:room_chat/core/constants/app_strings.dart';
import 'package:room_chat/core/routing/chat_route_args.dart';
import 'package:room_chat/core/services/user_identity_service.dart';
import 'package:room_chat/core/theme/app_spacing.dart';
import 'package:room_chat/core/theme/theme_extensions.dart';
import 'package:room_chat/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:room_chat/features/chat/domain/entities/room_message_entity.dart';
import 'package:room_chat/features/chat/domain/use_cases/resolve_chat_session_use_case.dart';
import 'package:room_chat/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:room_chat/features/room/data/repositories/room_repository_impl.dart';
import 'package:room_chat/shared/widgets/circle_back_button.dart';
import 'package:room_chat/shared/widgets/theme_mode_switcher_button.dart';

String _memberCountLabel(int count) {
  if (count == 1) {
    return '1 member';
  }
  return '$count members';
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.chatArgs});

  final ChatRouteArgs chatArgs;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final roomRepository = RoomRepositoryImpl();
        return ChatBloc(
          resolveChatSessionUseCase: ResolveChatSessionUseCase(
            roomRepository: roomRepository,
            identityService: UserIdentityService.instance,
          ),
          chatRepository: ChatRepositoryImpl(),
          roomRepository: roomRepository,
        )..add(
            InitializeChat(
              roomId: chatArgs.roomId,
              roomCode: chatArgs.roomCode,
              roomTitle: chatArgs.roomName,
            ),
          );
      },
      child: _ChatView(chatArgs: chatArgs),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({required this.chatArgs});

  final ChatRouteArgs chatArgs;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _hasAcknowledged = false;
  String? _lastMessageIdWeScrolledTo;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final pos = _scrollController.position;
    // [ListView.reverse] == true: offset 0 is at the bottom (newest); maxScrollExtent is the top (older).
    if (pos.maxScrollExtent > 0 && pos.pixels >= pos.maxScrollExtent - 120) {
      context.read<ChatBloc>().add(const LoadMoreMessages());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  bool get _canSend => _messageController.text.trim().isNotEmpty;

  void _send() {
    final text = _messageController.text;
    if (text.trim().isEmpty) {
      return;
    }
    context.read<ChatBloc>().add(SendMessage(text));
    _messageController.clear();
  }

  void _acknowledgeAndContinue() {
    setState(() {
      _hasAcknowledged = true;
    });
    _scrollToBottom();
  }

  void _exitChat(BuildContext context) {
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name != AppRoutePaths.chat);
  }

  static DateTime _calendarDay(DateTime t) => DateTime(t.year, t.month, t.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      _calendarDay(a) == _calendarDay(b);

  String _formatDateSeparatorLabel(DateTime day, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(day.year, day.month, day.day);
    if (target == today) {
      return 'Today';
    }
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

  Widget _buildMessageRow(
    BuildContext context, {
    required RoomMessage message,
    required String currentUserId,
  }) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final isMe = message.userId == currentUserId;
    final bubbleColor = isMe ? colors.secondaryAccent : colors.textBg;
    final textColor = isMe ? colors.secondaryText1 : colors.primaryHeading2;

    final bubble = DecoratedBox(
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
        child: Text(
          message.text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );

    if (isMe) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: bubble,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: colors.textBg,
          backgroundImage: message.avatar.isNotEmpty
              ? NetworkImage(message.avatar)
              : null,
          child: message.avatar.isEmpty
              ? Icon(Icons.person, color: colors.primarySubheading1, size: 20)
              : null,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  message.userName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.primarySubheading2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              bubble,
            ],
          ),
        ),
      ],
    );
  }

  /// Newest messages first so with [ListView.reverse] they anchor at the bottom above the composer.
  List<Widget> _buildMessageList(
    BuildContext context,
    List<RoomMessage> messages,
    String currentUserId,
  ) {
    if (messages.isEmpty) {
      return const [];
    }
    final ordered = messages.reversed.toList();
    final children = <Widget>[];
    for (var i = 0; i < ordered.length; i++) {
      if (i > 0) {
        if (!_isSameDay(ordered[i - 1].createdAt, ordered[i].createdAt)) {
          children.add(
            _buildDateSeparator(context, _calendarDay(ordered[i].createdAt)),
          );
        } else {
          children.add(const SizedBox(height: AppSpacing.sm));
        }
      }
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildMessageRow(
            context,
            message: ordered[i],
            currentUserId: currentUserId,
          ),
        ),
      );
    }
    // Reverse list: last sliver is at the scroll top — show day label when the oldest
    // block did not already get a separator between two different days.
    final last = ordered.last;
    if (ordered.length == 1 ||
        _isSameDay(ordered[ordered.length - 2].createdAt, last.createdAt)) {
      children.add(_buildDateSeparator(context, _calendarDay(last.createdAt)));
    }
    return children;
  }

  Widget _buildComposer(BuildContext context, ChatLoaded state) {
    final colors = context.appColors;
    final canSend = _canSend;

    return Row(
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
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (canSend) {
                  _send();
                }
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
        Material(
          color: colors.secondaryAccent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: canSend ? _send : null,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.send_outlined,
                size: 22,
                color: colors.secondaryText2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (previous, current) {
        if (current is ChatError) {
          return true;
        }
        if (current is! ChatLoaded) {
          return false;
        }
        final list = current.messagesAsc;
        if (list.isEmpty) {
          return false;
        }
        final lastId = list.last.id;
        return _lastMessageIdWeScrolledTo != lastId;
      },
      listener: (context, state) {
        if (state is ChatError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          return;
        }
        if (state is ChatLoaded) {
          final list = state.messagesAsc;
          if (list.isEmpty) {
            return;
          }
          final lastId = list.last.id;
          if (_lastMessageIdWeScrolledTo == lastId) {
            return;
          }
          _lastMessageIdWeScrolledTo = lastId;
          final showChat = !state.isFirstTime || _hasAcknowledged;
          if (showChat) {
            _scrollToBottom();
          }
        }
      },
      builder: (context, state) {
        if (state is ChatLoading || state is ChatInitial) {
          return Scaffold(
            backgroundColor: colors.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ChatError) {
          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              leading: CircleBackButton(onPressed: () => _exitChat(context)),
              title: const Text('Chat'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(state.message, textAlign: TextAlign.center),
              ),
            ),
          );
        }

        if (state is! ChatLoaded) {
          return Scaffold(
            backgroundColor: colors.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final loaded = state;
        final title = loaded.roomTitle?.trim().isNotEmpty == true
            ? loaded.roomTitle!.trim()
            : (widget.chatArgs.roomName?.trim().isNotEmpty == true
                ? widget.chatArgs.roomName!.trim()
                : (widget.chatArgs.roomCode.isNotEmpty
                    ? 'Room #${widget.chatArgs.roomCode}'
                    : AppStrings.chatTitle));
        final memberSubtitle =
            '${_memberCountLabel(loaded.participantCount)} | ${loaded.roomCode}';
        final displayName = loaded.userName;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) {
              _exitChat(context);
            }
          },
          child: Scaffold(
            backgroundColor: colors.background,
            body: SafeArea(
              child: Padding(
                padding: AppSpacing.pageHorizontal(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleBackButton(onPressed: () => _exitChat(context)),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                memberSubtitle,
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
                        const ThemeModeSwitcherButton(),
                      ],
                    ),
                    if (loaded.isFirstTime && !_hasAcknowledged) ...[
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                        displayName,
                                        style: const TextStyle(
                                          fontSize: 36,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          height: 1.1,
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
                      ),
                      SizedBox(height: AppSpacing.md),
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
                    if (!loaded.isFirstTime || _hasAcknowledged) ...[
                      Expanded(
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            ListView(
                              reverse: true,
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.lg,
                              ),
                              children: _buildMessageList(
                                context,
                                loaded.messagesAsc,
                                loaded.currentUserId,
                              ),
                            ),
                            if (loaded.isLoadingMore)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.primaryAccent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildComposer(context, loaded),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

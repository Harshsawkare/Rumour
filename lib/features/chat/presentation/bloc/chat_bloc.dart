import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:room_chat/core/utils/repository_result.dart';
import 'package:room_chat/features/chat/domain/entities/room_message_entity.dart';
import 'package:room_chat/features/chat/domain/repositories/chat_repository.dart';
import 'package:room_chat/features/chat/domain/use_cases/resolve_chat_session_use_case.dart';
import 'package:room_chat/features/room/domain/entities/participant_entity.dart';
import 'package:room_chat/features/room/domain/repositories/room_repository.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

final class InitializeChat extends ChatEvent {
  const InitializeChat({
    required this.roomId,
    required this.roomCode,
    this.roomTitle,
  });

  final String roomId;
  final String roomCode;
  final String? roomTitle;

  @override
  List<Object?> get props => [roomId, roomCode, roomTitle];
}

final class SendMessage extends ChatEvent {
  const SendMessage(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class LoadMoreMessages extends ChatEvent {
  const LoadMoreMessages();
}

/// Firestore realtime batch (newest-first from repository).
final class ChatMessagesSnapshot extends ChatEvent {
  const ChatMessagesSnapshot(this.messages);

  final List<RoomMessage> messages;

  @override
  List<Object?> get props => [messages];
}

/// `rooms/{roomId}/participants` document count (live).
final class ChatParticipantCountChanged extends ChatEvent {
  const ChatParticipantCountChanged(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatLoaded extends ChatState {
  const ChatLoaded({
    required this.messagesAsc,
    required this.hasMore,
    required this.currentUserId,
    required this.userName,
    required this.avatar,
    required this.roomCode,
    this.roomTitle,
    required this.participantCount,
    required this.isLoadingMore,
    required this.isFirstTime,
  });

  final List<RoomMessage> messagesAsc;
  final bool hasMore;
  final String currentUserId;
  final String userName;
  final String avatar;
  final String roomCode;
  final String? roomTitle;
  final int participantCount;
  final bool isLoadingMore;

  /// First-time join acknowledgement — `true` only when `participants/{deviceId}` was created in this session.
  final bool isFirstTime;

  @override
  List<Object?> get props => [
        messagesAsc,
        hasMore,
        currentUserId,
        userName,
        avatar,
        roomCode,
        roomTitle,
        participantCount,
        isLoadingMore,
        isFirstTime,
      ];
}

final class ChatError extends ChatState {
  const ChatError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required ResolveChatSessionUseCase resolveChatSessionUseCase,
    required ChatRepository chatRepository,
    required RoomRepository roomRepository,
  })  : _resolveChatSessionUseCase = resolveChatSessionUseCase,
        _chatRepository = chatRepository,
        _roomRepository = roomRepository,
        super(const ChatInitial()) {
    on<InitializeChat>(_onInitializeChat);
    on<ChatMessagesSnapshot>(_onMessagesSnapshot);
    on<ChatParticipantCountChanged>(_onParticipantCountChanged);
    on<SendMessage>(_onSendMessage);
    on<LoadMoreMessages>(_onLoadMore);
  }

  final ResolveChatSessionUseCase _resolveChatSessionUseCase;
  final ChatRepository _chatRepository;
  final RoomRepository _roomRepository;

  StreamSubscription<List<RoomMessage>>? _messagesSub;
  StreamSubscription<int>? _participantCountSub;

  String? _roomId;
  Participant? _self;

  String? _roomCode;
  String? _roomTitle;
  bool _isFirstTime = false;

  List<RoomMessage> _streamAsc = [];
  List<RoomMessage> _olderAsc = [];

  DateTime? _lastSendAt;

  Future<void> _onInitializeChat(
    InitializeChat event,
    Emitter<ChatState> emit,
  ) async {
    await _messagesSub?.cancel();
    _messagesSub = null;
    await _participantCountSub?.cancel();
    _participantCountSub = null;
    _roomId = event.roomId;
    _roomCode = event.roomCode;
    _roomTitle = event.roomTitle;
    _isFirstTime = false;
    _streamAsc = [];
    _olderAsc = [];
    _self = null;

    emit(const ChatLoading());

    final roomLookup = await _roomRepository.getRoomById(event.roomId);
    switch (roomLookup) {
      case RepositorySuccess(:final data):
        final room = data;
        if (room != null && room.roomName.trim().isNotEmpty) {
          _roomTitle = room.roomName.trim();
        }
        break;
      case RepositoryFailure():
        break;
    }

    final session = await _resolveChatSessionUseCase.execute(event.roomId);
    switch (session) {
      case RepositorySuccess(:final data):
        final p = data.participant;
        _isFirstTime = data.isNewParticipant;
        _self = p;
        _chatRepository.resetPaginationState();

        _messagesSub = _chatRepository
            .watchMessages(
              roomId: event.roomId,
              limit: 20,
            )
            .listen(
              (batch) => add(ChatMessagesSnapshot(batch)),
              onError: (Object e, StackTrace st) {
                debugPrint('ChatBloc: message stream error: $e');
              },
            );

        _participantCountSub = _roomRepository
            .watchParticipantCount(event.roomId)
            .listen(
              (count) => add(ChatParticipantCountChanged(count)),
              onError: (Object e, StackTrace st) {
                debugPrint('ChatBloc: participant count stream error: $e');
              },
            );

        emit(
          ChatLoaded(
            messagesAsc: const [],
            hasMore: true,
            currentUserId: p.userId,
            userName: p.userName,
            avatar: p.avatar,
            roomCode: event.roomCode,
            roomTitle: _roomTitle,
            participantCount: 0,
            isLoadingMore: false,
            isFirstTime: _isFirstTime,
          ),
        );
      case RepositoryFailure(:final message):
        emit(ChatError(message));
    }
  }

  void _onParticipantCountChanged(
    ChatParticipantCountChanged event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) {
      return;
    }
    final loaded = state as ChatLoaded;
    emit(
      ChatLoaded(
        messagesAsc: loaded.messagesAsc,
        hasMore: loaded.hasMore,
        currentUserId: loaded.currentUserId,
        userName: loaded.userName,
        avatar: loaded.avatar,
        roomCode: loaded.roomCode,
        roomTitle: loaded.roomTitle,
        participantCount: event.count,
        isLoadingMore: loaded.isLoadingMore,
        isFirstTime: loaded.isFirstTime,
      ),
    );
  }

  void _onMessagesSnapshot(
    ChatMessagesSnapshot event,
    Emitter<ChatState> emit,
  ) {
    if (_self == null || _roomCode == null) {
      return;
    }
    final desc = event.messages;
    final asc = List<RoomMessage>.from(desc)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _streamAsc = asc;

    final prevHasMore = state is ChatLoaded ? (state as ChatLoaded).hasMore : true;
    final loadingMore =
        state is ChatLoaded ? (state as ChatLoaded).isLoadingMore : false;
    final participantCount =
        state is ChatLoaded ? (state as ChatLoaded).participantCount : 0;

    emit(
      ChatLoaded(
        messagesAsc: _mergeMessages(),
        hasMore: prevHasMore,
        currentUserId: _self!.userId,
        userName: _self!.userName,
        avatar: _self!.avatar,
        roomCode: _roomCode!,
        roomTitle: _roomTitle,
        participantCount: participantCount,
        isLoadingMore: loadingMore,
        isFirstTime: _isFirstTime,
      ),
    );
  }

  List<RoomMessage> _mergeMessages() {
    final byId = <String, RoomMessage>{};
    for (final m in _olderAsc) {
      byId[m.id] = m;
    }
    for (final m in _streamAsc) {
      byId[m.id] = m;
    }
    final out = byId.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return out;
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) {
      return;
    }
    final now = DateTime.now();
    if (_lastSendAt != null &&
        now.difference(_lastSendAt!) < const Duration(milliseconds: 320)) {
      return;
    }
    _lastSendAt = now;

    if (_roomId == null || _self == null) {
      return;
    }
    if (state is! ChatLoaded) {
      return;
    }
    final before = state as ChatLoaded;

    final result = await _chatRepository.sendMessage(
      roomId: _roomId!,
      text: text,
      userId: _self!.userId,
      userName: _self!.userName,
      avatar: _self!.avatar,
    );

    switch (result) {
      case RepositorySuccess():
        break;
      case RepositoryFailure(:final message):
        emit(ChatError(message));
        emit(before);
    }
  }

  Future<void> _onLoadMore(
    LoadMoreMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (_roomId == null || _self == null) {
      return;
    }
    if (state is! ChatLoaded) {
      return;
    }
    final loaded = state as ChatLoaded;
    if (loaded.isLoadingMore || !loaded.hasMore) {
      return;
    }

    emit(
      ChatLoaded(
        messagesAsc: loaded.messagesAsc,
        hasMore: loaded.hasMore,
        currentUserId: loaded.currentUserId,
        userName: loaded.userName,
        avatar: loaded.avatar,
        roomCode: loaded.roomCode,
        roomTitle: loaded.roomTitle,
        participantCount: loaded.participantCount,
        isLoadingMore: true,
        isFirstTime: loaded.isFirstTime,
      ),
    );

    final page = await _chatRepository.fetchMoreMessages(
      roomId: _roomId!,
      limit: 20,
    );

    switch (page) {
      case RepositorySuccess(:final data):
        final batch = data.messages;
        final asc = List<RoomMessage>.from(batch)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _olderAsc = [...asc, ..._olderAsc];
        emit(
          ChatLoaded(
            messagesAsc: _mergeMessages(),
            hasMore: data.hasMore,
            currentUserId: _self!.userId,
            userName: _self!.userName,
            avatar: _self!.avatar,
            roomCode: loaded.roomCode,
            roomTitle: loaded.roomTitle,
            participantCount: loaded.participantCount,
            isLoadingMore: false,
            isFirstTime: loaded.isFirstTime,
          ),
        );
      case RepositoryFailure(:final message):
        emit(ChatError(message));
        emit(loaded);
    }
  }

  @override
  Future<void> close() async {
    await _messagesSub?.cancel();
    await _participantCountSub?.cancel();
    return super.close();
  }
}

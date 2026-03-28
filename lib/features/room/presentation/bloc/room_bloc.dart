import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:room_chat/core/utils/repository_result.dart';
import 'package:room_chat/features/room/domain/use_cases/create_room_result.dart';
import 'package:room_chat/features/room/domain/use_cases/create_room_use_case.dart';
import 'package:room_chat/features/room/domain/use_cases/join_room_result.dart';
import 'package:room_chat/features/room/domain/use_cases/join_room_use_case.dart';

sealed class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

final class JoinRoomRequested extends RoomEvent {
  const JoinRoomRequested(this.roomCode);

  final String roomCode;

  @override
  List<Object?> get props => [roomCode];
}

/// Loads a DB-validated random room name for the create-room preview.
final class CreateRoomPreviewRequested extends RoomEvent {
  const CreateRoomPreviewRequested();
}

final class CreateRoomRequested extends RoomEvent {
  const CreateRoomRequested(this.previewRoomName);

  final String previewRoomName;

  @override
  List<Object?> get props => [previewRoomName];
}

/// Clears terminal states after navigation (e.g. user popped back from chat).
final class RoomReset extends RoomEvent {
  const RoomReset();
}

sealed class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object?> get props => [];
}

final class RoomInitial extends RoomState {
  const RoomInitial();
}

/// [retainCreatePreviewName] keeps the preview label visible while the room is being created.
final class RoomLoading extends RoomState {
  const RoomLoading({this.retainCreatePreviewName});

  final String? retainCreatePreviewName;

  @override
  List<Object?> get props => [retainCreatePreviewName];
}

final class RoomCreatePreviewLoading extends RoomState {
  const RoomCreatePreviewLoading();
}

final class RoomCreatePreviewReady extends RoomState {
  const RoomCreatePreviewReady(this.previewRoomName);

  final String previewRoomName;

  @override
  List<Object?> get props => [previewRoomName];
}

/// Failed to load a unique preview name (network / DB); user can retry [CreateRoomPreviewRequested].
final class RoomCreatePreviewLoadError extends RoomState {
  const RoomCreatePreviewLoadError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class RoomJoinSuccess extends RoomState {
  const RoomJoinSuccess({
    required this.roomId,
    required this.roomCode,
    required this.userId,
    required this.userName,
    required this.avatar,
    required this.joinedAt,
  });

  final String roomId;
  final String roomCode;
  final String userId;
  final String userName;
  final String avatar;
  final DateTime joinedAt;

  @override
  List<Object?> get props => [
        roomId,
        roomCode,
        userId,
        userName,
        avatar,
        joinedAt,
      ];
}

final class RoomCreateSuccess extends RoomState {
  const RoomCreateSuccess({
    required this.roomId,
    required this.roomCode,
    required this.roomName,
    required this.userId,
    required this.userName,
    required this.avatar,
    required this.joinedAt,
  });

  final String roomId;
  final String roomCode;
  final String roomName;
  final String userId;
  final String userName;
  final String avatar;
  final DateTime joinedAt;

  @override
  List<Object?> get props => [
        roomId,
        roomCode,
        roomName,
        userId,
        userName,
        avatar,
        joinedAt,
      ];
}

final class RoomError extends RoomState {
  const RoomError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  RoomBloc({
    required JoinRoomUseCase joinRoomUseCase,
    required CreateRoomUseCase createRoomUseCase,
  })  : _joinRoomUseCase = joinRoomUseCase,
        _createRoomUseCase = createRoomUseCase,
        super(const RoomInitial()) {
    on<JoinRoomRequested>(_onJoinRoomRequested);
    on<CreateRoomPreviewRequested>(_onCreateRoomPreviewRequested);
    on<CreateRoomRequested>(_onCreateRoomRequested);
    on<RoomReset>(_onRoomReset);
  }

  final JoinRoomUseCase _joinRoomUseCase;
  final CreateRoomUseCase _createRoomUseCase;

  Future<void> _onJoinRoomRequested(
    JoinRoomRequested event,
    Emitter<RoomState> emit,
  ) async {
    if (state is RoomLoading) {
      return;
    }
    emit(const RoomLoading());
    final result = await _joinRoomUseCase.execute(event.roomCode);
    switch (result) {
      case JoinRoomSuccessResult(
          :final roomId,
          :final roomCode,
          :final userId,
          :final userName,
          :final avatar,
          :final joinedAt,
        ):
        emit(
          RoomJoinSuccess(
            roomId: roomId,
            roomCode: roomCode,
            userId: userId,
            userName: userName,
            avatar: avatar,
            joinedAt: joinedAt,
          ),
        );
      case JoinRoomFailureResult(:final message):
        emit(RoomError(message));
    }
  }

  Future<void> _onCreateRoomPreviewRequested(
    CreateRoomPreviewRequested event,
    Emitter<RoomState> emit,
  ) async {
    emit(const RoomCreatePreviewLoading());
    final result = await _createRoomUseCase.resolveUniqueRoomNameForPreview();
    switch (result) {
      case RepositorySuccess(:final data):
        emit(RoomCreatePreviewReady(data));
      case RepositoryFailure(:final message):
        emit(RoomCreatePreviewLoadError(message));
    }
  }

  Future<void> _onCreateRoomRequested(
    CreateRoomRequested event,
    Emitter<RoomState> emit,
  ) async {
    if (state is RoomLoading) {
      return;
    }
    emit(
      RoomLoading(retainCreatePreviewName: event.previewRoomName),
    );
    final result = await _createRoomUseCase.execute(
      roomName: event.previewRoomName,
    );
    switch (result) {
      case CreateRoomSuccessResult(
          :final roomId,
          :final roomCode,
          :final roomName,
          :final userId,
          :final userName,
          :final avatar,
          :final joinedAt,
        ):
        emit(
          RoomCreateSuccess(
            roomId: roomId,
            roomCode: roomCode,
            roomName: roomName,
            userId: userId,
            userName: userName,
            avatar: avatar,
            joinedAt: joinedAt,
          ),
        );
      case CreateRoomFailureResult(:final message):
        emit(RoomError(message));
        emit(RoomCreatePreviewReady(event.previewRoomName));
    }
  }

  void _onRoomReset(RoomReset event, Emitter<RoomState> emit) {
    emit(const RoomInitial());
  }
}

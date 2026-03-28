import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class JoinRoomEvent extends Equatable {
  const JoinRoomEvent();

  @override
  List<Object?> get props => [];
}

final class JoinRoomStarted extends JoinRoomEvent {
  const JoinRoomStarted();
}

sealed class JoinRoomState extends Equatable {
  const JoinRoomState();

  @override
  List<Object?> get props => [];
}

final class JoinRoomInitial extends JoinRoomState {
  const JoinRoomInitial();
}

class JoinRoomBloc extends Bloc<JoinRoomEvent, JoinRoomState> {
  JoinRoomBloc() : super(const JoinRoomInitial()) {
    on<JoinRoomStarted>((event, emit) async {
      // Foundation only.
    });
  }
}

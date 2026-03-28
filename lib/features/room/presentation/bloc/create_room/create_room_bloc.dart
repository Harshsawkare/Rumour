import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class CreateRoomEvent extends Equatable {
  const CreateRoomEvent();

  @override
  List<Object?> get props => [];
}

final class CreateRoomStarted extends CreateRoomEvent {
  const CreateRoomStarted();
}

sealed class CreateRoomState extends Equatable {
  const CreateRoomState();

  @override
  List<Object?> get props => [];
}

final class CreateRoomInitial extends CreateRoomState {
  const CreateRoomInitial();
}

class CreateRoomBloc extends Bloc<CreateRoomEvent, CreateRoomState> {
  CreateRoomBloc() : super(const CreateRoomInitial()) {
    on<CreateRoomStarted>((event, emit) async {
      // Foundation only.
    });
  }
}

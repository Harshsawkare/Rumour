import 'package:equatable/equatable.dart';

/// Safe success/failure wrapper for repository calls (no raw exceptions to Bloc).
sealed class RepositoryResult<T> extends Equatable {
  const RepositoryResult();

  @override
  List<Object?> get props => [];
}

final class RepositorySuccess<T> extends RepositoryResult<T> {
  const RepositorySuccess(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

final class RepositoryFailure<T> extends RepositoryResult<T> {
  const RepositoryFailure(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

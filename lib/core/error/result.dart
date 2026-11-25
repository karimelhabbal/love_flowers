import 'failures.dart';

/// A tiny functional result type. Avoids pulling a functional-programming
/// package into the project while still giving exhaustive error handling.
sealed class Result<T> {
  const Result();

  R fold<R>(R Function(T value) onSuccess, R Function(Failure failure) onError) {
    return switch (this) {
      Ok(:final value) => onSuccess(value),
      Err(:final failure) => onError(failure),
    };
  }

  T? get valueOrNull => switch (this) {
        Ok(:final value) => value,
        Err() => null,
      };

  Failure? get errorOrNull => switch (this) {
        Ok() => null,
        Err(:final failure) => failure,
      };

  bool get isSuccess => this is Ok<T>;
  bool get isFailure => this is Err<T>;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}

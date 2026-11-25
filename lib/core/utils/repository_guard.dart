import '../error/failures.dart';
import '../error/result.dart';
import 'error_mapper.dart';

Future<Result<T>> runSafe<T>(Future<T> Function() action) async {
  try {
    return Ok<T>(await action());
  } catch (error) {
    return Err<T>(mapError(error));
  }
}

Failure toFailure(Object error) => mapError(error);

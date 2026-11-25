/// Domain-level error types. Data sources translate provider exceptions into
/// these so the presentation layer never depends on Supabase or HTTP details.
sealed class Failure {
  const Failure(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => message;
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection', super.code]);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found', super.code]);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([
    super.message = 'You do not have permission to do that',
    super.code,
  ]);
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

final class ConfigurationFailure extends Failure {
  const ConfigurationFailure(super.message, [super.code]);
}

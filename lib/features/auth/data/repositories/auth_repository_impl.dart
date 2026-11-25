import '../../../../core/error/result.dart';
import '../../../../core/utils/repository_guard.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<AppUser?> get authStateChanges => _remote.authStateChanges;

  @override
  AppUser? get currentUser => _remote.currentUser;

  @override
  Future<bool> get isAdmin async {
    final result = await runSafe(_remote.getProfile);
    return result.fold((user) => user.isAdmin, (_) => false);
  }

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) =>
      runSafe(() => _remote.signIn(email: email, password: password));

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) =>
      runSafe(() => _remote.signUp(
            email: email,
            password: password,
            fullName: fullName,
            phone: phone,
          ));

  @override
  Future<Result<void>> signOut() => runSafe(_remote.signOut);

  @override
  Future<Result<AppUser>> getProfile() => runSafe(_remote.getProfile);

  @override
  Future<Result<AppUser>> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) =>
      runSafe(() => _remote.updateProfile(
            fullName: fullName,
            phone: phone,
            avatarUrl: avatarUrl,
          ));

  @override
  Future<Result<void>> resetPassword(String email) =>
      runSafe(() => _remote.resetPassword(email));
}

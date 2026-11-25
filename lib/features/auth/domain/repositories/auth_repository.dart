import '../../../../core/error/result.dart';
import '../entities/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> get authStateChanges;

  AppUser? get currentUser;

  Future<bool> get isAdmin;

  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  Future<Result<void>> signOut();

  Future<Result<AppUser>> getProfile();

  Future<Result<AppUser>> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  });

  Future<Result<void>> resetPassword(String email);
}

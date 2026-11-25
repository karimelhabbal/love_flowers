import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/app_user.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final SupabaseClient? _client;

  SupabaseClient get _db {
    final client = _client;
    if (client == null || !AppConstants.isSupabaseConfigured) {
      throw StateError('Supabase is not configured');
    }
    return client;
  }

  Stream<AppUser?> get authStateChanges {
    return _db.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;
      return _userFromAuth(user);
    });
  }

  AppUser? get currentUser {
    final user = _client?.auth.currentUser;
    if (user == null) return null;
    return _userFromAuth(user);
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _db.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) throw StateError('Invalid login credentials');
    return _userFromAuth(user);
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final response = await _db.auth.signUp(
      email: email.trim(),
      password: password,
      data: <String, dynamic>{
        'full_name': fullName.trim(),
        'phone': phone?.trim(),
      },
    );
    final user = response.user;
    if (user == null) throw StateError('Could not create account');
    if (response.session == null) {
      throw StateError(
        'Account created. Confirm your email before signing in.',
      );
    }

    // The profile row is created by the backend trigger on auth.users.
    // Never write role or email from here.
    return _userFromAuth(user);
  }

  Future<void> signOut() => _db.auth.signOut();

  Future<AppUser> getProfile() async {
    final authUser = _db.auth.currentUser;
    if (authUser == null) throw StateError('Not signed in');
    final row = await _db
        .from('profiles')
        .select('id, full_name, phone, avatar_url, role, created_at')
        .eq('id', authUser.id)
        .maybeSingle();

    if (row == null) {
      final created = await _db.from('profiles').insert(<String, dynamic>{
        'id': authUser.id,
        'full_name': authUser.userMetadata?['full_name'] as String? ?? '',
        'phone': authUser.userMetadata?['phone'] as String?,
      }).select('id, full_name, phone, avatar_url, role, created_at').single();
      return _withEmail(
        Map<String, dynamic>.from(created),
        authUser.email ?? '',
      );
    }
    return _withEmail(Map<String, dynamic>.from(row), authUser.email ?? '');
  }

  Future<AppUser> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final authUser = _db.auth.currentUser;
    if (authUser == null) throw StateError('Not signed in');
    final payload = <String, dynamic>{
      if (fullName != null) 'full_name': fullName.trim(),
      if (phone != null) 'phone': phone.trim(),
      'avatar_url': ?avatarUrl,
    };
    if (payload.isEmpty) return getProfile();
    final row = await _db
        .from('profiles')
        .update(payload)
        .eq('id', authUser.id)
        .select('id, full_name, phone, avatar_url, role, created_at')
        .single();
    return _withEmail(Map<String, dynamic>.from(row), authUser.email ?? '');
  }

  Future<void> resetPassword(String email) =>
      _db.auth.resetPasswordForEmail(email.trim());

  AppUser _userFromAuth(User user) => AppUser(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String? ?? '',
        phone: user.userMetadata?['phone'] as String? ?? '',
      );

  AppUser _withEmail(Map<String, dynamic> map, String email) =>
      AppUser.fromMap(<String, dynamic>{...map, 'email': email});
}

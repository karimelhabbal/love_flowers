import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.message,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? message;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isAdmin => user?.isAdmin ?? false;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool clearUser = false,
    String? message,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, user, message];
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState()) {
    _subscription = _repository.authStateChanges.listen(_onAuthChanged);
  }

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _subscription;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await refreshProfile();
  }

  void _onAuthChanged(AppUser? user) {
    if (user == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } else {
      emit(AuthState(status: AuthStatus.authenticated, user: user));
      refreshProfile();
    }
  }

  Future<void> refreshProfile() async {
    if (_repository.currentUser == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    final result = await _repository.getProfile();
    result.fold(
      (user) => emit(
        AuthState(status: AuthStatus.authenticated, user: user),
      ),
      (failure) => emit(
        state.copyWith(status: AuthStatus.failure, message: failure.message),
      ),
    );
  }

  Future<bool> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    final result = await _repository.signIn(email: email, password: password);
    return result.fold(
      (user) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
        return true;
      },
      (failure) {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            message: failure.message,
          ),
        );
        return false;
      },
    );
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    final result = await _repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
    return result.fold(
      (user) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
        return true;
      },
      (failure) {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            message: failure.message,
          ),
        );
        return false;
      },
    );
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _repository.signOut();
    result.fold(
      (_) => emit(const AuthState(status: AuthStatus.unauthenticated)),
      (failure) => emit(
        state.copyWith(status: AuthStatus.failure, message: failure.message),
      ),
    );
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    final result = await _repository.updateProfile(
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
    );
    return result.fold(
      (user) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
        return true;
      },
      (failure) {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            message: failure.message,
          ),
        );
        return false;
      },
    );
  }

  Future<bool> resetPassword(String email) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    final result = await _repository.resetPassword(email);
    return result.fold(
      (_) {
        emit(state.copyWith(status: AuthStatus.initial, clearMessage: true));
        return true;
      },
      (failure) {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            message: failure.message,
          ),
        );
        return false;
      },
    );
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

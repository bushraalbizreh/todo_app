import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/auth_repository.dart';

enum AuthStatus { unknown, signedOut, signedIn, loading, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  bool get isSignedIn => status == AuthStatus.signedIn && user != null;
  bool get isRemoteAvailable => status != AuthStatus.error || user != null;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState()) {
    final currentUser = _repository.currentUser;
    emit(
      AuthState(
        status: currentUser == null
            ? AuthStatus.signedOut
            : AuthStatus.signedIn,
        user: currentUser,
      ),
    );
    _subscription = _repository.authStateChanges().listen(_onAuthState);
    if (currentUser == null && _repository.isRemoteAvailable) {
      // Silent sign-in: Firebase Anonymous Authentication supplies a real
      // per-user UID for users/{uid}/... without any login screen. On
      // failure the app simply keeps running local-only (the header reports
      // it) and the settings sheet still offers a manual retry.
      unawaited(_signInSilently());
    }
  }

  final AuthRepository _repository;
  StreamSubscription<User?>? _subscription;

  /// Background anonymous sign-in — never surfaces an error state, because a
  /// failed *attempt nobody asked for* must not paint the account UI red.
  /// The exact error is still printed for diagnostics.
  Future<void> _signInSilently() async {
    try {
      final user = await _repository.signInAnonymously();
      if (kDebugMode) {
        debugPrint('[AUTH] anonymous sign-in succeeded: uid=${user?.uid}');
      }
      // authStateChanges() delivers the new user; the subscription above
      // emits signedIn and repositories retarget to this uid.
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[AUTH] anonymous sign-in FAILED: $error');
      }
    }
  }

  void _onAuthState(User? user) {
    emit(
      AuthState(
        status: user == null ? AuthStatus.signedOut : AuthStatus.signedIn,
        user: user,
      ),
    );
  }

  Future<void> signInAnonymously() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.signInAnonymously();
      emit(
        AuthState(
          status: user == null ? AuthStatus.signedOut : AuthStatus.signedIn,
          user: user,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _repository.signOut();
      emit(const AuthState(status: AuthStatus.signedOut));
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

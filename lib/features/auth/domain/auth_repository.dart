import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../data/auth_remote_data_source.dart';

class AuthRepository {
  AuthRepository(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  bool get isRemoteAvailable => _remoteDataSource.isAvailable;

  User? get currentUser => _remoteDataSource.currentUser;

  Stream<User?> authStateChanges() => _remoteDataSource.authStateChanges();

  Future<User?> signInAnonymously() => _remoteDataSource.signInAnonymously();

  Future<void> signOut() => _remoteDataSource.signOut();
}

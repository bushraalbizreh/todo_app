import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._auth);

  final FirebaseAuth? _auth;

  bool get isAvailable => _auth != null;

  User? get currentUser => _auth?.currentUser;

  Stream<User?> authStateChanges() {
    final auth = _auth;
    if (auth == null) return const Stream<User?>.empty();
    return auth.authStateChanges();
  }

  Future<User?> signInAnonymously() async {
    final auth = _auth;
    if (auth == null) {
      // Never report success for an operation that could not run: the UI
      // shows a localized error instead of pretending the sign-in worked.
      throw StateError('AuthRemoteDataSource used without FirebaseAuth.');
    }
    final credential = await auth.signInAnonymously();
    return credential.user;
  }

  Future<void> signOut() async {
    final auth = _auth;
    if (auth == null) {
      throw StateError('AuthRemoteDataSource used without FirebaseAuth.');
    }
    await auth.signOut();
  }
}

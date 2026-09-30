import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:to_do_with_fire_base/data/todo_repository.dart';
import 'package:to_do_with_fire_base/features/auth/data/auth_remote_data_source.dart';
import 'package:to_do_with_fire_base/features/auth/domain/auth_repository.dart';
import 'package:to_do_with_fire_base/features/auth/presentation/auth_cubit.dart';
import 'package:to_do_with_fire_base/features/todo/data/todo_remote_data_source.dart';
import 'package:to_do_with_fire_base/firebase_options.dart';

/// Regression tests for the live-persistence fix (requirement 9):
///
///  1. Firebase configuration points to the expected project.
///  2. Authentication state determines the user UID.
///  3. The repository uses that UID as the Firestore path segment.
///  4. Remote failures are surfaced.
///  5. Successful remote writes are distinguishable from local-only saves.
///
/// These tests prove configuration/auth/path *wiring* of the app code.
/// They run against fakes and therefore do NOT — and must never be cited as —
/// proof of live backend connectivity.
void main() {
  group('Firebase configuration', () {
    test('every platform targets project to-do-app-55081', () {
      final options = <String, FirebaseOptions>{
        'currentPlatform': DefaultFirebaseOptions.currentPlatform,
        'android': DefaultFirebaseOptions.android,
        'ios': DefaultFirebaseOptions.ios,
        'web': DefaultFirebaseOptions.web,
        'macos': DefaultFirebaseOptions.macos,
        'windows': DefaultFirebaseOptions.windows,
      };
      options.forEach((platform, value) {
        expect(
          value.projectId,
          'to-do-app-55081',
          reason: '$platform must point at the expected project',
        );
        expect(value.apiKey, isNotEmpty);
        expect(value.appId, isNotEmpty);
      });
    });
  });

  group('Authentication state → UID', () {
    test('silent anonymous sign-in puts a real UID on the auth state', () async {
      final source = _FakeAuthRemoteDataSource();
      final cubit = AuthCubit(AuthRepository(source));
      addTearDown(cubit.close);

      // The constructor kicks off the UI-less silent sign-in.
      await pumpEventQueue();

      expect(cubit.state.isSignedIn, isTrue, reason: 'anonymous session');
      expect(cubit.state.user?.uid, 'anon-uid-42');
      expect(cubit.state.errorMessage, isNull);
      expect(source.signInCalls, 1, reason: 'exactly one silent attempt');
    });

    test(
        'without a Firebase Auth backend the app stays signed out as guest',
        () async {
      final source = _FakeAuthRemoteDataSource()..available = false;
      final cubit = AuthCubit(AuthRepository(source));
      addTearDown(cubit.close);

      await pumpEventQueue();

      // No auth backend → no attempt, no error state, uid resolves to guest.
      expect(source.signInCalls, 0);
      expect(cubit.state.isSignedIn, isFalse);
      expect(cubit.state.user?.uid ?? 'guest', 'guest');
    });

    test('the UID from auth state becomes the Firestore path segment',
        () async {
      final source = _FakeAuthRemoteDataSource();
      final cubit = AuthCubit(AuthRepository(source));
      addTearDown(cubit.close);
      await pumpEventQueue();

      // Exactly the expression main.dart wires between AuthCubit and the
      // repositories: state.user?.uid ?? 'guest'.
      final uid = cubit.state.user?.uid ?? 'guest';
      expect(uid, 'anon-uid-42');

      final remote = _RecordingTodoRemoteDataSource();
      final repository = TodoRepository.seeded(
        remoteDataSource: remote,
        userId: uid,
      );
      addTearDown(repository.dispose);
      await repository.sync();
      await pumpEventQueue();

      expect(remote.fetchUserIds, ['anon-uid-42'],
          reason: 'reads must target users/{uid}/…');
      expect(remote.pushUserIds, ['anon-uid-42'],
          reason: 'writes must target users/{uid}/…');
    });

    test('retargeting the repository moves every path to the new uid', () async {
      final remote = _RecordingTodoRemoteDataSource();
      final repository = TodoRepository.seeded(
        remoteDataSource: remote,
        userId: 'guest',
      );
      addTearDown(repository.dispose);

      // Guest first: nothing may leave the device.
      await repository.sync();
      await pumpEventQueue();
      expect(remote.fetchUserIds, isEmpty);
      expect(remote.pushUserIds, isEmpty);

      // Sign-in retargets (as the BlocListener in main.dart does).
      repository.setUserId('anon-uid-42');
      await pumpEventQueue();

      expect(remote.fetchUserIds, ['anon-uid-42'],
          reason: 'after sign-in the read must run under the uid');
      expect(remote.pushUserIds, ['anon-uid-42'],
          reason: 'after sign-in the write must run under the uid');
    });
  });

  group('Remote failure surfacing', () {
    test('a failed push records lastSyncError with the exact cause', () async {
      final remote = _RecordingTodoRemoteDataSource();
      final repository = TodoRepository.seeded(
        remoteDataSource: remote,
        userId: 'qa-user',
      );
      addTearDown(repository.dispose);
      await repository.sync();
      await pumpEventQueue();
      expect(repository.hasSyncedOnce, isTrue, reason: 'initial sync worked');

      remote.failNextPush = Exception('backend unreachable');
      repository.removeTask('personal-1');
      await pumpEventQueue();

      expect(repository.lastSyncError, isNotNull,
          reason: 'the failure must be recorded for the UI');
      expect(
        repository.lastSyncError.toString(),
        contains('backend unreachable'),
        reason: 'the exact backend error must not be swallowed',
      );
    });

    test('a later successful sync clears the recorded failure', () async {
      final remote = _RecordingTodoRemoteDataSource();
      final repository = TodoRepository.seeded(
        remoteDataSource: remote,
        userId: 'qa-user',
      );
      addTearDown(repository.dispose);
      await repository.sync();
      await pumpEventQueue();

      remote.failNextPush = Exception('offline');
      repository.removeTask('personal-1');
      await pumpEventQueue();
      expect(repository.lastSyncError, isNotNull);

      await repository.sync();
      await pumpEventQueue();
      expect(repository.lastSyncError, isNull);
      expect(repository.hasSyncedOnce, isTrue);
    });
  });

  group('Local-only vs remote-backed saves', () {
    test('a guest session performs zero remote operations', () async {
      final remote = _RecordingTodoRemoteDataSource();
      final repository = TodoRepository.seeded(
        remoteDataSource: remote,
        userId: 'guest',
      );
      addTearDown(repository.dispose);

      repository.removeTask('personal-1');
      await repository.sync();
      await pumpEventQueue();

      expect(remote.fetchUserIds, isEmpty);
      expect(remote.pushUserIds, isEmpty);
      expect(repository.hasRemoteDataSource, isFalse);
      expect(repository.hasSyncedOnce, isFalse,
          reason: 'a local-only save must never claim a sync happened');
    });

    test('a session without any Firebase backend also never claims sync',
        () async {
      final repository = TodoRepository.seeded(userId: 'guest');
      addTearDown(repository.dispose);

      repository.removeTask('personal-1');
      await repository.sync();
      await pumpEventQueue();

      expect(repository.hasRemoteDataSource, isFalse);
      expect(repository.hasSyncedOnce, isFalse);
      expect(repository.lastSyncError, isNull);
    });

    test('an authenticated session pushes and then claims exactly one sync',
        () async {
      final remote = _RecordingTodoRemoteDataSource();
      final repository = TodoRepository.seeded(
        remoteDataSource: remote,
        userId: 'qa-user',
      );
      addTearDown(repository.dispose);

      expect(repository.hasSyncedOnce, isFalse,
          reason: 'nothing reached the backend yet');

      await repository.sync();
      await pumpEventQueue();

      expect(remote.pushUserIds, ['qa-user']);
      expect(repository.hasSyncedOnce, isTrue);
      expect(repository.lastSyncError, isNull);
    });
  });
}

/// Identity-less stand-in for FirebaseAuth: `signInAnonymously` flips the
/// session exactly like FirebaseAuth does — currentUser changes and the
/// authStateChanges stream emits the new user.
class _FakeAuthRemoteDataSource extends AuthRemoteDataSource {
  _FakeAuthRemoteDataSource() : super(null);

  bool available = true;
  int signInCalls = 0;
  User? _currentUser;
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();

  @override
  bool get isAvailable => available;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  Future<User?> signInAnonymously() async {
    if (!available) {
      throw StateError('AuthRemoteDataSource used without FirebaseAuth.');
    }
    signInCalls += 1;
    _currentUser = _FakeUser('anon-uid-42');
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}

/// A User whose uid/isAnonymous are fixed; every other member falls through
/// to noSuchMethod (never called by these tests).
class _FakeUser implements User {
  _FakeUser(this.uid);

  @override
  final String uid;

  @override
  bool get isAnonymous => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Recording stand-in for the real Firestore data source: captures the uid
/// used for every fetch/push so path targeting can be asserted.
class _RecordingTodoRemoteDataSource extends TodoRemoteDataSource {
  _RecordingTodoRemoteDataSource() : super(null);

  final List<String> fetchUserIds = <String>[];
  final List<String> pushUserIds = <String>[];
  Object? failNextPush;

  @override
  bool get isAvailable => true;

  @override
  Future<TodoRemoteSnapshot?> fetchSnapshot(String userId) async {
    fetchUserIds.add(userId);
    return null; // empty backend → repository uploads its snapshot
  }

  @override
  Future<void> pushSnapshot({
    required String userId,
    required List<Map<String, dynamic>> lists,
    required List<Map<String, dynamic>> tasks,
    List<String> deletedListIds = const <String>[],
    List<String> deletedTaskIds = const <String>[],
  }) async {
    final error = failNextPush;
    if (error != null) {
      failNextPush = null;
      throw error;
    }
    pushUserIds.add(userId);
  }
}

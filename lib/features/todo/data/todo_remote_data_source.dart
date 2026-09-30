import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TodoRemoteSnapshot {
  const TodoRemoteSnapshot({required this.lists, required this.tasks});

  final List<Map<String, dynamic>> lists;
  final List<Map<String, dynamic>> tasks;
}

class TodoRemoteDataSource {
  const TodoRemoteDataSource(this._firestore);

  final FirebaseFirestore? _firestore;

  bool get isAvailable => _firestore != null;

  Future<TodoRemoteSnapshot?> fetchSnapshot(String userId) async {
    final firestore = _firestore;
    if (firestore == null) {
      // Never report success for a remote operation that could not run:
      // callers must gate on [isAvailable].
      throw StateError('TodoRemoteDataSource used without Firestore.');
    }

    if (kDebugMode) {
      debugPrint('[SYNC] Firestore read STARTED uid=$userId');
    }
    try {
      final root = firestore.collection('users').doc(userId);
      final listSnapshot = await root.collection('lists').get();
      final taskSnapshot = await root.collection('tasks').get();
      final lists = listSnapshot.docs
          .map((document) => Map<String, dynamic>.from(document.data()))
          .where((data) => data['id'] != null)
          .toList(growable: false);
      final tasks = taskSnapshot.docs
          .map((document) => Map<String, dynamic>.from(document.data()))
          .where((data) => data['id'] != null && data['listId'] != null)
          .toList(growable: false);
      if (kDebugMode) {
        debugPrint(
          '[SYNC] Firestore read SUCCEEDED uid=$userId '
          'lists=${lists.length} tasks=${tasks.length}',
        );
      }
      if (lists.isEmpty && tasks.isEmpty) return null;
      return TodoRemoteSnapshot(lists: lists, tasks: tasks);
    } catch (error) {
      // Never swallow the exact backend error (permission-denied, unavailable…).
      if (kDebugMode) {
        debugPrint('[SYNC] Firestore read FAILED uid=$userId error=$error');
      }
      rethrow;
    }
  }

  /// Pushes the full local snapshot and replays every pending deletion.
  ///
  /// Deletions are explicit (tombstones recorded by the repository): the
  /// documents removed since the last successful push are deleted remotely so
  /// a later fetch can never resurrect them. Writes are never reported as
  /// successful when they did not run — an unavailable [FirebaseFirestore]
  /// throws instead of returning silently.
  Future<void> pushSnapshot({
    required String userId,
    required List<Map<String, dynamic>> lists,
    required List<Map<String, dynamic>> tasks,
    List<String> deletedListIds = const <String>[],
    List<String> deletedTaskIds = const <String>[],
  }) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError('TodoRemoteDataSource used without Firestore.');
    }

    // Diagnostic C: the write is about to reach the real backend.
    if (kDebugMode) {
      debugPrint(
        '[SYNC] C) Firestore write STARTED uid=$userId '
        'lists=${lists.length} tasks=${tasks.length} '
        'deletedLists=${deletedListIds.length} '
        'deletedTasks=${deletedTaskIds.length}',
      );
    }
    try {
      final root = firestore.collection('users').doc(userId);
      final batch = firestore.batch();
      for (final list in lists) {
        batch.set(root.collection('lists').doc('${list['id']}'), list);
      }
      for (final task in tasks) {
        batch.set(root.collection('tasks').doc('${task['id']}'), task);
      }
      for (final listId in deletedListIds) {
        batch.delete(root.collection('lists').doc(listId));
      }
      for (final taskId in deletedTaskIds) {
        batch.delete(root.collection('tasks').doc(taskId));
      }
      await batch.commit();
      // Diagnostic D: the backend acknowledged the batch.
      if (kDebugMode) {
        debugPrint('[SYNC] D) Firestore write SUCCEEDED uid=$userId');
      }
    } catch (error) {
      // Diagnostic E: exact exception — never swallowed.
      if (kDebugMode) {
        debugPrint('[SYNC] E) Firestore write FAILED uid=$userId error=$error');
      }
      rethrow;
    }
  }
}

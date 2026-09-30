import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:to_do_with_fire_base/core/storage/app_storage.dart';
import 'package:to_do_with_fire_base/data/todo_repository.dart';
import 'package:to_do_with_fire_base/features/todo/data/todo_local_data_source.dart';

/// Real on-disk persistence coverage (gap D9).
///
/// Unlike the in-memory storage used by every other test, this file exercises
/// the ACTUAL Hive implementation: a real box file is written into a real
/// temporary directory, the box is closed (simulated app restart) and reopened
/// from disk, and the repository must hydrate the same state back.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('to_do_hive_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    try {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    } catch (_) {
      // Windows may briefly hold the file handle; the temp dir is disposable.
    }
  });

  test('a real Hive box persists the snapshot across close and reopen',
      () async {
    // --- session 1: mutate through the real repository + real Hive box ---
    expect(Hive.isBoxOpen(HiveAppStorage.boxName), isFalse);
    final box = await Hive.openBox<dynamic>(HiveAppStorage.boxName);
    final local = TodoLocalDataSource(HiveAppStorage(box));

    final repository = TodoRepository.seeded(localDataSource: local);
    // The seed ships with task personal-1: deleting it is the change that
    // must survive the restart (the restarted seed would still contain it,
    // so only data from disk can explain its absence).
    expect(repository.taskById('personal-1'), isNotNull);
    repository.removeTask('personal-1');
    await pumpEventQueue(times: 10); // let the unawaited persist finish

    final boxFile = File(
      '${tempDir.path}${Platform.pathSeparator}'
      '${HiveAppStorage.boxName}.hive',
    );
    expect(boxFile.existsSync(), isTrue,
        reason: 'Hive must have produced a real file on disk');
    expect(boxFile.lengthSync(), greaterThan(0),
        reason: 'the snapshot must actually be written, not just opened');

    await Hive.close(); // simulate killing the app

    // --- session 2: restart and hydrate from disk ---
    Hive.init(tempDir.path);
    final reopened = await Hive.openBox<dynamic>(HiveAppStorage.boxName);
    final restoredSource = TodoLocalDataSource(HiveAppStorage(reopened));

    final rawSnapshot = await restoredSource.readSnapshot();
    expect(rawSnapshot, isNotNull, reason: 'snapshot must round-trip');
    expect(
      (rawSnapshot!['deletedTaskIds'] as List).map((id) => '$id'),
      contains('personal-1'),
      reason: 'the tombstone must be persisted with the snapshot',
    );

    final restarted = TodoRepository.seeded(localDataSource: restoredSource);
    await restarted.hydrate();

    expect(restarted.taskById('personal-1'), isNull,
        reason: 'the deletion must come from disk — the in-memory seed '
            'still contains personal-1, so this can only be restored state');
    expect(restarted.taskById('personal-2'), isNotNull,
        reason: 'untouched tasks must be restored too');
    expect(restarted.hasPendingDeletes, isTrue,
        reason: 'deletion tombstones must survive the restart so they can '
            'still replay against Firestore later');
    expect(restarted.lastSyncError, isNull,
        reason: 'a clean cache restore must not report an error');
  });

  test('the local data source reports a corrupt cache instead of throwing',
      () async {
    final box = await Hive.openBox<dynamic>(HiveAppStorage.boxName);
    await box.put(TodoLocalDataSource.snapshotKey, 'not-a-map');

    final source = TodoLocalDataSource(HiveAppStorage(box));
    expect(await source.readSnapshot(), isNull,
        reason: 'malformed cache must be ignored, not crash hydration');
  });

  test('openAppStorage() falls back to memory when the platform path is '
      'unavailable', () async {
    // In the test harness path_provider has no platform channel, so
    // initFlutter() fails: the fallback must keep the local-first app
    // starting instead of crashing. On a real device the same call returns
    // the Hive-backed implementation (that device-only branch is covered by
    // the two tests above through the identical openBox code path).
    final storage = await openAppStorage();
    expect(storage, isA<MemoryAppStorage>());
  });
}

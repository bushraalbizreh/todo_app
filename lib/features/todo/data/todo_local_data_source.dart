import '../../../core/storage/app_storage.dart';

class TodoLocalDataSource {
  const TodoLocalDataSource(this._storage);

  static const String snapshotKey = 'todos.snapshot';

  final AppStorage _storage;

  Future<Map<String, dynamic>?> readSnapshot() async {
    final value = await _storage.read<Object>(snapshotKey);
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  Future<void> writeSnapshot(Map<String, dynamic> snapshot) =>
      _storage.write(snapshotKey, snapshot);

  Future<void> clear() => _storage.delete(snapshotKey);
}

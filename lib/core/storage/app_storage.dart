import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Small persistence boundary used by repositories and settings cubits.
///
/// UI and state-management code never talks to Hive directly. The in-memory
/// implementation keeps widgets and unit tests deterministic when a platform
/// storage path is not available.
abstract interface class AppStorage {
  Future<T?> read<T>(String key);

  Future<void> write(String key, Object value);

  Future<void> delete(String key);
}

class MemoryAppStorage implements AppStorage {
  final Map<String, Object> _values = <String, Object>{};

  @override
  Future<T?> read<T>(String key) async => _values[key] as T?;

  @override
  Future<void> write(String key, Object value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}

class HiveAppStorage implements AppStorage {
  const HiveAppStorage(this._box);

  static const String boxName = 'to_do_app_cache';

  final Box<dynamic> _box;

  @override
  Future<T?> read<T>(String key) async => _box.get(key) as T?;

  @override
  Future<void> write(String key, Object value) => _box.put(key, value);

  @override
  Future<void> delete(String key) => _box.delete(key);
}

Future<AppStorage> openAppStorage() async {
  try {
    await Hive.initFlutter();
    final box = Hive.isBoxOpen(HiveAppStorage.boxName)
        ? Hive.box<dynamic>(HiveAppStorage.boxName)
        : await Hive.openBox<dynamic>(HiveAppStorage.boxName);
    return HiveAppStorage(box);
  } catch (error) {
    // A storage failure should not prevent the local-first app from starting.
    debugPrint('Falling back to in-memory storage: $error');
    return MemoryAppStorage();
  }
}

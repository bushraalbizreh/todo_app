import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/todo/data/todo_local_data_source.dart';
import '../features/todo/data/todo_remote_data_source.dart';
import '../models/todo_models.dart';

/// Repository for task data. The UI only observes this abstraction; cache and
/// Firebase details are intentionally kept behind data sources.
class TodoRepository extends ChangeNotifier {
  TodoRepository._({
    required List<TodoList> lists,
    required Map<String, List<TodoTask>> tasks,
    required int completedToday,
    required int focusStreak,
    TodoLocalDataSource? localDataSource,
    TodoRemoteDataSource? remoteDataSource,
    String userId = 'guest',
  }) : _lists = lists,
       _tasks = tasks,
       _completedToday = completedToday,
       _focusStreak = focusStreak,
       _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _userId = userId;

  factory TodoRepository.seeded({
    TodoLocalDataSource? localDataSource,
    TodoRemoteDataSource? remoteDataSource,
    String userId = 'guest',
  }) {
    return TodoRepository._(
      lists: _seedLists(),
      tasks: _seedTasks(),
      completedToday: 18,
      focusStreak: 5,
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      userId: userId,
    );
  }

  final List<TodoList> _lists;
  final Map<String, List<TodoTask>> _tasks;
  final TodoLocalDataSource? _localDataSource;
  final TodoRemoteDataSource? _remoteDataSource;
  int _completedToday;
  int _focusStreak;
  String _userId;
  bool _isHydrating = false;
  bool _isSyncing = false;
  bool _isPushing = false;
  bool _pushQueued = false;
  Object? _lastSyncError;
  bool _hasSyncedOnce = false;

  /// Local mutations counter. It detects edits that happen while a remote
  /// fetch is in flight so a stale remote snapshot can never overwrite newer
  /// local state (which would resurrect a just-deleted item).
  int _generation = 0;

  /// Tombstones for items deleted since the last successful push. They are
  /// part of the local snapshot, so a deletion survives a restart (even an
  /// offline one) and is replayed against Firestore instead of the item
  /// coming back on the next fetch.
  final Set<String> _deletedListIds = <String>{};
  final Set<String> _deletedTaskIds = <String>{};

  List<TodoList> get lists => List.unmodifiable(_lists);

  int get completedToday => _completedToday;

  int get focusStreak => _focusStreak;

  bool get isHydrating => _isHydrating;

  bool get isSyncing => _isSyncing;

  /// Whether a remote backend is usable for the *current* user.
  ///
  /// Unauthenticated "guest" sessions are intentionally local-only: writing
  /// them to the shared `users/guest` path would merge every anonymous
  /// user's data into one public bucket, and `firestore.rules` denies that
  /// path for everyone. Guests therefore sync nothing and see "Working
  /// offline" instead of a permanent permission error.
  bool get hasRemoteDataSource =>
      (_remoteDataSource?.isAvailable ?? false) && _userId != 'guest';

  /// True after at least one real successful remote operation (fetch or
  /// push). The UI may only claim "synced" once this holds.
  bool get hasSyncedOnce => _hasSyncedOnce;

  Object? get lastSyncError => _lastSyncError;

  /// Whether deletions are still waiting to reach the remote store.
  bool get hasPendingDeletes =>
      _deletedListIds.isNotEmpty || _deletedTaskIds.isNotEmpty;

  int get activeTaskCount =>
      _lists.fold(0, (total, list) => total + activeTaskCountForList(list.id));

  List<TodoTask> get allTasks =>
      List.unmodifiable(_tasks.values.expand((tasks) => tasks));

  /// Total tasks in a list (including completed)
  int taskCountForList(String listId) {
    return _tasks[listId]?.length ?? 0;
  }

  /// Active (incomplete) tasks in a list
  int activeTaskCountForList(String listId) {
    final tasks = _tasks[listId];
    if (tasks == null) return 0;
    return tasks.where((task) => !task.isCompleted).length;
  }

  /// Completed tasks in a list
  int completedTaskCountForList(String listId) {
    final tasks = _tasks[listId];
    if (tasks == null) return 0;
    return tasks.where((task) => task.isCompleted).length;
  }

  /// Progress percentage for a list (completed / total)
  double progressForList(String listId) {
    final total = taskCountForList(listId);
    if (total == 0) return 0.0;
    return completedTaskCountForList(listId) / total;
  }

  List<TodoTask> tasksForList(String listId, {bool includeCompleted = true}) {
    final tasks = _tasks[listId] ?? const <TodoTask>[];
    final filtered = includeCompleted
        ? tasks
        : tasks.where((task) => !task.isCompleted);
    return List.unmodifiable(filtered);
  }

  /// Tasks due today across all lists (incomplete, with dueLabel "Today" or priority high/urgent)
  List<TodoTask> get todaysTasks {
    return allTasks
        .where((task) =>
            !task.isCompleted &&
            (task.dueLabel.toLowerCase() == 'today' ||
                task.priority == TaskPriority.high ||
                task.priority == TaskPriority.urgent))
        .toList(growable: false);
  }

  TodoList? listById(String listId) {
    for (final list in _lists) {
      if (list.id == listId) return list;
    }
    return null;
  }

  TodoList? listByName(String name) {
    for (final list in _lists) {
      if (list.name == name) return list;
    }
    return null;
  }

  TodoTask? taskById(String taskId) {
    for (final tasks in _tasks.values) {
      for (final task in tasks) {
        if (task.id == taskId) return task;
      }
    }
    return null;
  }

  Future<void> hydrate() async {
    if (_isHydrating) return;
    _isHydrating = true;
    notifyListeners();
    try {
      final cached = await _localDataSource?.readSnapshot();
      if (cached != null) {
        try {
          _applySnapshot(cached);
        } catch (error) {
          _lastSyncError = error;
        }
      }
      _isHydrating = false;
      notifyListeners();
      if (hasRemoteDataSource) {
        await sync();
      }
    } catch (error) {
      _lastSyncError = error;
      _isHydrating = false;
      notifyListeners();
    }
  }

  Future<void> sync() async {
    final remote = _remoteDataSource;
    if (remote == null ||
        !remote.isAvailable ||
        _userId == 'guest' ||
        _isSyncing) {
      return;
    }
    _isSyncing = true;
    final generationAtStart = _generation;
    _lastSyncError = null;
    notifyListeners();
    try {
      final remoteSnapshot = await remote.fetchSnapshot(_userId);
      if (remoteSnapshot == null) {
        // The remote store is empty: upload the local snapshot.
        await _pushRemote();
      } else if (generationAtStart != _generation) {
        // A mutation happened while the fetch was in flight. The local state
        // is newer than the fetched snapshot, so it wins: push it instead of
        // overwriting it (which would resurrect a just-deleted item).
        _pushQueued = true;
      } else {
        _applySnapshot(<String, dynamic>{
          'lists': remoteSnapshot.lists,
          'tasks': remoteSnapshot.tasks,
          'completedToday': _completedToday,
          'focusStreak': _focusStreak,
        });
        await _persistLocal();
        if (hasPendingDeletes) {
          // Deletions that never reached the remote store (offline delete,
          // then restart) are replayed now, so deleted documents cannot
          // resurface on this or any other device.
          _pushQueued = true;
        }
      }
    } catch (error) {
      _lastSyncError = error;
    } finally {
      _isSyncing = false;
      // The fetch completed against the real backend without an error:
      // from now on "Synced just now" is a truthful statement.
      if (_lastSyncError == null) {
        _hasSyncedOnce = true;
      }
      final shouldPush = _pushQueued;
      _pushQueued = false;
      notifyListeners();
      if (shouldPush) unawaited(_pushRemote());
    }
  }

  void setUserId(String userId) {
    if (userId.isEmpty || userId == _userId) return;
    // Replay pending local changes — including deletions — against the
    // account that owns them before retargeting, so a tombstone can never
    // delete another account's documents. Tombstones are dropped afterwards
    // regardless of the outcome: they belong to the previous account.
    unawaited(
      _pushRemote().whenComplete(() {
        _deletedListIds.clear();
        _deletedTaskIds.clear();
        _pushQueued = false;
        _userId = userId;
        unawaited(sync());
      }),
    );
  }

  void addList(TodoList list) {
    // Re-creating an id that was previously deleted cancels its tombstone:
    // the document must exist again.
    _deletedListIds.remove(list.id);
    _lists.add(list);
    _tasks[list.id] = <TodoTask>[];
    _changed();
  }

  void updateList(TodoList updated) {
    final index = _lists.indexWhere((list) => list.id == updated.id);
    if (index == -1) return;
    _lists[index] = updated;
    _changed();
  }

  void removeList(String listId) {
    final index = _lists.indexWhere((list) => list.id == listId);
    if (index == -1) return;
    // Tombstone the list and everything in it so the deletion is replayed
    // against Firestore even if this happens offline or before a restart.
    _deletedListIds.add(listId);
    _deletedTaskIds.addAll(
      (_tasks[listId] ?? const <TodoTask>[]).map((task) => task.id),
    );
    _lists.removeAt(index);
    _tasks.remove(listId);
    _changed();
  }

  void addTask(TodoTask task) {
    final tasks = _tasks.putIfAbsent(task.listId, () => <TodoTask>[]);
    if (tasks.any((existing) => existing.id == task.id)) return;
    _deletedTaskIds.remove(task.id);
    tasks.add(task);
    _changed();
  }

  void updateTask(TodoTask updated) {
    final oldTask = taskById(updated.id);
    if (oldTask == null) return;
    final oldListTasks = _tasks[oldTask.listId];
    if (oldListTasks == null) return;
    final oldIndex = oldListTasks.indexWhere((task) => task.id == updated.id);
    if (oldIndex == -1) return;

    final movedList = oldTask.listId != updated.listId;
    final completionChanged = oldTask.isCompleted != updated.isCompleted;

    if (movedList) {
      oldListTasks.removeAt(oldIndex);
      final newTasks = _tasks.putIfAbsent(updated.listId, () => <TodoTask>[]);
      newTasks.add(updated);
    } else {
      oldListTasks[oldIndex] = updated;
    }

    if (completionChanged) {
      if (updated.isCompleted) {
        _completedToday += 1;
      } else {
        _completedToday = (_completedToday - 1).clamp(0, 9999).toInt();
      }
    }
    _changed();
  }

  void toggleTask(String taskId) {
    final task = taskById(taskId);
    if (task == null) return;
    updateTask(
      task.copyWith(
        isCompleted: !task.isCompleted,
        isDimmed: !task.isCompleted,
      ),
    );
  }

  void removeTask(String taskId) {
    for (final entry in _tasks.entries) {
      final index = entry.value.indexWhere((task) => task.id == taskId);
      if (index == -1) continue;
      final task = entry.value.removeAt(index);
      _deletedTaskIds.add(taskId);
      if (task.isCompleted) {
        _completedToday = (_completedToday - 1).clamp(0, 9999).toInt();
      }
      _changed();
      return;
    }
  }

  void clearCompleted({String? listId}) {
    var changed = false;
    final entries = listId == null
        ? _tasks.entries
        : _tasks.entries.where((entry) => entry.key == listId);
    for (final entry in entries) {
      final removed = entry.value.where((task) => task.isCompleted).toList();
      if (removed.isEmpty) continue;
      entry.value.removeWhere((task) => task.isCompleted);
      _deletedTaskIds.addAll(removed.map((task) => task.id));
      changed = true;
    }
    if (changed) {
      _completedToday = 0;
      _changed();
    }
  }

  void reorderTasks(String listId, int oldIndex, int newIndex) {
    final tasks = _tasks[listId];
    if (tasks == null || oldIndex < 0 || oldIndex >= tasks.length) return;
    if (newIndex > oldIndex) newIndex -= 1;
    newIndex = newIndex.clamp(0, tasks.length - 1);
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);
    _changed();
  }

  void _changed() {
    _generation += 1;
    notifyListeners();
    unawaited(_persistLocal());
    if (hasRemoteDataSource) {
      unawaited(_pushRemote());
    } else if (kDebugMode) {
      debugPrint(
        '[SYNC] mutation stored locally only — no remote attempt '
        '(remote=${_remoteDataSource?.isAvailable == true ? 'ready' : 'unavailable'}, '
        'userId=$_userId)',
      );
    }
  }

  Future<void> _persistLocal() async {
    final local = _localDataSource;
    if (local == null) return;
    try {
      await local.writeSnapshot(_snapshot());
      // Diagnostic A: the local (Hive/memory) save really happened.
      if (kDebugMode) {
        debugPrint(
          '[SYNC] A) local cache save SUCCEEDED '
          '(${_lists.length} lists, ${allTasks.length} tasks)',
        );
      }
    } catch (error) {
      // A failed cache write must be visible to the UI, not swallowed.
      if (kDebugMode) {
        debugPrint('[SYNC] A) local cache save FAILED: $error');
      }
      _lastSyncError = error;
      notifyListeners();
    }
  }

  Future<void> _pushRemote() async {
    if (_isPushing) {
      // Pushes are serialized: remember to run again with the newest state
      // once the in-flight push finishes, so a mutation is never dropped.
      _pushQueued = true;
      return;
    }
    final remote = _remoteDataSource;
    if (remote == null || !remote.isAvailable || _userId == 'guest') {
      // Local-only mode (no Firebase, or no signed-in uid yet): say so
      // instead of pretending a remote write ran.
      if (kDebugMode) {
        debugPrint(
          '[SYNC] remote push SKIPPED — local-only '
          '(remote=${remote != null && remote.isAvailable ? 'ready' : 'unavailable'}, '
          'userId=$_userId)',
        );
      }
      return;
    }
    _isPushing = true;
    try {
      await remote.pushSnapshot(
        userId: _userId,
        lists: _lists.map(_listToMap).toList(growable: false),
        tasks: allTasks.map(_taskToMap).toList(growable: false),
        deletedListIds: _deletedListIds.toList(growable: false),
        deletedTaskIds: _deletedTaskIds.toList(growable: false),
      );
      // The remote store applied the snapshot including every deletion, so
      // the tombstones can be dropped from the local snapshot.
      _hasSyncedOnce = true;
      _lastSyncError = null;
      if (_deletedListIds.isNotEmpty || _deletedTaskIds.isNotEmpty) {
        _deletedListIds.clear();
        _deletedTaskIds.clear();
        await _persistLocal();
      }
    } catch (error) {
      // Surface the failure: the UI must never claim the save succeeded.
      _lastSyncError = error;
    } finally {
      _isPushing = false;
      final shouldPush = _pushQueued;
      _pushQueued = false;
      notifyListeners();
      if (shouldPush) unawaited(_pushRemote());
    }
  }

  Map<String, dynamic> _snapshot() {
    return <String, dynamic>{
      'lists': _lists.map(_listToMap).toList(growable: false),
      'tasks': allTasks.map(_taskToMap).toList(growable: false),
      'completedToday': _completedToday,
      'focusStreak': _focusStreak,
      // Tombstones travel with the snapshot so a deletion survives a restart
      // (including offline) instead of being resurrected from cache/remote.
      'deletedListIds': _deletedListIds.toList(growable: false),
      'deletedTaskIds': _deletedTaskIds.toList(growable: false),
    };
  }

  void _applySnapshot(Map<String, dynamic> snapshot) {
    final rawLists = snapshot['lists'];
    final rawTasks = snapshot['tasks'];
    if (rawLists is! List || rawTasks is! List) {
      throw const FormatException('Invalid todo snapshot');
    }
    // Tombstones are local knowledge: a snapshot fetched from Firestore does
    // not carry them, so they are merged (never dropped) and used to filter
    // the incoming data — a pending deletion always wins over a fetch.
    final deletedLists = snapshot['deletedListIds'];
    if (deletedLists is List) {
      _deletedListIds.addAll(deletedLists.map((id) => '$id'));
    }
    final deletedTasks = snapshot['deletedTaskIds'];
    if (deletedTasks is List) {
      _deletedTaskIds.addAll(deletedTasks.map((id) => '$id'));
    }
    final nextLists = rawLists
        .whereType<Map>()
        .map((value) => _listFromMap(Map<String, dynamic>.from(value)))
        .where((list) => !_deletedListIds.contains(list.id))
        .toList();
    // A snapshot that holds tasks without a single list is malformed: keep
    // the current state instead of wiping it. An empty snapshot with no tasks
    // is a legitimate "everything was deleted" state and must be applied.
    if (nextLists.isEmpty && rawTasks.isNotEmpty) return;
    final nextTasks = <String, List<TodoTask>>{
      for (final list in nextLists) list.id: <TodoTask>[],
    };
    for (final raw in rawTasks.whereType<Map>()) {
      final task = _taskFromMap(Map<String, dynamic>.from(raw));
      if (_deletedTaskIds.contains(task.id)) continue;
      // Drop tasks whose list is gone so they can never reappear as orphans.
      if (!nextTasks.containsKey(task.listId)) continue;
      nextTasks[task.listId]!.add(task);
    }
    _lists
      ..clear()
      ..addAll(nextLists);
    _tasks
      ..clear()
      ..addAll(nextTasks);
    _completedToday = _readInt(snapshot['completedToday'], fallback: 18);
    _focusStreak = _readInt(snapshot['focusStreak'], fallback: 5);
  }

  Map<String, dynamic> _listToMap(TodoList list) {
    return <String, dynamic>{
      'id': list.id,
      'name': list.name,
      'subtitle': list.subtitle,
      'subtitleColor': list.subtitleColor?.toARGB32(),
      'countLabel': list.countLabel,
      'icon': _iconKey(list.icon),
      'accent': list.accent.toARGB32(),
      'softBackground': list.softBackground.toARGB32(),
      'softBorder': list.softBorder.toARGB32(),
      'previewIcon': _iconKey(list.previewIcon),
      'previewTitle': list.previewTitle,
    };
  }

  TodoList _listFromMap(Map<String, dynamic> map) {
    final accent = _readColor(map['accent'], const Color(0xFFF43F5E));
    return TodoList(
      id: '${map['id'] ?? ''}',
      name: '${map['name'] ?? ''}',
      subtitle: '${map['subtitle'] ?? ''}',
      subtitleColor: map['subtitleColor'] == null
          ? null
          : _readColor(map['subtitleColor'], const Color(0xFF6366F1)),
      countLabel: '${map['countLabel'] ?? 'tasks'}',
      icon: _readIcon(map['icon'], null, null, Icons.list_alt_rounded),
      accent: accent,
      softBackground: _readColor(
        map['softBackground'],
        const Color(0xFFFFF1F2),
      ),
      softBorder: _readColor(map['softBorder'], const Color(0xFFFFE4E6)),
      previewIcon: _readIcon(
        map['previewIcon'],
        null,
        null,
        Icons.task_alt_rounded,
      ),
      previewTitle: '${map['previewTitle'] ?? ''}',
    );
  }

  Map<String, dynamic> _taskToMap(TodoTask task) {
    return <String, dynamic>{
      'id': task.id,
      'listId': task.listId,
      'title': task.title,
      'dueLabel': task.dueLabel,
      'priority': task.priority.name,
      'tone': task.tone.name,
      'trailingIcon': task.trailingIcon == null
          ? null
          : _iconKey(task.trailingIcon!),
      'isDimmed': task.isDimmed,
      'isCompleted': task.isCompleted,
      'initialSwipeOffset': task.initialSwipeOffset,
    };
  }

  TodoTask _taskFromMap(Map<String, dynamic> map) {
    final priority = TaskPriority.values.firstWhere(
      (value) => value.name == map['priority'],
      orElse: () => TaskPriority.medium,
    );
    final tone = TaskTone.values.firstWhere(
      (value) => value.name == map['tone'],
      orElse: () => TaskVisualStyle.toneFor(priority),
    );
    return TodoTask(
      id: '${map['id'] ?? ''}',
      listId: '${map['listId'] ?? 'personal'}',
      title: '${map['title'] ?? ''}',
      dueLabel: '${map['dueLabel'] ?? ''}',
      priority: priority,
      tone: tone,
      trailingIcon: map['trailingIcon'] == null
          ? null
          : _readIcon(map['trailingIcon'], null, null, Icons.circle_outlined),
      isDimmed: map['isDimmed'] == true,
      isCompleted: map['isCompleted'] == true,
      initialSwipeOffset: _readDouble(map['initialSwipeOffset']),
    );
  }

  IconData _readIcon(
    Object? iconName,
    Object? fontFamily,
    Object? fontPackage,
    IconData fallback,
  ) {
    if (iconName is! String) return fallback;
    return _iconRegistry[iconName] ?? fallback;
  }

  static String _iconKey(IconData icon) => _iconRegistry.entries
      .firstWhere(
        (entry) => entry.value.codePoint == icon.codePoint,
        orElse: () => const MapEntry<String, IconData>('unknown', Icons.circle),
      )
      .key;

  Color _readColor(Object? value, Color fallback) {
    if (value is num) return Color(value.toInt());
    if (value is String) {
      return Color(int.tryParse(value) ?? fallback.toARGB32());
    }
    return fallback;
  }

  int _readInt(Object? value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  double _readDouble(Object? value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? fallback;
  }
}

/// Icons that may be persisted to the local/remote cache. Storing a stable
/// name instead of a raw code point keeps cached payloads portable and lets
/// the compiler verify every value.
const Map<String, IconData> _iconRegistry = <String, IconData>{
  'person': Icons.person_outline_rounded,
  'work': Icons.work_outline_rounded,
  'shopping': Icons.shopping_bag_outlined,
  'book': Icons.menu_book_outlined,
  'idea': Icons.lightbulb_outline_rounded,
  'list': Icons.list_alt_rounded,
  'task': Icons.task_alt_rounded,
  'priority': Icons.priority_high_rounded,
  'schedule': Icons.schedule_rounded,
  'store': Icons.storefront_outlined,
  'bookmark': Icons.bookmark_outline_rounded,
  'explore': Icons.explore_outlined,
  'calendar': Icons.calendar_today_outlined,
  'basket': Icons.shopping_basket_outlined,
  'circle': Icons.circle_outlined,
  'unknown': Icons.circle_outlined,
};

List<TodoList> _seedLists() {
  return <TodoList>[
    const TodoList(
      id: 'personal',
      name: 'Personal',
      subtitle: 'Updated 10m ago',
      countLabel: 'tasks',
      icon: Icons.person_outline_rounded,
      accent: Color(0xFFF43F5E),
      softBackground: Color(0xFFFFF1F2),
      softBorder: Color(0xFFFFE4E6),
      previewIcon: Icons.priority_high_rounded,
      previewTitle: 'Pick up prescription & renewal docs',
    ),
    const TodoList(
      id: 'work',
      name: 'Work & Projects',
      subtitle: '4 due by 5 PM',
      subtitleColor: Color(0xFF6366F1),
      countLabel: 'tasks',
      icon: Icons.work_outline_rounded,
      accent: Color(0xFF6366F1),
      softBackground: Color(0xFFEEF2FF),
      softBorder: Color(0xFFE0E7FF),
      previewIcon: Icons.schedule_rounded,
      previewTitle: 'Q3 Design review deck presentation',
    ),
    const TodoList(
      id: 'shopping',
      name: 'Shopping & Errands',
      subtitle: 'Weekly groceries',
      countLabel: 'tasks',
      icon: Icons.shopping_bag_outlined,
      accent: Color(0xFF14B8A6),
      softBackground: Color(0xFFF0FDFA),
      softBorder: Color(0xFFCCFBF1),
      previewIcon: Icons.storefront_outlined,
      previewTitle: 'Organic almond milk, coffee beans',
    ),
    const TodoList(
      id: 'books',
      name: 'Books & Learning',
      subtitle: 'Reading goal: 20pgs/day',
      countLabel: 'tasks',
      icon: Icons.menu_book_outlined,
      accent: Color(0xFFF59E0B),
      softBackground: Color(0xFFFFFBEB),
      softBorder: Color(0xFFFEF3C7),
      previewIcon: Icons.bookmark_outline_rounded,
      previewTitle: 'Finish Ch. 4: Systems & Entropy',
    ),
    const TodoList(
      id: 'ideas',
      name: 'Ideas & Someday',
      subtitle: 'Backlog exploration',
      countLabel: 'ideas',
      icon: Icons.lightbulb_outline_rounded,
      accent: Color(0xFF0EA5E9),
      softBackground: Color(0xFFF0F9FF),
      softBorder: Color(0xFFE0F2FE),
      previewIcon: Icons.explore_outlined,
      previewTitle: 'Solo bikepacking route planning in Alps',
    ),
  ];
}

Map<String, List<TodoTask>> _seedTasks() {
  final tasks = <String, List<TodoTask>>{
    'personal': <TodoTask>[
      const TodoTask(
        id: 'personal-1',
        listId: 'personal',
        title: 'Submit Q3 tax report & invoices',
        dueLabel: 'Priority 1',
        priority: TaskPriority.urgent,
        tone: TaskTone.coral,
      ),
      const TodoTask(
        id: 'personal-2',
        listId: 'personal',
        title: 'Call contractor about kitchen tiles',
        dueLabel: 'Today',
        priority: TaskPriority.high,
        tone: TaskTone.orange,
      ),
      const TodoTask(
        id: 'personal-3',
        listId: 'personal',
        title: 'Design sprint retro review slides',
        dueLabel: 'Swiping',
        priority: TaskPriority.high,
        tone: TaskTone.orange,
        isDimmed: true,
        initialSwipeOffset: 96,
      ),
      const TodoTask(
        id: 'personal-4',
        listId: 'personal',
        title: 'Renew passport before international trip',
        dueLabel: '3 days',
        priority: TaskPriority.medium,
        tone: TaskTone.amber,
      ),
      const TodoTask(
        id: 'personal-5',
        listId: 'personal',
        title: 'Order birthday gift for Sarah',
        dueLabel: 'This weekend',
        priority: TaskPriority.medium,
        tone: TaskTone.gold,
      ),
      const TodoTask(
        id: 'personal-6',
        listId: 'personal',
        title: 'Schedule dentist annual checkup',
        dueLabel: '',
        priority: TaskPriority.low,
        tone: TaskTone.sand,
        trailingIcon: Icons.calendar_today_outlined,
      ),
      const TodoTask(
        id: 'personal-7',
        listId: 'personal',
        title: 'Pick up organic oat milk & coffee beans',
        dueLabel: '',
        priority: TaskPriority.low,
        tone: TaskTone.slate,
        trailingIcon: Icons.shopping_basket_outlined,
      ),
      const TodoTask(
        id: 'personal-8',
        listId: 'personal',
        title: 'Water the balcony ferns',
        dueLabel: 'Someday',
        priority: TaskPriority.someday,
        tone: TaskTone.pearl,
      ),
    ],
    'work': <TodoTask>[
      _seedTask(
        'work-1',
        'work',
        'Review Q3 design system proposal',
        'Today',
        TaskPriority.high,
        TaskTone.orange,
      ),
      _seedTask(
        'work-2',
        'work',
        'Prepare client invoice summaries',
        'Today',
        TaskPriority.urgent,
        TaskTone.coral,
      ),
      _seedTask(
        'work-3',
        'work',
        'Share roadmap with the product team',
        'Tomorrow',
        TaskPriority.medium,
        TaskTone.amber,
      ),
      _seedTask(
        'work-4',
        'work',
        'Book research interviews',
        'This week',
        TaskPriority.medium,
        TaskTone.gold,
      ),
      _seedTask(
        'work-5',
        'work',
        'Polish portfolio case study',
        'Next week',
        TaskPriority.low,
        TaskTone.slate,
      ),
      _seedTask(
        'work-6',
        'work',
        'Outline quarterly planning workshop',
        'Next week',
        TaskPriority.low,
        TaskTone.sand,
      ),
      _seedTask(
        'work-7',
        'work',
        'Review accessibility feedback',
        'Friday',
        TaskPriority.high,
        TaskTone.orange,
      ),
      _seedTask(
        'work-8',
        'work',
        'Send project recap to stakeholders',
        'Friday',
        TaskPriority.medium,
        TaskTone.amber,
      ),
      _seedTask(
        'work-9',
        'work',
        'Audit analytics events',
        'Next month',
        TaskPriority.low,
        TaskTone.slate,
      ),
      _seedTask(
        'work-10',
        'work',
        'Brainstorm new workflow concepts',
        'Next month',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
      _seedTask(
        'work-11',
        'work',
        'Update portfolio navigation',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
      _seedTask(
        'work-12',
        'work',
        'Schedule design sync',
        'Today',
        TaskPriority.high,
        TaskTone.orange,
      ),
      _seedTask(
        'work-13',
        'work',
        'Document content guidelines',
        'This month',
        TaskPriority.medium,
        TaskTone.amber,
      ),
      _seedTask(
        'work-14',
        'work',
        'Archive old project files',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
    ],
    'shopping': <TodoTask>[
      _seedTask(
        'shopping-1',
        'shopping',
        'Buy organic almond milk',
        'Today',
        TaskPriority.high,
        TaskTone.orange,
      ),
      _seedTask(
        'shopping-2',
        'shopping',
        'Pick up coffee beans',
        'Today',
        TaskPriority.medium,
        TaskTone.amber,
      ),
      _seedTask(
        'shopping-3',
        'shopping',
        'Restock pantry staples',
        'This weekend',
        TaskPriority.medium,
        TaskTone.gold,
      ),
      _seedTask(
        'shopping-4',
        'shopping',
        'Return unused home supplies',
        'This week',
        TaskPriority.low,
        TaskTone.slate,
      ),
      _seedTask(
        'shopping-5',
        'shopping',
        'Pick up fresh flowers',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
    ],
    'books': <TodoTask>[
      _seedTask(
        'books-1',
        'books',
        'Finish Ch. 4: Systems & Entropy',
        'Today',
        TaskPriority.high,
        TaskTone.orange,
      ),
      _seedTask(
        'books-2',
        'books',
        'Read 20 pages of Deep Work',
        'This week',
        TaskPriority.medium,
        TaskTone.amber,
      ),
      _seedTask(
        'books-3',
        'books',
        'Save three new essay ideas',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
    ],
    'ideas': <TodoTask>[
      _seedTask(
        'ideas-1',
        'ideas',
        'Plan a solo bikepacking route',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
      _seedTask(
        'ideas-2',
        'ideas',
        'Start a neighborhood garden',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
      _seedTask(
        'ideas-3',
        'ideas',
        'Create a monthly reading ritual',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
      _seedTask(
        'ideas-4',
        'ideas',
        'Explore a weekend pottery class',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
      _seedTask(
        'ideas-5',
        'ideas',
        'Learn basic conversational Japanese',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
      _seedTask(
        'ideas-6',
        'ideas',
        'Photograph the city at dawn',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
      _seedTask(
        'ideas-7',
        'ideas',
        'Build a small writing corner',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
      _seedTask(
        'ideas-8',
        'ideas',
        'Plan a seasonal recipe swap',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
      _seedTask(
        'ideas-9',
        'ideas',
        'Sketch a home library layout',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
      _seedTask(
        'ideas-10',
        'ideas',
        'Research analog productivity tools',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
      _seedTask(
        'ideas-11',
        'ideas',
        'Plan a long weekend with friends',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
      _seedTask(
        'ideas-12',
        'ideas',
        'Keep a gratitude jar',
        'Someday',
        TaskPriority.someday,
        TaskTone.pearl,
      ),
    ],
  };

  for (var index = 1; index <= 18; index++) {
    final listId = index <= 6 ? 'work' : (index <= 12 ? 'shopping' : 'books');
    tasks[listId]!.add(
      _seedTask(
        'completed-$index',
        listId,
        'Completed task $index',
        'Today',
        TaskPriority.low,
        TaskTone.slate,
        isCompleted: true,
      ),
    );
  }
  return tasks;
}

TodoTask _seedTask(
  String id,
  String listId,
  String title,
  String dueLabel,
  TaskPriority priority,
  TaskTone tone, {
  bool isCompleted = false,
}) {
  return TodoTask(
    id: id,
    listId: listId,
    title: title,
    dueLabel: dueLabel,
    priority: priority,
    tone: tone,
    isCompleted: isCompleted,
    isDimmed: isCompleted,
  );
}

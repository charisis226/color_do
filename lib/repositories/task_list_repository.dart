import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class TaskListRepository {
  static const String _boxName = 'task_lists';
  late Box<TaskList> _box;
  final _uuid = const Uuid();

  Future<void> init() async {
    _box = await Hive.openBox<TaskList>(_boxName);
    if (_box.isEmpty) {
      await _createDefaultList();
    }
  }

  Future<void> _createDefaultList() async {
    final defaultList = TaskList(
      id: _uuid.v4(),
      name: '내 할 일',
      colorValue: 0xFF0078D4,
      iconName: 'list',
      isDefault: true,
      createdAt: DateTime.now(),
      sortOrder: 0,
    );
    await _box.put(defaultList.id, defaultList);
  }

  List<TaskList> getAllLists() {
    final lists = _box.values.toList();
    lists.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return lists;
  }

  TaskList? getListById(String id) {
    try {
      return _box.values.firstWhere((list) => list.id == id);
    } catch (_) {
      return null;
    }
  }

  TaskList? getDefaultList() {
    try {
      return _box.values.firstWhere((list) => list.isDefault);
    } catch (_) {
      return null;
    }
  }

  Future<TaskList> addList({
    required String name,
    required int colorValue,
    String iconName = 'list',
  }) async {
    final maxSortOrder = _box.values.isEmpty
        ? 0
        : _box.values.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b);

    final list = TaskList(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
      iconName: iconName,
      createdAt: DateTime.now(),
      sortOrder: maxSortOrder + 1,
    );
    await _box.put(list.id, list);
    return list;
  }

  Future<void> updateList(TaskList list) async {
    await _box.put(list.id, list);
  }

  Future<void> deleteList(String id) async {
    final list = getListById(id);
    if (list != null && !list.isDefault) {
      await _box.delete(id);
    }
  }

  Future<void> reorderLists(List<TaskList> lists) async {
    for (int i = 0; i < lists.length; i++) {
      final updatedList = lists[i].copyWith(sortOrder: i);
      await _box.put(updatedList.id, updatedList);
    }
  }
}

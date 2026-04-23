import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class TaskRepository {
  static const String _boxName = 'tasks';
  late Box<Task> _box;
  final _uuid = const Uuid();

  Future<void> init() async {
    _box = await Hive.openBox<Task>(_boxName);
  }

  List<Task> getAllTasks() {
    return _box.values.toList();
  }

  List<Task> getTasksByListId(String listId) {
    return _box.values.where((task) => task.listId == listId).toList();
  }

  List<Task> getImportantTasks() {
    return _box.values
        .where((task) => task.isImportant && !task.isCompleted)
        .toList();
  }

  List<Task> getTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return _box.values.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(
            today.subtract(const Duration(seconds: 1)),
          ) &&
          task.dueDate!.isBefore(tomorrow);
    }).toList();
  }

  List<Task> getPlannedTasks() {
    return _box.values
        .where((task) => task.dueDate != null && !task.isCompleted)
        .toList();
  }

  Task? getTaskById(String id) {
    try {
      return _box.values.firstWhere((task) => task.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Task> addTask({
    required String title,
    String? note,
    required String listId,
    DateTime? dueDate,
    bool isImportant = false,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      note: note,
      listId: listId,
      dueDate: dueDate,
      isImportant: isImportant,
      createdAt: DateTime.now(),
    );
    await _box.put(task.id, task);
    return task;
  }

  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleComplete(String id) async {
    final task = getTaskById(id);
    if (task != null) {
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
        clearCompletedAt: task.isCompleted,
      );
      await updateTask(updatedTask);
    }
  }

  Future<void> toggleImportant(String id) async {
    final task = getTaskById(id);
    if (task != null) {
      final updatedTask = task.copyWith(isImportant: !task.isImportant);
      await updateTask(updatedTask);
    }
  }

  Future<void> moveTask(String taskId, String newListId) async {
    final task = getTaskById(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(listId: newListId);
      await updateTask(updatedTask);
    }
  }
}

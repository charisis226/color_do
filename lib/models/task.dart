import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? note;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final bool isImportant;

  @HiveField(5)
  final DateTime? dueDate;

  @HiveField(6)
  final String listId;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    this.note,
    this.isCompleted = false,
    this.isImportant = false,
    this.dueDate,
    required this.listId,
    required this.createdAt,
    this.completedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? note,
    bool? isCompleted,
    bool? isImportant,
    DateTime? dueDate,
    String? listId,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearNote = false,
    bool clearDueDate = false,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      note: clearNote ? null : (note ?? this.note),
      isCompleted: isCompleted ?? this.isCompleted,
      isImportant: isImportant ?? this.isImportant,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      listId: listId ?? this.listId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    note,
    isCompleted,
    isImportant,
    dueDate,
    listId,
    createdAt,
    completedAt,
  ];
}

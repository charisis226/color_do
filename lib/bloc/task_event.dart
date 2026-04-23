import 'package:equatable/equatable.dart';
import '../models/models.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final String? listId;

  const LoadTasks({this.listId});

  @override
  List<Object?> get props => [listId];
}

class LoadImportantTasks extends TaskEvent {}

class LoadTodayTasks extends TaskEvent {}

class LoadPlannedTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final String title;
  final String? note;
  final String listId;
  final DateTime? dueDate;
  final bool isImportant;

  const AddTask({
    required this.title,
    this.note,
    required this.listId,
    this.dueDate,
    this.isImportant = false,
  });

  @override
  List<Object?> get props => [title, note, listId, dueDate, isImportant];
}

class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskComplete extends TaskEvent {
  final String taskId;

  const ToggleTaskComplete(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskImportant extends TaskEvent {
  final String taskId;

  const ToggleTaskImportant(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class MoveTask extends TaskEvent {
  final String taskId;
  final String newListId;

  const MoveTask({required this.taskId, required this.newListId});

  @override
  List<Object?> get props => [taskId, newListId];
}

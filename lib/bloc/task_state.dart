import 'package:equatable/equatable.dart';
import '../models/models.dart';

enum TaskFilter { all, today, important, planned }

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final TaskFilter filter;
  final String? currentListId;

  const TaskLoaded({
    required this.tasks,
    this.filter = TaskFilter.all,
    this.currentListId,
  });

  List<Task> get incompleteTasks => tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => tasks.where((t) => t.isCompleted).toList();

  @override
  List<Object?> get props => [tasks, filter, currentListId];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

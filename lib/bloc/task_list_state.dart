import 'package:equatable/equatable.dart';
import '../models/models.dart';

abstract class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object?> get props => [];
}

class TaskListInitial extends TaskListState {}

class TaskListLoading extends TaskListState {}

class TaskListLoaded extends TaskListState {
  final List<TaskList> lists;
  final String? selectedListId;

  const TaskListLoaded({required this.lists, this.selectedListId});

  TaskList? get selectedList {
    if (selectedListId == null) return null;
    try {
      return lists.firstWhere((list) => list.id == selectedListId);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [lists, selectedListId];
}

class TaskListError extends TaskListState {
  final String message;

  const TaskListError(this.message);

  @override
  List<Object?> get props => [message];
}

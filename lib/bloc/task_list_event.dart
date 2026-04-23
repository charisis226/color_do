import 'package:equatable/equatable.dart';
import '../models/models.dart';

abstract class TaskListEvent extends Equatable {
  const TaskListEvent();

  @override
  List<Object?> get props => [];
}

class LoadTaskLists extends TaskListEvent {}

class AddTaskList extends TaskListEvent {
  final String name;
  final int colorValue;
  final String iconName;

  const AddTaskList({
    required this.name,
    required this.colorValue,
    this.iconName = 'list',
  });

  @override
  List<Object?> get props => [name, colorValue, iconName];
}

class UpdateTaskList extends TaskListEvent {
  final TaskList list;

  const UpdateTaskList(this.list);

  @override
  List<Object?> get props => [list];
}

class DeleteTaskList extends TaskListEvent {
  final String listId;

  const DeleteTaskList(this.listId);

  @override
  List<Object?> get props => [listId];
}

class SelectTaskList extends TaskListEvent {
  final String? listId;

  const SelectTaskList(this.listId);

  @override
  List<Object?> get props => [listId];
}

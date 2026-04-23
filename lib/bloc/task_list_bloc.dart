import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/repositories.dart';
import 'task_list_event.dart';
import 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final TaskListRepository _taskListRepository;
  String? _selectedListId;

  TaskListBloc({required TaskListRepository taskListRepository})
    : _taskListRepository = taskListRepository,
      super(TaskListInitial()) {
    on<LoadTaskLists>(_onLoadTaskLists);
    on<AddTaskList>(_onAddTaskList);
    on<UpdateTaskList>(_onUpdateTaskList);
    on<DeleteTaskList>(_onDeleteTaskList);
    on<SelectTaskList>(_onSelectTaskList);
  }

  void _onLoadTaskLists(LoadTaskLists event, Emitter<TaskListState> emit) {
    final lists = _taskListRepository.getAllLists();
    if (lists.isNotEmpty && _selectedListId == null) {
      _selectedListId = lists.first.id;
    }
    emit(TaskListLoaded(lists: lists, selectedListId: _selectedListId));
  }

  Future<void> _onAddTaskList(
    AddTaskList event,
    Emitter<TaskListState> emit,
  ) async {
    await _taskListRepository.addList(
      name: event.name,
      colorValue: event.colorValue,
      iconName: event.iconName,
    );
    add(LoadTaskLists());
  }

  Future<void> _onUpdateTaskList(
    UpdateTaskList event,
    Emitter<TaskListState> emit,
  ) async {
    await _taskListRepository.updateList(event.list);
    add(LoadTaskLists());
  }

  Future<void> _onDeleteTaskList(
    DeleteTaskList event,
    Emitter<TaskListState> emit,
  ) async {
    await _taskListRepository.deleteList(event.listId);
    if (_selectedListId == event.listId) {
      _selectedListId = null;
    }
    add(LoadTaskLists());
  }

  void _onSelectTaskList(SelectTaskList event, Emitter<TaskListState> emit) {
    _selectedListId = event.listId;
    if (state is TaskListLoaded) {
      final currentState = state as TaskListLoaded;
      emit(
        TaskListLoaded(lists: currentState.lists, selectedListId: event.listId),
      );
    }
  }
}

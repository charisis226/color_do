import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/repositories.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  TaskFilter _currentFilter = TaskFilter.all;
  String? _currentListId;

  TaskBloc({required TaskRepository taskRepository})
    : _taskRepository = taskRepository,
      super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadImportantTasks>(_onLoadImportantTasks);
    on<LoadTodayTasks>(_onLoadTodayTasks);
    on<LoadPlannedTasks>(_onLoadPlannedTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskComplete>(_onToggleTaskComplete);
    on<ToggleTaskImportant>(_onToggleTaskImportant);
    on<MoveTask>(_onMoveTask);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    _currentFilter = TaskFilter.all;
    _currentListId = event.listId;
    final tasks = event.listId != null
        ? _taskRepository.getTasksByListId(event.listId!)
        : _taskRepository.getAllTasks();
    emit(
      TaskLoaded(
        tasks: tasks,
        filter: TaskFilter.all,
        currentListId: event.listId,
      ),
    );
  }

  void _onLoadImportantTasks(
    LoadImportantTasks event,
    Emitter<TaskState> emit,
  ) {
    _currentFilter = TaskFilter.important;
    final tasks = _taskRepository.getImportantTasks();
    emit(TaskLoaded(tasks: tasks, filter: TaskFilter.important));
  }

  void _onLoadTodayTasks(LoadTodayTasks event, Emitter<TaskState> emit) {
    _currentFilter = TaskFilter.today;
    final tasks = _taskRepository.getTodayTasks();
    emit(TaskLoaded(tasks: tasks, filter: TaskFilter.today));
  }

  void _onLoadPlannedTasks(LoadPlannedTasks event, Emitter<TaskState> emit) {
    _currentFilter = TaskFilter.planned;
    final tasks = _taskRepository.getPlannedTasks();
    emit(TaskLoaded(tasks: tasks, filter: TaskFilter.planned));
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    await _taskRepository.addTask(
      title: event.title,
      note: event.note,
      listId: event.listId,
      dueDate: event.dueDate,
      isImportant: event.isImportant,
    );
    _reloadCurrentFilter();
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    await _taskRepository.updateTask(event.task);
    _reloadCurrentFilter();
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    await _taskRepository.deleteTask(event.taskId);
    _reloadCurrentFilter();
  }

  Future<void> _onToggleTaskComplete(
    ToggleTaskComplete event,
    Emitter<TaskState> emit,
  ) async {
    await _taskRepository.toggleComplete(event.taskId);
    _reloadCurrentFilter();
  }

  Future<void> _onToggleTaskImportant(
    ToggleTaskImportant event,
    Emitter<TaskState> emit,
  ) async {
    await _taskRepository.toggleImportant(event.taskId);
    _reloadCurrentFilter();
  }

  Future<void> _onMoveTask(MoveTask event, Emitter<TaskState> emit) async {
    await _taskRepository.moveTask(event.taskId, event.newListId);
    _reloadCurrentFilter();
  }

  void _reloadCurrentFilter() {
    switch (_currentFilter) {
      case TaskFilter.all:
        add(LoadTasks(listId: _currentListId));
        break;
      case TaskFilter.important:
        add(LoadImportantTasks());
        break;
      case TaskFilter.today:
        add(LoadTodayTasks());
        break;
      case TaskFilter.planned:
        add(LoadPlannedTasks());
        break;
    }
  }
}

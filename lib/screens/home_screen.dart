import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
import 'task_list_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<TaskListBloc>().add(LoadTaskLists());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color.do'),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TaskListManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildMyDayView(),
          _buildImportantView(),
          _buildPlannedView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _loadTasks(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '내 할 일',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: '중요함',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: '계획됨',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _loadTasks(int index) {
    switch (index) {
      case 0:
        final taskListState = context.read<TaskListBloc>().state;
        if (taskListState is TaskListLoaded) {
          context.read<TaskBloc>().add(
            LoadTasks(listId: taskListState.selectedListId),
          );
        } else {
          context.read<TaskBloc>().add(const LoadTasks());
        }
        break;
      case 1:
        context.read<TaskBloc>().add(LoadImportantTasks());
        break;
      case 2:
        context.read<TaskBloc>().add(LoadPlannedTasks());
        break;
    }
  }

  Widget _buildMyDayView() {
    return BlocBuilder<TaskListBloc, TaskListState>(
      builder: (context, listState) {
        if (listState is TaskListLoaded) {
          if (listState.selectedListId != null) {
            context.read<TaskBloc>().add(
              LoadTasks(listId: listState.selectedListId),
            );
          } else {
            context.read<TaskBloc>().add(const LoadTasks());
          }
        }
        return BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TaskLoaded) {
              return _buildTaskList(state.tasks);
            }
            return const Center(child: Text('할 일을 추가하세요'));
          },
        );
      },
    );
  }

  Widget _buildImportantView() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TaskLoaded) {
          return _buildTaskList(state.tasks);
        }
        return const Center(child: Text('중요한 할 일이 없습니다'));
      },
    );
  }

  Widget _buildPlannedView() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TaskLoaded) {
          return _buildTaskList(state.tasks);
        }
        return const Center(child: Text('계획된 할 일이 없습니다'));
      },
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('할 일이 없습니다'));
    }
    final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = tasks.where((t) => t.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (incompleteTasks.isNotEmpty) ...[
          ...incompleteTasks.map(
            (task) => TaskTile(
              task: task,
              onTap: () => _navigateToTaskDetail(context, task),
              onToggleComplete: () {
                context.read<TaskBloc>().add(ToggleTaskComplete(task.id));
              },
              onToggleImportant: () {
                context.read<TaskBloc>().add(ToggleTaskImportant(task.id));
              },
              onDelete: () {
                context.read<TaskBloc>().add(DeleteTask(task.id));
              },
            ),
          ),
        ],
        if (completedTasks.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '완료됨',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          ...completedTasks.map(
            (task) => TaskTile(
              task: task,
              onTap: () => _navigateToTaskDetail(context, task),
              onToggleComplete: () {
                context.read<TaskBloc>().add(ToggleTaskComplete(task.id));
              },
              onToggleImportant: () {
                context.read<TaskBloc>().add(ToggleTaskImportant(task.id));
              },
              onDelete: () {
                context.read<TaskBloc>().add(DeleteTask(task.id));
              },
            ),
          ),
        ],
      ],
    );
  }

  void _navigateToAddTask(BuildContext context) {
    final listState = context.read<TaskListBloc>().state;
    String? selectedListId;
    if (listState is TaskListLoaded) {
      selectedListId = listState.selectedListId;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(listId: selectedListId),
      ),
    ).then((_) => _loadTasks(_selectedIndex));
  }

  void _navigateToTaskDetail(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    ).then((_) => _loadTasks(_selectedIndex));
  }
}

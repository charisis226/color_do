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
    _loadTasks(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Navigator.of(context).push(
                  _SideDrawerRoute(
                    selectedIndex: _selectedIndex,
                    onLoadTasks: _loadTasks,
                  ),
                );
              },
            ),
            const Text('Color.do'),
          ],
        ),
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

class _SideDrawerRoute extends PageRouteBuilder {
  final int selectedIndex;
  final Function(int) onLoadTasks;

  _SideDrawerRoute({
    required this.selectedIndex,
    required this.onLoadTasks,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => _SideDrawer(
            selectedIndex: selectedIndex,
            onLoadTasks: onLoadTasks,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
}

class _SideDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onLoadTasks;

  const _SideDrawer({
    required this.selectedIndex,
    required this.onLoadTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
        title: const Text('할 일 목록'),
      ),
      body: SafeArea(
        child: BlocBuilder<TaskListBloc, TaskListState>(
          builder: (context, state) {
            if (state is TaskListLoaded) {
              return ListView.builder(
                itemCount: state.lists.length,
                itemBuilder: (context, index) {
                  final list = state.lists[index];
                  final isSelected = list.id == state.selectedListId;
                  return TaskListTile(
                    taskList: list,
                    isSelected: isSelected,
                    taskCount: 0,
                    onTap: () {
                      context.read<TaskListBloc>().add(SelectTaskList(list.id));
                      onLoadTasks(selectedIndex);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
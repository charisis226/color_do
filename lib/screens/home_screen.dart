import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

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
                showDialog(
                  context: context,
                  builder: (context) => _SideDrawerOverlay(
                    selectedIndex: _selectedIndex,
                    onLoadTasks: _loadTasks,
                  ),
                );
              },
            ),
            const Text('Color.do'),
          ],
        ),
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

class _SideDrawerOverlay extends Dialog {
  final int selectedIndex;
  final Function(int) onLoadTasks;

  const _SideDrawerOverlay({
    required this.selectedIndex,
    required this.onLoadTasks,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.black54,
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: screenWidth * 0.5,
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '할 일 목록',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
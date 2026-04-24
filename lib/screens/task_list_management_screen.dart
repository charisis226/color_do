import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../theme/app_theme.dart';

class TaskListManagementScreen extends StatefulWidget {
  const TaskListManagementScreen({super.key});

  static Future<void> showAddListDialog(BuildContext parentContext) async {
    final nameController = TextEditingController();
    int selectedColor = AppTheme.listColors.first.value;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('새 목록'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: '목록 이름'),
              ),
              const SizedBox(height: 16),
              const Text('색상 선택'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppTheme.listColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color.value;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selectedColor == color.value
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  parentContext.read<TaskListBloc>().add(
                    AddTaskList(
                      name: nameController.text.trim(),
                      colorValue: selectedColor,
                    ),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<TaskListManagementScreen> createState() =>
      _TaskListManagementScreenState();
}

class _TaskListManagementScreenState extends State<TaskListManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('목록 관리')),
      body: BlocBuilder<TaskListBloc, TaskListState>(
        builder: (context, state) {
          if (state is TaskListLoaded) {
            return ListView.builder(
              itemCount: state.lists.length,
              itemBuilder: (context, index) {
                final list = state.lists[index];
                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(list.colorValue),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.list,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  title: Text(list.name),
                  subtitle: list.isDefault ? const Text('기본 목록') : null,
                  trailing: list.isDefault
                      ? null
                      : PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('편집'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('삭제'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditListDialog(
                                context,
                                list.id,
                                list.name,
                                list.colorValue,
                              );
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(context, list.id);
                            }
                          },
                        ),
                  onTap: () {
                    context.read<TaskListBloc>().add(SelectTaskList(list.id));
                    Navigator.pop(context);
                  },
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddListDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddListDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColor = AppTheme.listColors.first.value;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('새 목록'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: '목록 이름'),
              ),
              const SizedBox(height: 16),
              const Text('색상 선택'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppTheme.listColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color.value;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selectedColor == color.value
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  context.read<TaskListBloc>().add(
                    AddTaskList(
                      name: nameController.text.trim(),
                      colorValue: selectedColor,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditListDialog(
    BuildContext context,
    String listId,
    String currentName,
    int currentColor,
  ) {
    final nameController = TextEditingController(text: currentName);
    int selectedColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('목록 편집'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: '목록 이름'),
              ),
              const SizedBox(height: 16),
              const Text('색상 선택'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppTheme.listColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color.value;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selectedColor == color.value
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final listState = context.read<TaskListBloc>().state;
                  if (listState is TaskListLoaded) {
                    final list = listState.lists.firstWhere(
                      (l) => l.id == listId,
                    );
                    context.read<TaskListBloc>().add(
                      UpdateTaskList(
                        list.copyWith(
                          name: nameController.text.trim(),
                          colorValue: selectedColor,
                        ),
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String listId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목록 삭제'),
        content: const Text('이 목록과 관련된 모든 할 일이 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskListBloc>().add(DeleteTaskList(listId));
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

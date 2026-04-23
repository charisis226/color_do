import 'package:flutter/material.dart';
import '../models/models.dart';

class TaskListTile extends StatelessWidget {
  final TaskList taskList;
  final bool isSelected;
  final int taskCount;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const TaskListTile({
    super.key,
    required this.taskList,
    required this.isSelected,
    required this.taskCount,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: const Color(0xFFE8F4FD),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Color(taskList.colorValue),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.list, color: Colors.white, size: 18),
      ),
      title: Text(
        taskList.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: taskCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$taskCount',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            )
          : null,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

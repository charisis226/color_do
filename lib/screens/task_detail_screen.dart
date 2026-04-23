import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/bloc.dart';
import '../models/models.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late DateTime? _dueDate;
  late bool _isImportant;
  late String _selectedListId;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _noteController = TextEditingController(text: widget.task.note ?? '');
    _dueDate = widget.task.dueDate;
    _isImportant = widget.task.isImportant;
    _selectedListId = widget.task.listId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '할 일 편집' : '할 일 상세'),
        actions: [
          if (_isEditing)
            TextButton(onPressed: _saveTask, child: const Text('저장'))
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteTask),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing)
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '할 일 제목',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 18),
              )
            else
              Text(
                widget.task.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.task.isCompleted ? '완료됨' : '진행 중',
                  style: TextStyle(
                    color: widget.task.isCompleted ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  _dueDate != null
                      ? DateFormat('EEEE, MMMM d, y').format(_dueDate!)
                      : '마감일 없음',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _isImportant ? Icons.star : Icons.star_border,
                  size: 20,
                  color: _isImportant ? Colors.amber : null,
                ),
                const SizedBox(width: 8),
                Text(_isImportant ? '중요함' : '보통'),
              ],
            ),
            const Divider(height: 32),
            const Text(
              '메모',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (_isEditing)
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  hintText: '메모 추가',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              )
            else
              Text(
                widget.task.note ?? '메모 없음',
                style: TextStyle(
                  color: widget.task.note != null ? null : Colors.grey,
                ),
              ),
            const SizedBox(height: 16),
            if (_isEditing) ...[
              const Text(
                '목록',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<TaskListBloc, TaskListState>(
                builder: (context, state) {
                  if (state is TaskListLoaded) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.lists.map((list) {
                        final isSelected = _selectedListId == list.id;
                        return ChoiceChip(
                          label: Text(list.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedListId = list.id;
                            });
                          },
                        );
                      }).toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요')));
      return;
    }

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      dueDate: _dueDate,
      isImportant: _isImportant,
      listId: _selectedListId,
      clearNote: _noteController.text.trim().isEmpty,
    );

    context.read<TaskBloc>().add(UpdateTask(updatedTask));
    Navigator.pop(context);
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할 일 삭제'),
        content: const Text('이 할 일을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTask(widget.task.id));
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

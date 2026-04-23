import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/bloc.dart';
import '../theme/app_theme.dart';

class AddTaskScreen extends StatefulWidget {
  final String? listId;

  const AddTaskScreen({super.key, this.listId});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _dueDate;
  bool _isImportant = false;
  String? _selectedListId;

  @override
  void initState() {
    super.initState();
    _selectedListId = widget.listId;
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
        title: const Text('새 할 일'),
        actions: [TextButton(onPressed: _saveTask, child: const Text('저장'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '할 일 제목',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 18),
              autofocus: true,
            ),
            const Divider(),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: '메모 추가',
                border: InputBorder.none,
              ),
              maxLines: 3,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('마감일'),
              subtitle: _dueDate != null
                  ? Text(DateFormat('EEEE, MMMM d').format(_dueDate!))
                  : const Text('설정 안 함'),
              onTap: _selectDate,
              trailing: _dueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _dueDate = null;
                        });
                      },
                    )
                  : null,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.star_border),
              title: const Text('중요함'),
              trailing: Switch(
                value: _isImportant,
                onChanged: (value) {
                  setState(() {
                    _isImportant = value;
                  });
                },
              ),
            ),
            const Divider(),
            BlocBuilder<TaskListBloc, TaskListState>(
              builder: (context, state) {
                if (state is TaskListLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '목록',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.lists.map((list) {
                          final isSelected = _selectedListId == list.id;
                          return ChoiceChip(
                            label: Text(list.name),
                            selected: isSelected,
                            selectedColor: Color(
                              list.colorValue,
                            ).withOpacity(0.3),
                            onSelected: (selected) {
                              setState(() {
                                _selectedListId = list.id;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요')));
      return;
    }

    final listState = context.read<TaskListBloc>().state;
    String listId = _selectedListId ?? '';
    if (listState is TaskListLoaded && listId.isEmpty) {
      listId = listState.selectedList?.id ?? '';
    }

    context.read<TaskBloc>().add(
      AddTask(
        title: _titleController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        listId: listId,
        dueDate: _dueDate,
        isImportant: _isImportant,
      ),
    );

    Navigator.pop(context);
  }
}

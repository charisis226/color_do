import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'task_list.g.dart';

@HiveType(typeId: 1)
class TaskList extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int colorValue;

  @HiveField(3)
  final String iconName;

  @HiveField(4)
  final bool isDefault;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final int sortOrder;

  const TaskList({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconName = 'list',
    this.isDefault = false,
    required this.createdAt,
    this.sortOrder = 0,
  });

  TaskList copyWith({
    String? id,
    String? name,
    int? colorValue,
    String? iconName,
    bool? isDefault,
    DateTime? createdAt,
    int? sortOrder,
  }) {
    return TaskList(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    colorValue,
    iconName,
    isDefault,
    createdAt,
    sortOrder,
  ];
}

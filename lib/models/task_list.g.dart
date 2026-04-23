part of 'task_list.dart';

class TaskListAdapter extends TypeAdapter<TaskList> {
  @override
  final int typeId = 1;

  @override
  TaskList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskList(
      id: fields[0] as String,
      name: fields[1] as String,
      colorValue: fields[2] as int,
      iconName: fields[3] as String,
      isDefault: fields[4] as bool,
      createdAt: fields[5] as DateTime,
      sortOrder: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TaskList obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorValue)
      ..writeByte(3)
      ..write(obj.iconName)
      ..writeByte(4)
      ..write(obj.isDefault)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/models.dart';
import 'repositories/repositories.dart';
import 'bloc/bloc.dart';
import 'screens/screens.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskListAdapter());

  final taskRepository = TaskRepository();
  final taskListRepository = TaskListRepository();

  await taskListRepository.init();
  await taskRepository.init();

  runApp(
    ColorDoApp(
      taskRepository: taskRepository,
      taskListRepository: taskListRepository,
    ),
  );
}

class ColorDoApp extends StatelessWidget {
  final TaskRepository taskRepository;
  final TaskListRepository taskListRepository;

  const ColorDoApp({
    super.key,
    required this.taskRepository,
    required this.taskListRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              TaskListBloc(taskListRepository: taskListRepository)
                ..add(LoadTaskLists()),
        ),
        BlocProvider(
          create: (context) =>
              TaskBloc(taskRepository: taskRepository)..add(const LoadTasks()),
        ),
      ],
      child: MaterialApp(
        title: 'Color.do',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assesment/injection_container.dart' as di;

import 'features/task_manager/presentation/bloc/task_bloc.dart';
import 'features/task_manager/presentation/pages/task_list_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize dependencies
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      home: BlocProvider(
        create: (context) => di.sl<TaskBloc>()..add(LoadTasks()),
        child: TaskListPage(),
      ),
    );
  }
}

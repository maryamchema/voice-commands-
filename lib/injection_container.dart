import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_assesment/features/task_manager/domain/usecases/add_task.dart';
import 'package:task_assesment/features/task_manager/presentation/bloc/task_bloc.dart';

import 'features/task_manager/data/datasources/task_local_data_source.dart';
import 'features/task_manager/data/datasources/task_local_data_source_impl.dart';
import 'features/task_manager/data/repositories/task_repository_impl.dart';
import 'features/task_manager/domain/entities/task.dart';
import 'features/task_manager/domain/repositories/task_repository.dart';
import 'features/task_manager/domain/usecases/delete_task.dart';
import 'features/task_manager/domain/usecases/get_task.dart';
import 'features/task_manager/domain/usecases/get_task_id.dart';
import 'features/task_manager/domain/usecases/get_task_id_by_title.dart';
import 'features/task_manager/domain/usecases/update_task.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Register BLoC
  // await _initHive();
  sl.registerFactory(() => TaskBloc(
        getTasks: sl(),
        addTask: sl(),
        updateTask: sl(),
        deleteTask: sl(),
        getTaskById: sl(),
        getTaskIdByTitle: sl(),
        updateTaskByTitle: sl(),
        deleteTaskByTitle: sl(),
      ));

  // Register Use Cases
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => AddTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerLazySingleton(() => GetTaskById(sl()));
  sl.registerLazySingleton(() => GetTaskIdByTitle(sl()));
  sl.registerLazySingleton(() => UpdateTaskByTitle(sl()));
  sl.registerLazySingleton(() => DeleteTaskByTitle(sl()));
  sl.registerSingleton<List<Task>>([]);

  // Register Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(localDataSource: sl(), taskList: sl()),
  );

  // Register Data Sources
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(hiveBox: sl()),
  );

  // Initialize Hive or other dependencies
  await _initHive();
}

// lib/injection_container.dart

Future<void> _initHive() async {
  try {
    await Hive.initFlutter();

    await _openBoxWithRecovery();
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  } catch (e) {
    print('Hive initialization failed: $e');
  }
}

Future<void> _openBoxWithRecovery() async {
  try {
    final box = await Hive.openBox('tasks');
    sl.registerLazySingleton<Box<dynamic>>(() => box);
  } catch (e) {
    // If box is corrupted, delete and recreate
    await Hive.deleteBoxFromDisk('tasks');
    final box = await Hive.openBox('tasks');
    sl.registerLazySingleton<Box<dynamic>>(() => box);
  }
}

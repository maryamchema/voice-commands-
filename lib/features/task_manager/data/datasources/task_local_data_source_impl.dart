// lib/features/task_manager/data/datasources/task_local_data_source_impl.dart

// import 'package:dartz/dartz.dart' hide Task;
import 'package:hive/hive.dart';
import 'package:task_assesment/features/task_manager/data/datasources/task_local_data_source.dart';
import 'package:task_assesment/features/task_manager/data/models/task_model.dart';

import '../../../../core/errors/exceptions.dart';

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<dynamic> hiveBox;

  TaskLocalDataSourceImpl({required this.hiveBox});

  Future<void> _ensureMapType(Map<String, dynamic> data) async {
    if (data.keys.any((k) => k is! String)) {
      throw CacheException('Invalid map key types');
    }
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    final json = task.toJson();
    await _ensureMapType(json);
    // await box.put(task.id, json);
    await hiveBox.put(task.id, task.toJson());
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      return hiveBox.values.map((dynamic item) {
        // Ensure proper type conversion
        final json =
            item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};
        return TaskModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw CacheException('Failed to load tasks: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    if (hiveBox.containsKey(task.id)) {
      await hiveBox.put(task.id, task.toJson());
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await hiveBox.delete(taskId);
  }

  @override
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      if (!hiveBox.containsKey(taskId)) return null;

      final json = hiveBox.get(taskId);
      return json != null
          ? TaskModel.fromJson(json as Map<String, dynamic>)
          : null;
    } catch (e) {
      throw CacheException('Failed to load task: ${e.toString()}');
    }
  }
}

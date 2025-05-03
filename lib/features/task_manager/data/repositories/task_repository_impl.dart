import 'package:hive/hive.dart';
import 'package:task_assesment/core/errors/failures.dart';
import 'package:task_assesment/injection_container.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../models/task_model.dart';
import 'package:dartz/dartz.dart' hide Task;

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final List<Task> taskList;

  TaskRepositoryImpl({required this.localDataSource, required this.taskList});

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      final taskModels = await localDataSource.getTasks();
      return Right(taskModels.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Task?> findByTitle(String title) async {
    try {
      return taskList.firstWhere(
        (task) => task.title.toLowerCase() == title.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<Failure, void>> addTask(Task task) async {
    try {
      await localDataSource.cacheTask(TaskModel.fromEntity(task));
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(CacheFailure(e.toString(), stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await localDataSource.deleteTask(taskId);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(CacheFailure(e.toString(), stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> updateTask(Task task) async {
    try {
      await localDataSource.updateTask(TaskModel.fromEntity(task));
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(CacheFailure(e.toString(), stackTrace));
    }
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String taskId) async {
    try {
      final box = sl.get<Box<dynamic>>();

      // Check if task exists
      if (!box.containsKey(taskId)) {
        return Left(CacheFailure('Task not found'));
      }

      // Get and parse the task
      final json = box.get(taskId) as Map<String, dynamic>?;
      if (json == null) {
        return Left(CacheFailure('Task data corrupted'));
      }

      final taskModel = TaskModel.fromJson(json);
      return Right(taskModel.toEntity());
    } on HiveError catch (e) {
      return Left(CacheFailure('Storage error: ${e.message}'));
    } catch (e, stackTrace) {
      return Left(
          CacheFailure('Unexpected error: ${e.toString()}', stackTrace));
    }
  }

  @override
  Future<Either<Failure, String>> getTaskIdByTitle(String title) async {
    try {
      final tasks = await localDataSource.getTasks();
      final task = tasks.firstWhere(
        (t) => t.title.toLowerCase() == title.toLowerCase(),
        orElse: () => throw ('Task not found'),
      );
      return Right(task.id);
    } on LLMProcessingFailure catch (e) {
      return Left(LLMProcessingFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error finding task: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTaskByTitle(
      String title, Task newData) async {
    final taskIdResult = await getTaskIdByTitle(title);
    return taskIdResult.fold(
      (failure) => Left(failure),
      (taskId) => updateTask(newData.copyWith(id: taskId)),
    );
  }

  @override
  Future<Either<Failure, void>> deleteTaskByTitle(String title) async {
    try {
      // First find the task ID
      final taskIdResult = await getTaskIdByTitle(title);

      return await taskIdResult.fold(
        (failure) => Left(failure),
        (taskId) async {
          await localDataSource.deleteTask(taskId);
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Failed to delete task: ${e.toString()}'));
    }
  }
}

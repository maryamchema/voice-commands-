import '../../../../core/errors/failures.dart';
import '../entities/task.dart';
import 'package:dartz/dartz.dart' hide Task;

abstract class TaskRepository {
  final List<Task> _taskList; // this should come from BLoC or DB

  TaskRepository(this._taskList);

  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, void>> addTask(Task task);
  Future<Either<Failure, void>> updateTask(Task task);
  Future<Either<Failure, void>> deleteTask(String taskId);

  Future<Either<Failure, Task>> getTaskById(String taskId);

  Future<Either<Failure, String>> getTaskIdByTitle(String title);
  Future<Either<Failure, void>> updateTaskByTitle(String title, Task newData);
  Future<Either<Failure, void>> deleteTaskByTitle(String title);
  Future<Task?> findByTitle(String title);
}

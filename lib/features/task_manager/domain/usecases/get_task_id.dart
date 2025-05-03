import 'package:dartz/dartz.dart' hide Task;
import 'package:task_assesment/core/errors/failures.dart';
import 'package:task_assesment/features/task_manager/domain/entities/task.dart';
import 'package:task_assesment/features/task_manager/domain/repositories/task_repository.dart';

class GetTaskById {
  final TaskRepository repository;

  GetTaskById(this.repository); // Dependency injection

  Future<Either<Failure, Task>> call(String taskId) async {
    try {
      // 1. Validate input
      if (taskId.isEmpty) {
        return Left(LLMProcessingFailure('Task ID cannot be empty'));
      }

      // 2. Call repository
      final result = await repository.getTaskById(taskId);

      // 3. Handle not found case
      return result.fold(
        (failure) => Left(failure),
        (task) => task != null
            ? Right(task)
            : Left(LLMProcessingFailure('Task not found')),
      );
    } catch (e, stackTrace) {
      // 4. Handle unexpected errors
      return Left(RepositoryFailure(
        'Failed to fetch task: ${e.toString()}',
        stackTrace,
      ));
    }
  }
}

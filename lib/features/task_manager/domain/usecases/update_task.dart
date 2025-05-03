// lib/features/task_manager/domain/usecases/update_task.dart

import 'package:dartz/dartz.dart' hide Task;
import 'package:task_assesment/core/errors/failures.dart';
import 'package:task_assesment/features/task_manager/domain/entities/task.dart';
import 'package:task_assesment/features/task_manager/domain/repositories/task_repository.dart';

class UpdateTask {
  final TaskRepository repository;

  UpdateTask(this.repository);

  Future<Either<Failure, void>> call(Task task) async {
    try {
      // Validate task before updating
      if (task.title.isEmpty) {
        return Left(ValidationFailure('Task title cannot be empty'));
      }

      if (task.scheduledTime.isBefore(DateTime.now())) {
        return Left(ValidationFailure('Task cannot be scheduled in the past'));
      }

      // Call repository to update
      return await repository.updateTask(task);
    } catch (e, stackTrace) {
      return Left(RepositoryFailure(e.toString(), stackTrace));
    }
  }
}

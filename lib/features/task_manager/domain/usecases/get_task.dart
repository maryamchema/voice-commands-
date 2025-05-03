// lib/features/task_manager/domain/usecases/get_tasks.dart

import 'package:dartz/dartz.dart' hide Task;
import 'package:task_assesment/core/errors/failures.dart';
import 'package:task_assesment/features/task_manager/domain/entities/task.dart';
import 'package:task_assesment/features/task_manager/domain/repositories/task_repository.dart';

class GetTasks {
  final TaskRepository repository;

  GetTasks(this.repository);

  Future<Either<Failure, List<Task>>> call() async {
    return await repository.getTasks();
  }
}

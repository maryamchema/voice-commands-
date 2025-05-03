// lib/features/task_manager/domain/usecases/get_task_id_by_title.dart
import 'package:dartz/dartz.dart' hide Task;

import '../../../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTaskIdByTitle {
  final TaskRepository repository;

  GetTaskIdByTitle(this.repository);

  Future<Either<Failure, String>> call(String title) async {
    return await repository.getTaskIdByTitle(title);
  }
}

// lib/features/task_manager/domain/usecases/update_task_by_title.dart
class UpdateTaskByTitle {
  final TaskRepository repository;

  UpdateTaskByTitle(this.repository);

  Future<Either<Failure, void>> call(String title, Task newData) async {
    return await repository.updateTaskByTitle(title, newData);
  }
}

// lib/features/task_manager/domain/usecases/delete_task_by_title.dart
class DeleteTaskByTitle {
  final TaskRepository repository;

  DeleteTaskByTitle(this.repository);

  Future<Either<Failure, void>> call(String title) async {
    return await repository.deleteTaskByTitle(title);
  }
}

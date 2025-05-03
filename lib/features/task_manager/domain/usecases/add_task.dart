import '../../../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import 'package:dartz/dartz.dart' hide Task;

class AddTask {
  final TaskRepository repository;

  AddTask(this.repository);

  Future<Either<Failure, void>> call(Task task) async {
    return await repository.addTask(task);
  }
}

// lib/features/task_manager/domain/services/command_processor.dart

import 'package:dartz/dartz.dart' hide Task;
import 'package:task_assesment/core/errors/failures.dart';
import 'package:task_assesment/features/task_manager/domain/entities/task.dart';

abstract class CommandProcessor {
  Future<Either<Failure, CommandResult>> processCommand(String input);
}

class CommandResult {
  final CommandType type;
  final Task? task;
  final String? taskId;
  final DateTime? newTime;

  CommandResult.create(this.task)
      : type = CommandType.create,
        taskId = null,
        newTime = null;

  CommandResult.update(this.taskId, this.newTime)
      : type = CommandType.update,
        task = null;

  CommandResult.delete(this.taskId)
      : type = CommandType.delete,
        task = null,
        newTime = null;
}

enum CommandType { create, update, delete }

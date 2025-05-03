// lib/features/task_manager/data/services/llm_command_processor.dart

import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter/material.dart';
import 'package:task_assesment/core/errors/failures.dart';
import 'package:task_assesment/features/task_manager/domain/entities/task.dart';
import 'package:task_assesment/features/task_manager/domain/services/command_processor.dart';
import 'package:intl/intl.dart';

import '../repositories/task_repository.dart';
import 'llm_api_service.dart';

class LLMCommandProcessor implements CommandProcessor {
  final LLMApiService apiService;
  final TaskRepository taskRepository;

  LLMCommandProcessor({
    required this.apiService,
    required this.taskRepository,
  });

  @override
  Future<Either<Failure, CommandResult>> processCommand(String input) async {
    try {
      final resultMap = await apiService.processCommand(input);

      final action = resultMap['action'];
      final title = resultMap['title'];
      final oldTitle = resultMap['oldTitle'];
      final description = resultMap['description'];
      final dateTimeStr = resultMap['dateTime'];
      final parsedDateTime =
          dateTimeStr != null ? DateTime.tryParse(dateTimeStr) : null;

      switch (action) {
        case 'create':
          final task = Task(
            id: UniqueKey().toString(),
            title: title,
            oldTitle: title,
            description: description ?? '',
            scheduledTime: parsedDateTime ?? DateTime.now(),
          );
          return Right(CommandResult.create(task));

        case 'update':
          final task = await taskRepository.findByTitle(title);
          if (task == null) {
            return Left(
                LLMProcessingFailure("No task found with title '$title'"));
          }
          return Right(CommandResult.update(task.id, parsedDateTime));

        case 'delete':
          final task = await taskRepository.findByTitle(title);
          if (task == null) {
            return Left(
                LLMProcessingFailure("No task found with title '$title'"));
          }
          return Right(CommandResult.delete(task.id));

        default:
          return Left(LLMProcessingFailure("Unknown action '$action'"));
      }
    } catch (e) {
      return Left(LLMProcessingFailure("Command processing failed: $e"));
    }
  }
}

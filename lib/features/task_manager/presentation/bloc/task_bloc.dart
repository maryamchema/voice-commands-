import 'package:bloc/bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:task_assesment/core/errors/failures.dart';
import 'package:task_assesment/features/task_manager/domain/entities/task.dart';
import 'package:task_assesment/features/task_manager/domain/usecases/add_task.dart';
import 'package:task_assesment/features/task_manager/domain/usecases/get_task.dart';
import 'package:task_assesment/injection_container.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_task_id.dart';
import '../../domain/usecases/get_task_id_by_title.dart';
import '../../domain/usecases/update_task.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  final GetTaskIdByTitle getTaskIdByTitle; // Add this
  final UpdateTaskByTitle updateTaskByTitle; // Add this
  final DeleteTaskByTitle deleteTaskByTitle;
  final GetTaskById getTaskById;

  TaskBloc({
    required this.getTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
    required this.getTaskById,
    required this.getTaskIdByTitle,
    required this.updateTaskByTitle,
    required this.deleteTaskByTitle,
  }) : super(TaskInitial()) {
    // Register all event handlers
    on<LoadTasks>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<LoadTaskByIdEvent>(_onLoadTaskById);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<UpdateTaskByTitleEvent>(_onUpdateTaskByTitle);
    on<DeleteTaskByTitleEvent>(_onDeleteTaskByTitle);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      emit(TaskLoading());

      await Future.delayed(const Duration(milliseconds: 500));

      final result = await getTasks();

      result.fold(
        (failure) {
          if (failure is CacheFailure && event.refresh) {
            _recoverFromCacheFailure();
            add(LoadTasks(refresh: false));
          } else {
            emit(TaskError(failure));
          }
        },
        (tasks) {
          if (tasks.isEmpty) {
            emit(TaskEmpty());
          } else {
            emit(TaskLoaded(tasks));
          }
        },
      );
    } catch (e, stackTrace) {
      emit(TaskError(CacheFailure(e.toString(), stackTrace)));
    }
  }

  Future<void> _recoverFromCacheFailure() async {
    try {
      // Close and reopen the box
      final box = sl.get<Box<dynamic>>();
      // await box.close();
      await Hive.openBox('tasks');
    } catch (e) {
      // If recovery fails, create a new box
      await Hive.deleteBoxFromDisk('tasks');
      await Hive.openBox('tasks');
    }
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    final result = await addTask(event.task);
    result.fold(
      (failure) => emit(TaskError(failure)),
      (_) => add(LoadTasks()),
    );
  }

  Future<void> _onUpdateTask(
      UpdateTaskEvent event, Emitter<TaskState> emit) async {
    final result = await updateTask(event.task);
    result.fold(
      (failure) => emit(TaskError(failure)),
      (_) => add(LoadTasks()),
    );
  }

  Future<void> _onDeleteTask(
      DeleteTaskEvent event, Emitter<TaskState> emit) async {
    final result = await deleteTask(event.taskId);
    result.fold(
      (failure) => emit(TaskError(failure)),
      (_) => add(LoadTasks()),
    );
  }

  Future<void> _onLoadTaskById(
      LoadTaskByIdEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());

    final result = await getTaskById(event.taskId);

    result.fold(
      (failure) => emit(TaskError(failure)),
      (task) => emit(TaskLoaded([task])),
    );
  }

  Future<void> _onUpdateTaskTime(
      UpdateTaskTimeEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      try {
        // Find the task to update
        final task = currentState.tasks.firstWhere(
          (t) => t.id == event.taskId,
          orElse: () => throw Exception('Task not found'),
        );

        // Create updated copy
        final updatedTask = task.copyWith(scheduledTime: event.newTime);

        // Save the update
        final result = await updateTask(updatedTask);

        result.fold(
          (failure) => emit(TaskError(failure)),
          (_) => add(LoadTasks()), // Refresh the list
        );
      } catch (e) {
        emit(TaskError(CacheFailure(e.toString())));
      }
    }
  }

  Future<void> _onUpdateTaskByTitle(
      UpdateTaskByTitleEvent event, Emitter<TaskState> emit) async {
    try {
      emit(TaskLoading());

      final idResult = await getTaskIdByTitle(event.title);

      idResult.fold(
        // Remove await here
        (failure) => emit(TaskError(failure)),
        (taskId) async {
          final updatedTask = event.newData.copyWith(id: taskId);
          final updateResult = await updateTask(updatedTask);

          updateResult.fold(
            (failure) => emit(TaskError(failure)),
            (_) => add(LoadTasks()),
          );
        },
      );
    } catch (e) {
      emit(TaskError(CacheFailure(e.toString())));
    }
  }

  Future<void> _onDeleteTaskByTitle(
      DeleteTaskByTitleEvent event, Emitter<TaskState> emit) async {
    try {
      emit(TaskLoading());

      final idResult = await getTaskIdByTitle(event.title);

      idResult.fold(
        // Remove await here
        (failure) => emit(TaskError(failure)),
        (taskId) async {
          final deleteResult = await deleteTask(taskId);

          deleteResult.fold(
            (failure) => emit(TaskError(failure)),
            (_) {
              emit(TaskDeleted(event.title));
              add(LoadTasks());
            },
          );
        },
      );
    } catch (e) {
      emit(TaskError(CacheFailure(e.toString())));
    }
  }
}

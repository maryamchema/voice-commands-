// lib/features/task_manager/presentation/bloc/task_event.dart

part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {
  final bool refresh;

  const LoadTasks({this.refresh = false});

  @override
  List<Object> get props => [refresh];
}

class AddTaskEvent extends TaskEvent {
  final Task task;
  const AddTaskEvent(this.task);
  @override
  List<Object> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final Task task;
  const UpdateTaskEvent(this.task);
  @override
  List<Object> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;
  const DeleteTaskEvent(this.taskId);
  @override
  List<Object> get props => [taskId];
}

class LoadTaskByIdEvent extends TaskEvent {
  final String taskId;
  const LoadTaskByIdEvent(this.taskId);
  @override
  List<Object> get props => [taskId];
}

class UpdateTaskTimeEvent extends TaskEvent {
  final String taskId;
  final DateTime newTime;
  const UpdateTaskTimeEvent(this.taskId, this.newTime);
  @override
  List<Object> get props => [taskId, newTime];
}

class UpdateTaskByTitleEvent extends TaskEvent {
  final String title;
  final Task newData;

  const UpdateTaskByTitleEvent(this.title, this.newData);

  @override
  List<Object> get props => [title, newData];
}

class DeleteTaskByTitleEvent extends TaskEvent {
  final String title;

  const DeleteTaskByTitleEvent(this.title);

  @override
  List<Object> get props => [title];
}

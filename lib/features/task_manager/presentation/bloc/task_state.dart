part of 'task_bloc.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskEmpty extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;

  const TaskLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class TaskError extends TaskState {
  final Failure failure;

  const TaskError(this.failure);

  @override
  List<Object> get props => [failure];
}

class TaskDeleted extends TaskState {
  final String title;

  const TaskDeleted(this.title);

  @override
  List<Object> get props => [title];
}

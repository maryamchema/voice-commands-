import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.oldTitle,
    required super.description,
    required super.scheduledTime,
  });

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      oldTitle: task.oldTitle,
      description: task.description,
      scheduledTime: task.scheduledTime,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final map = json is Map ? json.cast<String, dynamic>() : {};
    return TaskModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      oldTitle: map['oldTitle'] as String? ?? '',
      description: map['description'] as String? ?? '',
      scheduledTime: DateTime.parse(
          map['scheduledTime'] as String? ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'oldTitle': oldTitle,
      'description': description,
      'scheduledTime': scheduledTime.toIso8601String(),
    };
  }
}

extension TaskModelExtensions on TaskModel {
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      oldTitle: oldTitle,
      description: description,
      scheduledTime: scheduledTime,
    );
  }
}

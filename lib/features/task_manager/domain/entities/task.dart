class Task {
  final String id;
  final String title;
  final String oldTitle;
  final String description;
  final DateTime scheduledTime;

  const Task({
    required this.id,
    required this.title,
    required this.oldTitle,
    required this.description,
    required this.scheduledTime,
  });
  Task copyWith({
    String? id,
    String? title,
    String? oldTitle,
    String? description,
    DateTime? scheduledTime,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      oldTitle: title ?? this.oldTitle,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.oldTitle == oldTitle &&
        other.description == description &&
        other.scheduledTime == scheduledTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        oldTitle.hashCode ^
        description.hashCode ^
        scheduledTime.hashCode;
  }
}

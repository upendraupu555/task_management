class Task {
  int? id;
  String title;
  String description;
  bool isCompleted;
  DateTime dueDate;
  final int position;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.dueDate,
    required this.position,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? position,
    DateTime? dueDate,
  }) {
    return Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        isCompleted: isCompleted ?? this.isCompleted,
        dueDate: dueDate ?? this.dueDate,
        position: position ?? this.position);
  }

  factory Task.fromMap(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        isCompleted: json['isCompleted'] == 1,
        dueDate: DateTime.parse(json['dueDate']),
        position: json['position'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted ? 1 : 0,
        'dueDate': dueDate.toIso8601String(),
        'position': position,
      };
}

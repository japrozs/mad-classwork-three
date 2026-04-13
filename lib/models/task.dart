// models/task.dart
// Data contract between the UI and Firestore.
// Every property must have a matching key in toMap() and fromMap().

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final List<Map<String, dynamic>> subtasks; // [{title: '', isDone: false}]
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.subtasks = const [],
    required this.createdAt,
  });

  /// Serialize → Firestore
  Map<String, dynamic> toMap() => {
    'title': title,
    'isCompleted': isCompleted,
    'subtasks': subtasks,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Deserialize ← Firestore snapshot
  factory Task.fromMap(String id, Map<String, dynamic> data) => Task(
    id: id,
    title: data['title'] ?? '',
    isCompleted: data['isCompleted'] ?? false,
    subtasks: List<Map<String, dynamic>>.from(data['subtasks'] ?? []),
    createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
  );

  /// Immutable update — used for toggling completion without re-creating the whole object
  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    List<Map<String, dynamic>>? subtasks,
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    subtasks: subtasks ?? this.subtasks,
    createdAt: createdAt ?? this.createdAt,
  );
}

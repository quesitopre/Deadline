class Subtask {
  final String id;
  final String title;
  final int totalMinutes;
  bool isCompleted;
  DateTime? completedAt;

  Subtask({
    required this.id,
    required this.title,
    required this.totalMinutes,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'totalMinutes': totalMinutes,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toString(),
  };

  factory Subtask.fromMap(Map<String, dynamic> map) => Subtask(
    id: map['id'],
    title: map['title'],
    totalMinutes: map['totalMinutes'],
    isCompleted: map['isCompleted'] ?? false,
    completedAt: map['completedAt'] != null
        ? DateTime.parse(map['completedAt'])
        : null,
  );

  // Default essay subtasks
  static List<Subtask> essayDefaults() => [
    Subtask(
      id: '1',
      title: 'Brainstorm and Research',
      totalMinutes: 120,
    ),
    Subtask(
      id: '2',
      title: 'Create Outline and Research',
      totalMinutes: 60,
    ),
    Subtask(
      id: '3',
      title: 'Create Rough Draft',
      totalMinutes: 180,
    ),
    Subtask(
      id: '4',
      title: 'Revise and Edit',
      totalMinutes: 60,
    ),
  ];
}
class Task {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;      // ← new
  String taskType;        // ← new
  List<Map<String, int>>? pageRanges;  // ← new
  int? questionCount;
  String taskDifficulty; 

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,                  // ← new
    this.taskType = 'Other',       // ← new
    this.pageRanges,               // ← new
    this.questionCount,  
    this.taskDifficulty = 'Easy',         
  });
}
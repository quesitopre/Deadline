import '../models/subtask.dart';

class Task {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;      
  String taskType;        
  List<Map<String, int>>? pageRanges;  
  int? questionCount;
  String taskDifficulty; 
  int? questionsAnswered;
  int? currentPage;
  List<Subtask>? subtasks;
  String? courseCode;
  // A runtime-only field (not saved to storage)
  bool needsHardCap = false;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,                  
    this.taskType = 'Other',       
    this.pageRanges,              
    this.questionCount,  
    this.taskDifficulty = 'Easy',         
    this.questionsAnswered,
    this.currentPage, 
    this.subtasks,
    this.courseCode,
  });

  double get progressPercent {
    if (taskType == 'Problem Set') {
      if (questionCount == null || questionCount == 0) return 0;
      final answered = questionsAnswered ?? 0;
      return (answered / questionCount!).clamp(0.0, 1.0);
    } else if (taskType == 'Reading') {
      if (pageRanges == null || pageRanges!.isEmpty) return 0;
      // Calculate total pages across all ranges
      final totalPages = pageRanges!.fold(0, (sum, r) =>
          sum + ((r['end'] as int) - (r['start'] as int) + 1));
      if (totalPages == 0) return 0;
      // Calculate pages read from first page of first range
      final firstPage = pageRanges!.first['start'] as int;
      final pagesRead = ((currentPage ?? firstPage) - firstPage)
          .clamp(0, totalPages);
      return (pagesRead / totalPages).clamp(0.0, 1.0);
    } else if (taskType == 'Essay') {
      if (subtasks == null || subtasks!.isEmpty) return 0;
      final totalMinutes = subtasks!.fold(0, (sum, s) => sum + s.totalMinutes);
      if (totalMinutes == 0) return 0;
      final completedMinutes = subtasks!
          .where((s) => s.isCompleted)
          .fold(0, (sum, s) => sum + s.totalMinutes);
      return (completedMinutes / totalMinutes).clamp(0.0, 1.0);
    }
    return 0;
  }

  bool get allSubtasksCompleted =>
      subtasks != null && subtasks!.isNotEmpty &&
      subtasks!.every((s) => s.isCompleted);
}
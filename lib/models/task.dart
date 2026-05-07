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
  
  
  // Add this as a runtime-only field (not saved to storage)
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
  });
}
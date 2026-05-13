class TaskSchedule {
  final int total;                  
  final int daysToComplete;
  final int firstDayCount;          
  final int remainingDaysCount;     
  final int remainingDays;
  final String unit;
  final String taskTitle;
  final String difficulty;                 

  TaskSchedule({
    required this.total,
    required this.daysToComplete,
    required this.firstDayCount,
    required this.remainingDaysCount,
    required this.remainingDays,
    required this.unit,
    required this.taskTitle,
    required this.difficulty,            
  });
}
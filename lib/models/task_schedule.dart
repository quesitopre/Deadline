class TaskSchedule {
  final int totalProblems;
  final int daysToComplete;
  final int problemsFirstDay;
  final int problemsRestOfDays;
  final int remainingDays;

  TaskSchedule({
    required this.totalProblems,
    required this.daysToComplete,
    required this.problemsFirstDay,
    required this.problemsRestOfDays,
    required this.remainingDays,
  });
}
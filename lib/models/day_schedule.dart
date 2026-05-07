class DayWorkload {
  final int dayIndex;           // 0 = today, 1 = tomorrow etc.
  int totalMinutes;
  final List<TaskMinutes> tasks;
  final bool isOverflowed;      // true if capped at 480

  DayWorkload({
    required this.dayIndex,
    this.totalMinutes = 0,
    List<TaskMinutes>? tasks,
    this.isOverflowed = false,
  }) : tasks = tasks ?? [];
}

class TaskMinutes {
  final String taskTitle;
  final int minutes;
  final String difficulty;

  TaskMinutes({
    required this.taskTitle,
    required this.minutes,
    required this.difficulty,
  });
}
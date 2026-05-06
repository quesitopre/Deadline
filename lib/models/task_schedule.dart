class TaskSchedule {
  final int total;                  // ← renamed from totalProblems
  final int daysToComplete;
  final int firstDayCount;          // ← renamed from problemsFirstDay
  final int remainingDaysCount;     // ← renamed from problemsRestOfDays
  final int remainingDays;
  final String unit;                // ← new: 'problems' or 'pages'

  TaskSchedule({
    required this.total,
    required this.daysToComplete,
    required this.firstDayCount,
    required this.remainingDaysCount,
    required this.remainingDays,
    required this.unit,             // ← new
  });
}
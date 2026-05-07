import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/task_schedule.dart';
import '../models/day_schedule.dart';

class TaskService {
  // Singleton pattern - only one instance ever exists
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final List<Task> _tasks = [];
  bool _loaded = false;

  // Get all tasks
  List<Task> getTasks() => _tasks;

  // Must call this first before anything else
  Future<void> initialize() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    //await prefs.remove('tasks'); // Resets app to have no tasks, use if tasks corrupted
    final String? data = prefs.getString('tasks');
    if (data != null) {
      final List decoded = jsonDecode(data);
      _tasks.addAll(decoded.map((t) => Task(
        id: t['id'],
        title: t['title'],
        description: t['description'],
        isCompleted: t['isCompleted'],
        createdAt: DateTime.parse(t['createdAt']),
        dueDate: t['dueDate'] != null ? DateTime.parse(t['dueDate']) : null,  // ← new
        taskType: t['taskType'] ?? 'Other',
        pageRanges: t['pageRanges'] != null
            ? List<Map<String, int>>.from(
                (t['pageRanges'] as List).map((r) => Map<String, int>.from(r)))
            : null, 
        questionCount: t['questionCount'],                   // ← new
        taskDifficulty: t['taskDifficulty'] ?? 'Easy',
      )));
    }
    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = _tasks.map((t) => {
      'id': t.id,
      'title': t.title,
      'description': t.description,
      'isCompleted': t.isCompleted,
      'createdAt': t.createdAt.toString(),
      'dueDate': t.dueDate?.toString(),     // ← new
      'taskType': t.taskType,
      'pageRanges': t.pageRanges,   // ← new
      'questionCount': t.questionCount,   // ← new
      'taskDifficulty': t.taskDifficulty,
    }).toList();
    await prefs.setString('tasks', jsonEncode(taskList));
  }

  Future<void> addTask(String title, String description, {DateTime? dueDate, String taskType = 'Other', List<Map<String, int>>? pageRanges, int? questionCount, String taskDifficulty = 'Unknown'}) async {
    _tasks.add(Task(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      isCompleted: false,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      taskType: taskType,
      pageRanges: pageRanges,    // ← new
      questionCount: questionCount,
      taskDifficulty: taskDifficulty,
    ));
    await _save();
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      await _save();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _save();
  }

  // Get only completed tasks
  List<Task> getCompletedTasks() {
    return _tasks.where((t) => t.isCompleted).toList();
  }

  // Get only incomplete tasks
  List<Task> getPendingTasks() {
    return _tasks.where((t) => !t.isCompleted).toList();
  }

  List<Task> getTasksSortedByDueDate() {
    final sorted = List<Task>.from(_tasks);
    sorted.sort((a, b) {
      // Tasks with no due date go to the bottom
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      // Sort closest due date to top
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return sorted;
  }

  int hoursUntilNearestTask() {
    final pending = getPendingTasks()
        .where((t) => t.dueDate != null)
        .toList();

    if (pending.isEmpty) return 0;

    // Sort by due date to find the nearest task
    pending.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    final nearest = pending.first;

    // Set due time to 11:59 PM on the due date
    final dueDateTime = DateTime(
      nearest.dueDate!.year,
      nearest.dueDate!.month,
      nearest.dueDate!.day,
      23,
      59,
    );

    final now = DateTime.now();

    // If already past due return 0
    if (dueDateTime.isBefore(now)) return 0;

    // Return hours remaining
    final hours = dueDateTime.difference(now).inHours;
    return hours > 999 ? 999 : hours; // ← cap at 999 -> roughly 41 days when divided by 24
  }

  int hoursSinceNearestTaskOverdue() {
    final pending = getPendingTasks()
        .where((t) => t.dueDate != null)
        .toList();

    if (pending.isEmpty) return 0;

    // Sort by due date to find the nearest task
    pending.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    final nearest = pending.first;

    // Set due time to 11:59 PM on the due date
    final dueDateTime = DateTime(
      nearest.dueDate!.year,
      nearest.dueDate!.month,
      nearest.dueDate!.day,
      23,
      59,
    );

    final now = DateTime.now();

    // If NOT already past due return 0
    if (!dueDateTime.isBefore(now)) return 0;

    // Hours past due date
    final hours = now.difference(dueDateTime).inHours;
    return hours > 999 ? 999 : hours; // ← cap at 999 -> roughly 41 days when divided by 24
  }

  TaskSchedule? calculateTaskSchedule(Task task) {
    if (task.isCompleted) return null;
    if (task.dueDate == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);

    final daysUntilDue = due.difference(today).inDays;
    if (daysUntilDue <= 0) return null;

    // How many days based on difficulty
    final int daysToComplete;
    if (task.taskDifficulty == 'Easy') {
      daysToComplete = 7;
    } else if (task.taskDifficulty == 'Medium') {
      daysToComplete = 14;
    } else {
      daysToComplete = 21;
    }

    final int workDays = daysToComplete < daysUntilDue ? daysToComplete : daysUntilDue;

    // Get the total count based on task type
    final int? total;
    if (task.taskType == 'Problem Set' && task.questionCount != null) {
      total = task.questionCount;
    } else if (task.taskType == 'Reading' && 
              task.pageRanges != null && 
              task.pageRanges!.isNotEmpty) {
      // Add up all pages across all ranges
      total = task.pageRanges!.fold(0, (sum, r) => sum! + ((r['end'] as int) - (r['start'] as int) + 1));
    } else {
      return null; // unsupported task type
    }

    if (total == null || total <= 0) return null;

    final double perDay = total / workDays;
    final int perDayFloor = perDay.floor();
    final int firstDay = total - (perDayFloor * (workDays - 1));

    return TaskSchedule(
      total: total,
      daysToComplete: workDays,
      firstDayCount: firstDay,
      remainingDaysCount: perDayFloor,
      remainingDays: daysUntilDue,
      unit: task.taskType == 'Problem Set' ? 'problems' : 'pages',
      taskTitle: task.title,       // ← new
      difficulty: task.taskDifficulty, // ← new
    );
  }

  // For bar graph
  List<DayWorkload> calculateThreeWeekSchedule() {
    const int softCapMinutes = 150;     // ← daily target
    const int hardCapMinutes = 480;     // ← 8 hour max
    const int totalDays = 21;
    const int minutesPerUnit = 15;

    // Initialize 21 days
    final List<DayWorkload> schedule =
        List.generate(totalDays, (i) => DayWorkload(dayIndex: i));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get valid tasks - no completed, no overdue, only Problem Set and Reading
    final validTasks = _tasks.where((t) {
      if (t.isCompleted) return false;
      if (t.taskType != 'Problem Set' && t.taskType != 'Reading') return false;
      if (t.dueDate == null) return false;
      final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      if (due.isBefore(today)) return false;
      if (t.taskType == 'Problem Set' && t.questionCount == null) return false;
      if (t.taskType == 'Reading' &&
          (t.pageRanges == null || t.pageRanges!.isEmpty)) return false;
      return true;
    }).toList();

    // Sort by priority: sooner due date first, then harder difficulty
    validTasks.sort((a, b) {
      final dueCmp = a.dueDate!.compareTo(b.dueDate!);
      if (dueCmp != 0) return dueCmp;
      return _difficultyRank(a.taskDifficulty)
          .compareTo(_difficultyRank(b.taskDifficulty));
    });

    // First pass: schedule within soft cap (150 min)
    for (final task in validTasks) {
      final taskSchedule = calculateTaskSchedule(task);
      if (taskSchedule == null) continue;

      final due = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      final daysUntilDue = due.difference(today).inDays.clamp(0, totalDays);

      final int firstDayMinutes = taskSchedule.firstDayCount * minutesPerUnit;
      final int restDayMinutes = taskSchedule.remainingDaysCount * minutesPerUnit;
      final int workDays = taskSchedule.daysToComplete;

      // Find first day within soft cap before due date
      int startDay = 0;
      bool fitsInSoftCap = false;
      for (int d = 0; d < daysUntilDue && d < totalDays; d++) {
        if (schedule[d].totalMinutes < softCapMinutes) {
          startDay = d;
          fitsInSoftCap = true;
          break;
        }
      }

      if (!fitsInSoftCap) {
        // Mark task for second pass (hard cap)
        task.needsHardCap = true;  // ← we'll add this field
        continue;
      }

      // Place within soft cap
      _placeMinutes(
        schedule: schedule,
        startDay: startDay,
        minutes: firstDayMinutes,
        taskTitle: task.title,
        difficulty: task.taskDifficulty,
        cap: softCapMinutes,
        totalDays: daysUntilDue.clamp(0, totalDays),
      );

      // Place remaining days
      for (int i = 1; i < workDays; i++) {
        final targetDay = startDay + i;
        if (targetDay >= totalDays || targetDay >= daysUntilDue) break;
        _placeMinutes(
          schedule: schedule,
          startDay: targetDay,
          minutes: restDayMinutes,
          taskTitle: task.title,
          difficulty: task.taskDifficulty,
          cap: softCapMinutes,
          totalDays: daysUntilDue.clamp(0, totalDays),
        );
      }
    }

    // Update soft cap flags
    for (final day in schedule) {
      if (day.totalMinutes >= softCapMinutes) {
        day.isDailyTargetReached = true;
      }
    }

    // Second pass: tasks that didn't fit in soft cap now use hard cap
    for (final task in validTasks) {
      if (!task.needsHardCap) continue;

      final taskSchedule = calculateTaskSchedule(task);
      if (taskSchedule == null) continue;

      final due = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      final daysUntilDue = due.difference(today).inDays.clamp(0, totalDays);

      final int firstDayMinutes = taskSchedule.firstDayCount * minutesPerUnit;
      final int restDayMinutes = taskSchedule.remainingDaysCount * minutesPerUnit;
      final int workDays = taskSchedule.daysToComplete;

      // Find first available day within hard cap
      int startDay = 0;
      for (int d = 0; d < totalDays; d++) {
        if (schedule[d].totalMinutes < hardCapMinutes) {
          startDay = d;
          break;
        }
      }

      _placeMinutes(
        schedule: schedule,
        startDay: startDay,
        minutes: firstDayMinutes,
        taskTitle: task.title,
        difficulty: task.taskDifficulty,
        cap: hardCapMinutes,
        totalDays: totalDays,
      );

      for (int i = 1; i < workDays; i++) {
        final targetDay = startDay + i;
        if (targetDay >= totalDays) break;
        _placeMinutes(
          schedule: schedule,
          startDay: targetDay,
          minutes: restDayMinutes,
          taskTitle: task.title,
          difficulty: task.taskDifficulty,
          cap: hardCapMinutes,
          totalDays: totalDays,
        );
      }
    }

    // Update hard cap flags
    for (final day in schedule) {
      if (day.totalMinutes >= hardCapMinutes) {
        day.isOverflowed = true;
      }
    }

    return schedule;
  }

  // Places minutes with Option B overflow (fills current day, spills rest)
  void _placeMinutes({
    required List<DayWorkload> schedule,
    required int startDay,
    required int minutes,
    required String taskTitle,
    required String difficulty,
    required int cap,           // ← now accepts either soft or hard cap
    required int totalDays,
  }) {
    int remainingMinutes = minutes;
    int currentDay = startDay;

    while (remainingMinutes > 0 && currentDay < totalDays) {
      final available = cap - schedule[currentDay].totalMinutes;

      if (available <= 0) {
        currentDay++;
        continue;
      }

      final toPlace = remainingMinutes <= available ? remainingMinutes : available;

      schedule[currentDay].totalMinutes += toPlace;
      schedule[currentDay].tasks.add(TaskMinutes(
        taskTitle: taskTitle,
        minutes: toPlace,
        difficulty: difficulty,
      ));

      remainingMinutes -= toPlace;
      if (remainingMinutes > 0) currentDay++;
    }
  }

  // Hard = 0 (highest priority), Medium = 1, Easy = 2 (lowest priority)
  int _difficultyRank(String difficulty) {
    if (difficulty == 'Hard') return 0;
    if (difficulty == 'Medium') return 1;
    return 2;
  }
}
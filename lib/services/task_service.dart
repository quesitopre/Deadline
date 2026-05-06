import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/task_schedule.dart';

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
      unit: task.taskType == 'Problem Set' ? 'problems' : 'pages', // ← new
    );
  }
}
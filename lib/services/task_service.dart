import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

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
            : null,                    // ← new
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
    }).toList();
    await prefs.setString('tasks', jsonEncode(taskList));
  }

  Future<void> addTask(String title, String description, {DateTime? dueDate, String taskType = 'Other', List<Map<String, int>>? pageRanges}) async {
    _tasks.add(Task(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      isCompleted: false,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      taskType: taskType,
      pageRanges: pageRanges,    // ← new
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

  
}
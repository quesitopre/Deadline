import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  static const String _key = 'tasks';

  // Save tasks to storage
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = tasks.map((t) => {
      'id': t.id,
      'title': t.title,
      'description': t.description,
      'isCompleted': t.isCompleted,
      'createdAt': t.createdAt.toString(),
    }).toList();
    prefs.setString(_key, jsonEncode(taskList));
  }

  // Load tasks from storage
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];

    final List decoded = jsonDecode(data);
    return decoded.map((t) => Task(
      id: t['id'],
      title: t['title'],
      description: t['description'],
      isCompleted: t['isCompleted'],
      createdAt: DateTime.parse(t['createdAt']),
    )).toList();
  }
}
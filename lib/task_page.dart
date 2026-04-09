import 'package:flutter/material.dart';
import 'services/task_service.dart';
import 'models/task.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    await _taskService.initialize(); // ← initialize first
    setState(() {
      _tasks = _taskService.getTasks();
    });
  }

  void _addTask(String title, DateTime? dueDate, String taskType, List<Map<String, int>>? pageRanges) async {
    await _taskService.addTask(title, '', dueDate: dueDate, taskType: taskType, pageRanges: pageRanges);
    setState(() {
      _tasks = _taskService.getTasks();
    });
  }

  void _toggleTask(String id) async {
    await _taskService.toggleTask(id);
    setState(() {
      _tasks = _taskService.getTasks();
    });
  }

  void _deleteTask(String id) async {
    await _taskService.deleteTask(id);
    setState(() {
      _tasks = _taskService.getTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add task button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddTaskDialog(context),
            icon: Icon(Icons.add),
            label: Text('Add Task'),
          ),
        ),
        // Task list
        Expanded(
          child: ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              return ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => _toggleTask(task.id),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type: ${task.taskType}'),
                    if (task.dueDate != null)
                      Text('Due: ${task.dueDate!.month}/${task.dueDate!.day}/${task.dueDate!.year}'),
                    if (task.pageRanges != null && task.pageRanges!.isNotEmpty)
                      Text('Pages: ${task.pageRanges!.map((r) => '${r['start']}-${r['end']}').join(', ')}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTask(task.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    DateTime? selectedDate;
    String selectedType = 'Other';
    List<Map<String, TextEditingController>> pageRanges = [
      {
        'start': TextEditingController(),
        'end': TextEditingController(),
      }
    ];

    final List<String> taskTypes = [
      'Problem Set',
      'Reading',
      'Essay',
      'Writing',
      'Other'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Task name input
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Enter task title',
                  labelText: 'Task Name',
                ),
              ),
              SizedBox(height: 16),

              // 2. Due date picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? 'No due date selected'
                          : 'Due: ${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_today),
                    label: Text('Pick Date'),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // 3. Task type dropdown
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'Task Type',
                ),
                items: taskTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedType = value!;
                  });
                },
              ),

              // 4. Page ranges - directly below dropdown, only shows for Reading
              if (selectedType == 'Reading') ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Text('Page Ranges', style: TextStyle(fontWeight: FontWeight.bold)),
                    Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          pageRanges.add({
                            'start': TextEditingController(),
                            'end': TextEditingController(),
                            'source': TextEditingController(),
                          });
                        });
                      },
                      icon: Icon(Icons.add),
                      label: Text('Add Range'),
                    ),
                  ],
                ),
                ...pageRanges.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, TextEditingController> range = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: range['start'],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'From',
                                  hintText: '1',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('to'),
                            ),
                            Expanded(
                              child: TextField(
                                controller: range['end'],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'To',
                                  hintText: '10',
                                ),
                              ),
                            ),
                            if (pageRanges.length > 1)
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  setDialogState(() {
                                    pageRanges.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  // Convert page ranges to int maps
                  List<Map<String, int>>? ranges;
                  if (selectedType == 'Reading') {
                    ranges = pageRanges
                        .where((r) =>
                            r['start']!.text.isNotEmpty &&
                            r['end']!.text.isNotEmpty)
                        .map((r) => {
                              'start': int.parse(r['start']!.text),
                              'end': int.parse(r['end']!.text),
                            })
                        .toList();
                  }
                  _addTask(titleController.text, selectedDate, selectedType, ranges);
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
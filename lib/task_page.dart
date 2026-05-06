import 'package:flutter/material.dart';
import 'services/task_service.dart';
import 'models/task.dart';
import 'package:deadline_app/models/task_schedule.dart';
import 'package:deadline_app/screens/individual_task_page.dart';
import 'package:deadline_app/models/task_schedule.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  String? _activeFilter; // null means show all tasks
  Map<String, TaskSchedule?> _schedules = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    await _taskService.initialize(); // ← initialize first
    setState(() => _refreshTasks());
  }

  void _addTask(String title, DateTime? dueDate, String taskType, List<Map<String, int>>? pageRanges, int? questionCount, String taskDifficulty) async {
    await _taskService.addTask(title, '', dueDate: dueDate, taskType: taskType, pageRanges: pageRanges, questionCount: questionCount, taskDifficulty: taskDifficulty,);
    setState(() => _refreshTasks());
  }

  void _toggleTask(String id) async {
    await _taskService.toggleTask(id);
    setState(() => _refreshTasks());
  }

  void _deleteTask(String id) async {
    await _taskService.deleteTask(id);
    setState(() => _refreshTasks());
  }

  void _refreshTasks() { //schedule calc extracted to avoid repetition
    _tasks = _taskService.getTasksSortedByDueDate();
    _schedules = {
      for (var task in _tasks)
        task.id: task.taskType == 'Problem Set'
            ? _taskService.calculateProblemSetSchedule(task)
            : null
    };
    //print('Schedules: $_schedules'); for debugging
  }
  
  List<Task> get _filteredTasks {
    if (_activeFilter == null) return _tasks;
    return _tasks.where((t) => t.taskDifficulty == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              // All button
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeFilter = null;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _activeFilter == null ? Colors.blue : Colors.transparent,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'All',
                      style: TextStyle(
                        color: _activeFilter == null ? Colors.white : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Easy, Medium, Hard buttons
              ...['Easy', 'Medium', 'Hard'].map((difficulty) {
                final isSelected = _activeFilter == difficulty;
                final color = difficulty == 'Easy'
                    ? Colors.green
                    : difficulty == 'Medium'
                        ? Colors.orange
                        : Colors.red;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeFilter = isSelected ? null : difficulty;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.transparent,
                        border: Border.all(color: color),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        difficulty,
                        style: TextStyle(
                          color: isSelected ? Colors.white : color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }
            )
          ],
        ),
      ),
        // Add task button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddTaskDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
        ),
        // Task list
        Expanded(
          child: ListView.builder(
            itemCount: _filteredTasks.length,
            itemBuilder: (context, index) {
              final task = _filteredTasks[index];
              return _buildTaskTile(task);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTile(Task task) {
    final schedule = _schedules[task.id];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndividualTaskPage(
              task: task,
              schedule: schedule,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          enabled: schedule != null,
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
          subtitle: _buildTaskSubtitle(task),
          trailing: IconButton(                    // ← only ONE trailing here
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteTask(task.id),
          ),                                      // ← closes ExpansionTile children
        ), 
      ),                                        // ← closes ExpansionTile
    ); 
  }

  Widget _buildTaskSubtitle(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type: ${task.taskType}'),
        Row(
          children: [
            const Text('Difficulty: '),
            Text(
              task.taskDifficulty,
              style: TextStyle(
                color: task.taskDifficulty == 'Easy'
                    ? Colors.green
                    : task.taskDifficulty == 'Medium'
                        ? Colors.orange
                        : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (task.dueDate != null)
          Text('Due: ${task.dueDate!.month}/${task.dueDate!.day}/${task.dueDate!.year}'),
        if (task.pageRanges != null && task.pageRanges!.isNotEmpty)
          Text('Pages: ${task.pageRanges!.map((r) => '${r['start']}-${r['end']}').join(', ')}'),
        if (task.questionCount != null)
          Text('Questions: ${task.questionCount}'),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    DateTime? selectedDate;
    String selectedType = 'Other';
    String selectedDifficulty = 'Easy';
    List<Map<String, TextEditingController>> pageRanges = [
      {
        'start': TextEditingController(),
        'end': TextEditingController(),
      }
    ];
    TextEditingController questionCountController = TextEditingController();

    final List<String> taskTypes = [
      'Problem Set',
      'Reading',
      'Essay',
      'Writing',
      'Other'
    ];

    final List<String> taskDifficulties = [
      'Easy',
      'Medium',
      'Hard'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Task'),
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
              const SizedBox(height: 16),
              // 2. Task Difficulty buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Difficulty', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Easy', 'Medium', 'Hard'].map((difficulty) {
                      final isSelected = selectedDifficulty == difficulty;
                      final color = difficulty == 'Easy'
                          ? Colors.green
                          : difficulty == 'Medium'
                              ? Colors.orange
                              : Colors.red;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedDifficulty = difficulty;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? color : Colors.transparent,
                              border: Border.all(color: color),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              difficulty,
                              style: TextStyle(
                                color: isSelected ? Colors.white : color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 3. Due date picker
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
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Task type dropdown
              DropdownButtonFormField<String>(
                initialValue: selectedType,
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

              // Page ranges - only shows for Reading
              if (selectedType == 'Reading') ...[
                const SizedBox(height: 16),
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
                      icon: const Icon(Icons.add),
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
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
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
                }
              )
           ],
              // Question count - only show for Problem Set
              if (selectedType == 'Problem Set') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: questionCountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Questions',
                    hintText: 'e.g. 20',
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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

                  // Parse question count for Problem Set
                  int? questionCount;
                  if (selectedType == 'Problem Set' && 
                      questionCountController.text.isNotEmpty) {
                    questionCount = int.tryParse(questionCountController.text);
                  }

                  _addTask(titleController.text, selectedDate, selectedType, ranges, questionCount, selectedDifficulty);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
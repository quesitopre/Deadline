import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/task_schedule.dart';
import '../../services/task_service.dart';
import '../../models/subtask.dart';

class IndividualTaskPage extends StatefulWidget {
  final Task task;
  final TaskSchedule? schedule;

  const IndividualTaskPage({
    super.key,
    required this.task,
    this.schedule,
  });

  @override
  State<IndividualTaskPage> createState() => _IndividualTaskPageState();
}

class _IndividualTaskPageState extends State<IndividualTaskPage> {
  final TaskService _taskService = TaskService();
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task; // ← use local copy so we can update it
  }

  Widget build(BuildContext context) {
    /* For testing purposes
    print('Task type: ${task.taskType}');
    print('Task difficulty: ${task.taskDifficulty}');
    print('Question count: ${task.questionCount}');
    print('Due date: ${task.dueDate}');
    print('Schedule: $schedule'); 
    */
    return Scaffold( //basic page structure
      appBar: AppBar( // the top bar with task title
        title: Text(_task.title),
      ),
      body: SingleChildScrollView( // makes page scrollable
        padding: EdgeInsets.all(16), //adds spacing around content
        child: Column( // stacks children vertically
          crossAxisAlignment: CrossAxisAlignment.center, //CrossAxisAlignment.start,
          children: [ // calls each build method to get widgets and stacks them vertically in order
            _buildProgressCircle(context),         
            const SizedBox(height: 16),
            // Congrats banner
            if (_task.allSubtasksCompleted) _buildCongratsBanner(),
            if (_task.allSubtasksCompleted) const SizedBox(height: 16),
            _buildPopUp(context),
            const SizedBox(height: 16),
            _buildInfoCard(context), // card 1: task details
            const SizedBox(height: 16), // spacing between cards
            if (_task.taskType == 'Essay' &&
                _task.subtasks != null)
              _buildSubtaskChecklist(),
            if (widget.schedule != null) _buildScheduleCard(widget.schedule!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final difficultyColor = _task.taskDifficulty == 'Easy'
        ? Colors.green
        : _task.taskDifficulty == 'Medium'
            ? Colors.orange
            : Colors.red;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              _task.title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Divider(),

            // Status
            Row(
              children: [
                Icon(
                  _task.isCompleted ? Icons.check_circle : Icons.pending_actions,
                  color: _task.isCompleted ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  _task.isCompleted ? 'Completed' : 'Pending',
                  style: TextStyle(
                    color: _task.isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Task type
            _buildInfoRow(Icons.category, 'Type', _task.taskType),
            SizedBox(height: 8),

            // Difficulty
            Row(
              children: [
                Icon(Icons.flag, color: difficultyColor),
                SizedBox(width: 8),
                Text('Difficulty: '),
                Text(
                  _task.taskDifficulty,
                  style: TextStyle(
                    color: difficultyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Due date
            if (_task.dueDate != null) ...[
              _buildInfoRow(
                Icons.calendar_today,
                'Due Date',
                '${_task.dueDate!.month}/${_task.dueDate!.day}/${_task.dueDate!.year}',
              ),
              SizedBox(height: 8),
            ],

            // Question count for Problem Set
            if (_task.questionCount != null) ...[
              _buildInfoRow(
                Icons.quiz,
                'Questions',
                '${_task.questionCount}',
              ),
              SizedBox(height: 8),
            ],

            // Page ranges for Reading
            if (_task.pageRanges != null && _task.pageRanges!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.menu_book, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Page Ranges:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ..._task.pageRanges!.map((r) =>
                          Text('  pg. ${r['start']} - ${r['end']}')),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(TaskSchedule schedule) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📅 Recommended Study Schedule',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Divider(),
            _buildScheduleRow(Icons.calculate, 'Total ${schedule.unit}', '${schedule.total}'),
            SizedBox(height: 8),
            _buildScheduleRow(Icons.today, 'Days to Complete', '${schedule.daysToComplete}'),
            SizedBox(height: 8),
            _buildScheduleRow(Icons.hourglass_bottom, 'Days Remaining', '${schedule.remainingDays}'),
            Divider(),
            Row(
              children: [
                Icon(Icons.looks_one, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Day 1: ${schedule.firstDayCount} ${schedule.unit}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Days 2-${schedule.daysToComplete}: ${schedule.remainingDaysCount} ${schedule.unit}/day',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _buildScheduleRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _buildProgressCircle(BuildContext context){
    final percent = _task.progressPercent;
    final percentText = '${(percent * 100).toStringAsFixed(0)}%';

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: CircularProgressIndicator(
            value: percent,
            strokeWidth: 10,
            backgroundColor: Colors.grey[200],
            color: percent == 1.0 ? Colors.green : Colors.blue,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              percentText,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: percent == 1.0 ? Colors.green : Colors.black,
              ),
            ),
            if (percent == 1.0)
              Text(
                'Complete!',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPopUp(BuildContext context) {
    // Only show for Problem Set and Reading
    if (_task.taskType != 'Problem Set' && _task.taskType != 'Reading') {
      return const SizedBox.shrink(); // ← invisible widget for other task types
    }

    return ElevatedButton(
      onPressed: () => _showProgressDialog(context),
      child: Text('Update Progress'),
    );
  }

  void _showProgressDialog(BuildContext context) {
    if (_task.taskType == 'Problem Set') {
      _showProblemSetDialog(context);
    } else if (_task.taskType == 'Reading') {
      _showReadingDialog(context);
    }
  }

  void _showProblemSetDialog(BuildContext context) {
    int currentCount = _task.questionsAnswered ?? 0;
    final int maxCount = _task.questionCount ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Update Progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Questions answered out of $maxCount',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Minus button
                  IconButton(
                    onPressed: currentCount > 0
                        ? () => setDialogState(() => currentCount--)
                        : null,
                    icon: Icon(Icons.remove_circle, size: 36),
                    color: Colors.red,
                  ),
                  SizedBox(width: 16),
                  // Current count display
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text(
                      '$currentCount',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Plus button
                  IconButton(
                    onPressed: currentCount < maxCount
                        ? () => setDialogState(() => currentCount++)
                        : null,
                    icon: Icon(Icons.add_circle, size: 36),
                    color: Colors.green,
                  ),
                ],
              ),
              // Progress preview
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: maxCount > 0 ? currentCount / maxCount : 0,
                backgroundColor: Colors.grey[200],
                color: currentCount == maxCount ? Colors.green : Colors.blue,
              ),
              SizedBox(height: 4),
              Text(
                maxCount > 0
                    ? '${(currentCount / maxCount * 100).toStringAsFixed(0)}%'
                    : '0%',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _taskService.updateProgress(
                  _task.id,
                  questionsAnswered: currentCount,
                );
                // Refresh local task
                setState(() {
                  _task.questionsAnswered = currentCount;
                  if (currentCount >= maxCount) {
                    _task.isCompleted = true;
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReadingDialog(BuildContext context) {
    final TextEditingController pageController = TextEditingController(
      text: _task.currentPage?.toString() ?? 
            _task.pageRanges!.first['start'].toString(),
    );
    String? errorText;

    // Get valid page range bounds
    final int firstPage = _task.pageRanges!.first['start'] as int;
    final int lastPage = _task.pageRanges!.last['end'] as int;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Update Progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the page you read up to',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Text(
                'Valid range: pg. $firstPage - $lastPage',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              SizedBox(height: 16),
              TextField(
                controller: pageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Current Page',
                  hintText: 'e.g. $firstPage',
                  errorText: errorText,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final int? page = int.tryParse(pageController.text);

                // Validate
                if (page == null) {
                  setDialogState(() => errorText = 'Please enter a valid number');
                  return;
                }
                if (page < firstPage || page > lastPage) {
                  setDialogState(() => errorText = 'Page must be between $firstPage and $lastPage');
                  return;
                }

                await _taskService.updateProgress(
                  _task.id,
                  currentPage: page,
                );
                // Refresh local task
                setState(() {
                  _task.currentPage = page;
                  if (page >= lastPage) {
                    _task.isCompleted = true;
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildCongratsBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration, color: Colors.green),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Congratulations! 🎉',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'All subtasks complete! You may now mark this task as complete.',
                  style: TextStyle(color: Colors.green[700], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskChecklist() {
    // Find the first incomplete subtask index for locking
    final firstIncompleteIndex = _task.subtasks!
        .indexWhere((s) => !s.isCompleted);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📝 Essay Subtasks',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Divider(),
            ..._task.subtasks!.asMap().entries.map((entry) {
              final index = entry.key;
              final subtask = entry.value;

              // Locked if a previous subtask is not complete
              final bool isLocked = index > 0 &&
                  !_task.subtasks![index - 1].isCompleted;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // Checkbox
                    Checkbox(
                      value: subtask.isCompleted,
                      onChanged: isLocked
                          ? null  // ← disabled if locked
                          : (value) async {
                              await _taskService.toggleSubtask(
                                _task.id,
                                subtask.id,
                                value ?? false,
                              );
                              // Reload task to reflect changes
                              final updatedTasks = _taskService.getTasks();
                              final updatedTask = updatedTasks
                                  .firstWhere((t) => t.id == _task.id);
                              setState(() => _task = updatedTask);
                            },
                    ),
                    // Lock icon if locked
                    if (isLocked)
                      Icon(Icons.lock, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    // Subtask info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subtask.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: subtask.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: isLocked
                                  ? Colors.grey
                                  : subtask.isCompleted
                                      ? Colors.green
                                      : Colors.black,
                            ),
                          ),
                          Text(
                            '${subtask.totalMinutes} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (subtask.completedAt != null)
                            Text(
                              'Completed: ${subtask.completedAt!.month}/${subtask.completedAt!.day}/${subtask.completedAt!.year}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[400],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Completion icon
                    if (subtask.isCompleted)
                      Icon(Icons.check_circle, color: Colors.green),
                    if (isLocked)
                      Icon(Icons.lock_outline, color: Colors.grey[400]),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
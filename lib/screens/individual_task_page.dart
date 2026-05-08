import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/task_schedule.dart';
import '../../services/task_service.dart';

class IndividualTaskPage extends StatelessWidget {
  final Task task;
  final TaskSchedule? schedule;

  const IndividualTaskPage({
    super.key,
    required this.task,
    this.schedule,
  });

  @override
  
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
        title: Text(task.title),
      ),
      body: SingleChildScrollView( // makes page scrollable
        padding: EdgeInsets.all(16), //adds spacing around content
        child: Column( // stacks children vertically
          crossAxisAlignment: CrossAxisAlignment.center, //CrossAxisAlignment.start,
          children: [ // calls each build method to get widgets and stacks them vertically in order
            _buildProgressCircle(context),         
            const SizedBox(height: 16),
            _buildPopUp(context),
            const SizedBox(height: 16),
            _buildInfoCard(context), // card 1: task details
            const SizedBox(height: 16), // spacing between cards
            if (schedule != null) _buildScheduleCard(schedule!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final difficultyColor = task.taskDifficulty == 'Easy'
        ? Colors.green
        : task.taskDifficulty == 'Medium'
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
              task.title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Divider(),

            // Status
            Row(
              children: [
                Icon(
                  task.isCompleted ? Icons.check_circle : Icons.pending_actions,
                  color: task.isCompleted ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  task.isCompleted ? 'Completed' : 'Pending',
                  style: TextStyle(
                    color: task.isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Task type
            _buildInfoRow(Icons.category, 'Type', task.taskType),
            SizedBox(height: 8),

            // Difficulty
            Row(
              children: [
                Icon(Icons.flag, color: difficultyColor),
                SizedBox(width: 8),
                Text('Difficulty: '),
                Text(
                  task.taskDifficulty,
                  style: TextStyle(
                    color: difficultyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Due date
            if (task.dueDate != null) ...[
              _buildInfoRow(
                Icons.calendar_today,
                'Due Date',
                '${task.dueDate!.month}/${task.dueDate!.day}/${task.dueDate!.year}',
              ),
              SizedBox(height: 8),
            ],

            // Question count for Problem Set
            if (task.questionCount != null) ...[
              _buildInfoRow(
                Icons.quiz,
                'Questions',
                '${task.questionCount}',
              ),
              SizedBox(height: 8),
            ],

            // Page ranges for Reading
            if (task.pageRanges != null && task.pageRanges!.isNotEmpty) ...[
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
                      ...task.pageRanges!.map((r) =>
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
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: CircularProgressIndicator(
            value: 0.7,
            strokeWidth: 10,
            backgroundColor: Colors.grey[200],
          ),
        ),
        Text("70%", style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPopUp(BuildContext context){
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Update Progress"),
              content: Text("This is a simple pop-up message."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Closes the dialog
                  child: Text("Save"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context), // Closes the dialog
                  child: Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
      child: Text("Update Progress?"),
    );
  }
}
import 'package:flutter/material.dart';
import 'services/task_service.dart';
import 'models/task.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<Dashboard> {
  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    await _taskService.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = _taskService.getTasks();
    final dueSoonTasks = allTasks.where((t) =>
      t.dueDate != null &&
      !t.isCompleted && 
      //Easy
      ((t.taskDifficulty == "Easy" && t.dueDate!.isBefore(DateTime.now().add(const Duration(days: 2))))
      //Medium
      || (t.taskDifficulty == "Medium" && t.dueDate!.isBefore(DateTime.now().add(const Duration(days: 4))))
      //Hard
      || (t.taskDifficulty == "Hard" && t.dueDate!.isBefore(DateTime.now().add(const Duration(days: 7))))
      )).toList();
    final pendingTasks = _taskService.getPendingTasks();
    final hoursUntilDue = _taskService.hoursUntilNearestTask();
    final hoursPastDue = _taskService.hoursSinceNearestTaskOverdue();
    final completedTasks = _taskService.getCompletedTasks();
    final atRiskTasks = allTasks.where((t) =>
      t.dueDate != null &&
      !t.isCompleted &&  
      (t.dueDate!.isBefore(DateTime.now()) || //tasks with already past due dates, tasks due today or now
      (t.dueDate!.year == DateTime.now().year &&
      t.dueDate!.month == DateTime.now().month &&
      t.dueDate!.day == DateTime.now().day))).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                label: 'Due Soon',
                count: dueSoonTasks.length,
                color: Colors.blue,
                icon: Icons.bolt,
              ),
              _buildStatCard(
                label: 'Total Tasks',
                count: pendingTasks.length,
                color: Colors.orange,
                icon: Icons.pending_actions,
              ),
              _buildNextDueCard(hoursUntilDue,hoursPastDue),
              _buildStatCard(
                label: 'At Risk',
                count: atRiskTasks.length,
                color: Colors.red,
                icon: Icons.warning_amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            SizedBox(height: 12),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextDueCard(int hoursUntilDue, int hoursPastDue) {
    final color = hoursUntilDue == 0 ? Colors.red : Colors.blue;
    final icon = hoursUntilDue == 0 ? Icons.warning_amber : Icons.timer;

    // Smart display - show days if over 48 hours
    final String countText;
    final String labelText;

    if (hoursUntilDue == 0 && hoursPastDue >= 48) {
      countText = '${(hoursPastDue / 24).floor()}d';
      labelText = 'Days Since Overdue';
    }else if(hoursPastDue == 999){
      countText = 'Over a Month';
      labelText = 'Time Since Overdue';
    }else if(hoursUntilDue == 0){
      countText = '${hoursPastDue}h';
      labelText = 'Hours Since Overdue';
    }else if(hoursUntilDue == 999){
      countText = 'Over a Month';
      labelText = 'Time Until Due';
    } else if (hoursUntilDue >= 48) {
      countText = '${(hoursUntilDue / 24).floor()}d';
      labelText = 'Days Until Due';
    } else {
      countText = '${hoursUntilDue}h';
      labelText = 'Hours Until Due';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            SizedBox(height: 12),
            Text(
              countText,
              style: TextStyle(
                fontSize: 32,          // ← slightly smaller than before
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              labelText,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
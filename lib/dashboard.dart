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
    final timeBeforeNearestTaskisDue = DateTime.now().subtract(const Duration(days: 2));
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
              _buildStatCard(
                label: 'Hours Left',
                count: completedTasks.length,
                color: Colors.green,
                icon: Icons.timelapse,
              ),
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
}
import 'package:flutter/material.dart';
import '../models/day_schedule.dart';

class WorkloadGraph extends StatelessWidget {
  final List<DayWorkload> schedule;
  const WorkloadGraph({super.key, required this.schedule});

  static const int maxMinutes = 480;

  Color _difficultyColor(String difficulty) {
    if (difficulty == 'Easy') return Colors.green;
    if (difficulty == 'Medium') return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 3-Week Workload',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        // Legend
        Row(
          children: [
            _buildLegendItem('Easy', Colors.green),
            SizedBox(width: 12),
            _buildLegendItem('Medium', Colors.orange),
            SizedBox(width: 12),
            _buildLegendItem('Hard', Colors.red),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: schedule.length,
            itemBuilder: (context, index) {
              return _buildDayBar(context, schedule[index], index);
            },
          ),
        ),
        SizedBox(height: 4),
        // Week labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Week 1', style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text('Week 2', style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text('Week 3', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildDayBar(BuildContext context, DayWorkload day, int index) {
    final bool isHardCapped = day.isOverflowed;
    final bool isSoftCapped = day.isDailyTargetReached && !isHardCapped;
    final double fillRatio = (day.totalMinutes / 480).clamp(0.0, 1.0);
    final String label = index == 0 ? 'Today' : 'D${index + 1}';

    return GestureDetector(
      onTap: () => _showDayDetails(context, day, index),
      child: Container(
        width: 32,
        margin: EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
           // Cap labels
            if (isHardCapped) // 8hrs+ label if full
              Text('8h+', style: TextStyle(fontSize: 8, color: Colors.red)),
            if (isSoftCapped)
              Text('2.5h+', style: TextStyle(fontSize: 8, color: Colors.orange)),
            // Bar
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: day.tasks.isEmpty
                    ? Container(
                        width: 28,
                        height: 4,
                        color: Colors.grey[300],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: _buildStackedBar(day, fillRatio),
                      ),
              ),
            ),
            SizedBox(height: 4),
            // Day label
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight:
                    index == 0 ? FontWeight.bold : FontWeight.normal,
                color: index == 0 ? Colors.blue : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds stacked colored segments per task
  List<Widget> _buildStackedBar(DayWorkload day, double fillRatio) {
    const double maxBarHeight = 140;
    return day.tasks.reversed.map((task) {
      final double taskRatio = task.minutes / maxMinutes;
      final double barHeight = (taskRatio * maxBarHeight).clamp(2.0, maxBarHeight);
      return Container(
        width: 28,
        height: barHeight,
        color: _difficultyColor(task.difficulty),
      );
    }).toList();
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  // Tap a bar to see task breakdown for that day
  void _showDayDetails(BuildContext context, DayWorkload day, int index) {
    final String dayLabel = index == 0 ? 'Today' : 'Day ${index + 1}';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$dayLabel — ${day.totalMinutes} min'),
        content: day.tasks.isEmpty
            ? Text('No tasks scheduled')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: day.tasks.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: _difficultyColor(t.difficulty),
                      ),
                      SizedBox(width: 8),
                      Expanded(child: Text(t.taskTitle)),
                      Text('${t.minutes} min'),
                    ],
                  ),
                )).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
//Revamp

import 'dart:async';
import 'package:flutter/material.dart';

enum TimerMode { study, shortBreak, longBreak }

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? _timer;
  bool _isRunning = false;

  TimerMode _currentMode = TimerMode.study;
  int _pomodoroCount = 0; // how many study sessions completed

  // Durations in seconds
  final Map<TimerMode, int> _durations = {
    TimerMode.study: 25 * 60,
    TimerMode.shortBreak: 5 * 60,
    TimerMode.longBreak: 15 * 60,
  };

  late int _seconds;

  // Mode display config
  final Map<TimerMode, Map<String, dynamic>> _modeConfig = {
    TimerMode.study: {
      'label': 'Study Session',
      'icon': Icons.menu_book,
      'color': Color(0xFF4A6FA5),
    },
    TimerMode.shortBreak: {
      'label': 'Short Break',
      'icon': Icons.coffee,
      'color': Color(0xFF57A773),
    },
    TimerMode.longBreak: {
      'label': 'Long Break',
      'icon': Icons.weekend,
      'color': Color(0xFFE07A5F),
    },
  };

  @override
  void initState() {
    super.initState();
    _seconds = _durations[_currentMode]!;
  }

  void _switchMode(TimerMode mode) {
    _timer?.cancel();
    setState(() {
      _currentMode = mode;
      _seconds = _durations[mode]!;
      _isRunning = false;
    });
  }

  void startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
        setState(() {
          _isRunning = false;
          // Auto-advance logic
          if (_currentMode == TimerMode.study) {
            _pomodoroCount++;
            // Every 4 study sessions, take a long break
            if (_pomodoroCount % 4 == 0) {
              _switchMode(TimerMode.longBreak);
            } else {
              _switchMode(TimerMode.shortBreak);
            }
          } else {
            _switchMode(TimerMode.study);
          }
        });
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = _durations[_currentMode]!;
      _isRunning = false;
    });
  }

  void resetAll() {
    _timer?.cancel();
    setState(() {
      _currentMode = TimerMode.study;
      _seconds = _durations[TimerMode.study]!;
      _isRunning = false;
      _pomodoroCount = 0;
    });
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    final total = _durations[_currentMode]!;
    return 1 - (_seconds / total);
  }

  Color get _currentColor => _modeConfig[_currentMode]!['color'] as Color;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _modeConfig[_currentMode]!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [

            // Mode selector tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: TimerMode.values.map((mode) {
                  final isSelected = _currentMode == mode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _switchMode(mode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? _modeConfig[mode]!['color'] as Color : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _modeConfig[mode]!['label'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 36),

            // Circular progress + timer
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(_currentColor),
                  ),
                ),
                Column(
                  children: [
                    Icon(config['icon'] as IconData, size: 28, color: _currentColor),
                    const SizedBox(height: 8),
                    Text(
                      formatTime(_seconds),
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: _currentColor,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      config['label'] as String,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Pomodoro session dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < (_pomodoroCount % 4 == 0 && _pomodoroCount > 0
                    ? 4
                    : _pomodoroCount % 4);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? _modeConfig[TimerMode.study]!['color'] as Color : Colors.grey[300],
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Text(
              'Session ${(_pomodoroCount % 4) + 1} of 4 — Pomodoro #${(_pomodoroCount ~/ 4) + 1}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),

            const SizedBox(height: 32),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : startTimer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _isRunning ? stopTimer : null,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Reset all sessions
            TextButton.icon(
              onPressed: resetAll,
              icon: const Icon(Icons.restart_alt, size: 16),
              label: const Text('Reset all sessions'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
            ),

            const SizedBox(height: 24),

            // Tips card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _currentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _currentColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: _currentColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentMode == TimerMode.study
                          ? 'Stay focused! Close distracting tabs and put your phone away.'
                          : _currentMode == TimerMode.shortBreak
                              ? 'Stretch, grab some water, and rest your eyes.'
                              : 'Great work! Take a proper break — go for a walk or have a snack.',
                      style: TextStyle(fontSize: 13, color: _currentColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
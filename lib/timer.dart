import 'dart:async';
import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? _timer;
  int _seconds = 0;
  int _setDuration = 10; // default duration
  bool _isRunning = false;

  void startTimer() {
    if (_isRunning) return; // prevent double-starting

    setState(() {
      _seconds = _setDuration;
      _isRunning = true;
    });

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_seconds == 0) {
        setState(() {
          timer.cancel();
          _isRunning = false;
        });
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = _setDuration;
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Formats seconds as MM:SS
  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Timer display
        Text(
          formatTime(_seconds),
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 12),

        // Status label
        Text(
          _isRunning ? 'Running...' : (_seconds == 0 ? 'Done!' : 'Paused'),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 40),

        // Duration picker
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Duration (min): '),
            DropdownButton<int>(
              value: _setDuration ~/ 60 == 0 ? null : _setDuration ~/ 60,
              hint: const Text('Select'),
              items: [1, 5, 10, 15, 25, 30, 45, 60]
                  .map((m) => DropdownMenuItem(value: m, child: Text('$m min')))
                  .toList(),
              onChanged: _isRunning
                  ? null // disable while running
                  : (val) {
                      if (val != null) {
                        setState(() {
                          _setDuration = val * 60;
                          _seconds = _setDuration;
                        });
                      }
                    },
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _isRunning ? null : startTimer,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _isRunning ? stopTimer : null,
              icon: const Icon(Icons.pause),
              label: const Text('Stop'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: resetTimer,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}
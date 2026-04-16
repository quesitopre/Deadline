import 'package:flutter/material.dart';
import 'package:deadline_app/styled_page_name.dart';
import 'package:deadline_app/task_page.dart';
import 'package:deadline_app/timer.dart';
import 'package:deadline_app/blocker.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  //List of page titles
  final List<String> _pageTitles = [
    'Dashboard', 'Task', 'Timer', 'Blocker', 'Profile'
  ];

  final List<Widget> _pages = [
    const Placeholder(),   // Dashboard (not built yet)
    const TaskPage(),   // Task (not built yet)
    const TimerPage(),     // Timer ✅
    const AppBlocker(),    // Blocker ✅
    const Placeholder(),   // Profile (not built yet)
  ];

  //bottom Navigation bar
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: StyledPageName(pageTitle: _pageTitles[_selectedIndex]),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Task'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.app_blocking), label: 'Blocker'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }
}
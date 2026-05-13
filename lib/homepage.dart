import 'package:flutter/material.dart';
import 'package:deadline_app/styled_page_name.dart';
import 'package:deadline_app/task_page.dart';
import 'package:deadline_app/timer.dart';
import 'package:deadline_app/blocker.dart';
import 'package:deadline_app/dashboard.dart';
import 'package:deadline_app/profile.dart';
import 'package:deadline_app/course.dart';

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

  late final List<Widget> _pages;
  
  @override
  void initState(){
    super.initState();
    _pages = [
    const Dashboard(),   // Dashboard (not built yet)
    TaskPage(),   // Task (not built yet) const might not be needed for this
    const TimerPage(),     // Timer ✅
    const AppBlocker(),    // Blocker ✅
    Profile(studentName: 'studentName', studentID: 'studentID', email: 'email', courses: const [
    Course(
      name: 'Computer Science 101',
      code: 'CS101',
      subject:'Computer Science',
      grade: 91.5,
      creditHours: 3,
    ),
    Course(
      name: 'Calculus II',
      code: 'MATH202',
      subject:'Mathematics',
      grade: 78.0,
      creditHours: 4,
    ),
   ],
  ),
  ];
}

  //bottom Navigation bar
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
      // Rebuild dashboard every time Home tab is selected
      if (index == 0) {
        _pages[0] = Dashboard();
      }
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: StyledPageName(pageTitle: _pageTitles[_selectedIndex]),
      body: 
      IndexedStack(
        index: _selectedIndex,
        children:_pages,
      ),
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

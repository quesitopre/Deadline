import 'package:flutter/material.dart';
import 'package:deadline_app/styled_page_name.dart';
import 'package:deadline_app/task_page.dart';
import 'package:deadline_app/blocker.dart';

class Homepage extends StatefulWidget{
const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}
  class  _HomepageState extends State<Homepage>{
    int _selectedIndex = 0;

    final List<Widget> _pages = [
      Center(child: Text('Home Page')),  // index 0 - Home
      TaskPage(),                         // index 1 - Task
      Center(child: Text('Timer')),       // index 2 - Timer
      AppBlocker(),                          // index 3 - Blocker
      Center(child: Text('Profile')),     // index 4 - Profile
    ];
 
  //List of page titles
  final List<String> _pageTitles = [
    'Dashboard','Task','Timer','Blocker','Profile'
  ];

  //bottom Navigation bar
  void navigateBottomBar(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

    @override
  Widget build(context){
      return Scaffold(
        appBar: StyledPageName(pageTitle: _pageTitles[_selectedIndex]),
        //body: Center(
         // child: StyledPageName('Dashboard'),
        //),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex, // when user selects a tab to navigate to
          onTap: navigateBottomBar,
        type: BottomNavigationBarType.fixed,
      
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Task'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.app_blocking), label: 'Blocker'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ]
        ),
    );
  } 
}
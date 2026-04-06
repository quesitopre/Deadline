import 'package:deadline_app/blocker.dart';
import 'package:flutter/material.dart';
import 'package:deadline_app/styled_page_name.dart';

class Homepage extends StatefulWidget{
const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}
  class  _HomepageState extends State<Homepage>{
    int _selectedIndex = 0;
    
  //List of page titles
  final List<String> _pageTitles = [
    'Dashboard','Task','Timer','Blocker','Profile'
  ];

  final List<Widget> _pages =[
    const Center(child: Text('Dashboard')), // placeholder 
    const Center(child: Text('Task')),  //placeholder
    const Center(child : Text('Timer')), // placeholder
    const AppBlocker(),
    const Center(child: Text('Profile')), // placeholder
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
        body:
         _pages[_selectedIndex],

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
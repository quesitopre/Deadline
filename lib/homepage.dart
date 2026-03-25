import 'package:flutter/material.dart';
import 'package:deadline_app/styled_page_name.dart';
import 'package:deadline_app/styled_page_name.dart';
class Homepage extends StatefulWidget{
const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}
  class  _HomepageState extends State<Homepage>{
    int _selectedIndex = 0;

  void navigateBottomBar(int index){
    setState(() {
      _selectedIndex = index;
    });
  }
    @override
  Widget build(context){
      return Scaffold(
        body: Center(
          child: StyledPageName('Dashboard'),
          
        ),
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
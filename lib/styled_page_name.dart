import 'package:flutter/material.dart';

class StyledPageName extends StatelessWidget implements PreferredSizeWidget{
  
   const StyledPageName({super.key, required this.pageTitle});

    @override 
    Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  final String pageTitle;

  @override
  Widget build(context) {
    return AppBar(
        title: Text(
          pageTitle,
          textAlign: TextAlign.left,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
  }
}
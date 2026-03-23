import 'package:flutter/material.dart';

class StyledPageName extends StatelessWidget{
  const StyledPageName(this.pageTitle, {super.key});
   
  final String pageTitle;

  @override
  Widget build(context) {
    return  Text(
                pageTitle,
                style:TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 40,
                ),
    );
  }
}
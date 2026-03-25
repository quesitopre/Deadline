import 'package:flutter/material.dart';

class StyledPageName extends StatelessWidget{
  const StyledPageName(this.pageTitle, {super.key});
   
  final String pageTitle;

  @override
  Widget build(context) {
    return  Text(
                pageTitle,
                style:const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 40,
                  color: Colors.black87,
                 TextStyle(
                  textAlign: TextAlign.left,
                ),
    );
  }


}
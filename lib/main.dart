import 'package:flutter/material.dart';
import 'package:deadline_app/gradient_container.dart'; //dashboard style sheet

void main() {
  runApp(
     MaterialApp(
      home: Scaffold(
        body: GradientContainer() ,
        appBar: TabBar(tabs: tabs),),
      ),
    );// func. used to run app.
}
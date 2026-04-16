import 'package:flutter/material.dart';
//dashboard style sheet
import 'package:deadline_app/homepage.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
void main() {
  runApp(
     MaterialApp(
      // Scaffold(
       //body: GradientContainer(),
        home: Homepage(),
        ),
     // ),
    );// func. used to run app.
}
// overlay entry point
@pragma("vm:entry-point")
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Material(child: Text("My overlay"))
  ));
}
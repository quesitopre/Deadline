import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:deadline_app/timer.dart';

class FocusOverlay extends StatefulWidget {
  const FocusOverlay({super.key});

  @override
  State<FocusOverlay> createState() => _FocusOverlayState();
}
void main() async{
  //check if overlay permission is granted
  final bool status = await FlutterOverlayWindow.isPermissionGranted();

  /// request overlay permission
 /// it will open the overlay settings page and return `true` once the permission granted.
  FlutterOverlayWindow.requestPermission();
}

class _FocusOverlayState extends State<FocusOverlay> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
    
  }
}
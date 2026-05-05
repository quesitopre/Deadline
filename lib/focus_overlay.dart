import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class FocusOverlay extends StatefulWidget {
  const FocusOverlay({super.key});

  @override
  State<FocusOverlay> createState() => _FocusOverlayState();
}
//void main() async{
  //check if overlay permission is granted
  //final bool status = await FlutterOverlayWindow.isPermissionGranted();

  /// request overlay permission
 /// it will open the overlay settings page and return `true` once the permission granted.
  //FlutterOverlayWindow.requestPermission();
//}

class _FocusOverlayState extends State<FocusOverlay> {
  int _remainingSeconds = 0;
  String _blockedAppName ='';

 @override
 void initState(){
  super.initState();
  //listen for data sent from blocker.dart via shareData()
  FlutterOverlayWindow.overlayListener.listen((data){
    if (data != null && data is Map){
      setState(() {
        _remainingSeconds = data['seconds'] ?? 0;
        _blockedAppName = data['appName'] ?? '';
      });
    }
  });
 }

 String _formatTime(int seconds){
  final m = (seconds ~/60).toString().padLeft(2,'0');
  final s = (seconds % 60).toString().padLeft(2,'0');
  return '$m:$s';
 }

 @override
 Widget build(BuildContext context){
  return Material(
   // color: Colors.black.withOpacity(opacity) //'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss.
    child: SafeArea(
    child: Center(  
      child: Padding( 
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // lock icon circle
            Container(  
              padding: const EdgeInsets.all(22),
              decoration:BoxDecoration( 
                color: Colors.redAccent.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.redAccent, width:2),
              ),
              child: const Icon(Icons.lock, color: Colors.redAccent, size:52),
            ),
            const SizedBox(height:28),

            Text( 
              _blockedAppName.isNotEmpty 
                ? '$_blockedAppName is Blocked'
                : 'App blocked',
              style: const TextStyle(  
                color: Colors.white,
                fontSize:26,
                fontWeight:FontWeight.bold,
              ),
            ),

            const SizedBox(height:12),

            //remaining time displayed
            if(_remainingSeconds >0)...[
              const Text( 
                'Focus time remaining',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text( 
                _formatTime(_remainingSeconds),
                style: const TextStyle( 
                  color: Colors.white,
                  fontSize:56,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ] else...[
              const Text(   
                'Focus session active',
                style: TextStyle( color: Colors.white54, fontSize: 14),
              ),
            ],

          const SizedBox(height: 48),

          SizedBox(  
            width: double.infinity,
            child: ElevatedButton.icon( 
              onPressed: () async{
              await FlutterOverlayWindow.closeOverlay();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go back to Deadline'),
            style: ElevatedButton.styleFrom( 
              backgroundColor: const Color(0xFF4A6FA5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
         ],
      ),
    ),
    ),
    ),
  );
 }
}


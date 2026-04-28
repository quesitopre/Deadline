import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';


class AppBlocker extends StatefulWidget {
  const AppBlocker({super.key});

  @override
  State<AppBlocker> createState() => _BlockerState(); //_BlockerState instantiating
}

class _BlockerState extends State<AppBlocker> with AutomaticKeepAliveClientMixin { //keeps widget alive: toggle alive
 @override 
 bool get wantKeepAlive => true; 


  Future<void> _toggleOverlay(String appName, bool enable) async{
    if(enable) {
      final bool granted = await FlutterOverlayWindow.isPermissionGranted();
      if(!granted) {
        await FlutterOverlayWindow.requestPermission(); // request user permission
        return;
      }
      await FlutterOverlayWindow.showOverlay(
        enableDrag: false,
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.right, // no const name 'fill'
      );
      // send app name to overlay
      await FlutterOverlayWindow.shareData({
        'appName': appName,
        'seconds': 25* 60,
      });
    } else {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  final List<String> appNames =[
    'Instagram', 'Youtube', 'Tiktok','Twitter/X', 'Reddit','Snapchat'
  ];

  final List<bool> AppOnOFF =[
    false,false,false, false, false,false,
  ];

  final List<IconData> appIcons =[
    Icons.camera_alt_outlined,Icons.play_circle,Icons.tiktok, Icons.flutter_dash, Icons.reddit,Icons.snapchat
  ];

  @override 
  void initState(){
    super.initState();
    // Listen for accessibility service telling us a blocked app was opened
    const MethodChannel('deadline_app/blocker').setMethodCallHandler((call) async {
      if (call.method == 'showOverlay') {
        final appName = call.arguments['appName'] as String;
        final index = appNames.indexOf(appName);
        if (index != -1 && AppOnOFF[index]) {
          await _toggleOverlay(appName, true);
        }
      }
    });
  }
  

 @override
  Widget build(BuildContext context) {
    // switch toggle here 
    // beginning of card
    super.build(context);
    return ListView.builder(
      itemCount:appNames.length,
      itemBuilder:(context, index){
        return Card(
          child:Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(appIcons[index]),
                SizedBox(width:15),
                Expanded( child: Text(appNames[index])),
                Switch(
                  value: AppOnOFF[index], 
                  onChanged: (value){
                    setState(() {
                  AppOnOFF[index] = value;
                 });
                 _toggleOverlay(appNames[index], value);
                },
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}
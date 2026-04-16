import 'package:deadline_app/styled_page_name.dart';
//import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AppBlocker extends StatefulWidget {
  const AppBlocker({super.key});

  @override
  State<AppBlocker> createState() => _BlockerState(); //_BlockerState instantiating
}

class _BlockerState extends State<AppBlocker> {
  
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
  Widget build(BuildContext context) {

    // switch toggle here 
    // beginning of card
    return ListView.builder(
      itemCount:appNames.length,
      itemBuilder:(context, index){
        return Card(
          child:Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(appIcons[index]),
                SizedBox(width:12),
                Expanded( child: Text(appNames[index])),
                Switch(
                  value: AppOnOFF[index], 
                  onChanged: (value) {
                    setState(() {
                  AppOnOFF[index] = value;
                 });
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
import 'package:deadline_app/styled_page_name.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AppBlocker extends StatelessWidget{

const AppBlocker({super.key});

  @override 
  Widget build(context){
    return ListView.separated(
      itemCount: 6,
      itemBuilder: (BuildContext context, int index){
        return ListTile(
         title: const Text('Block List'),
         tileColor: Colors.orange.shade50,
         onTap:(){},
         );
      },
      separatorBuilder: (context, index) => const Divider(color: Colors.white,
      ),
    );
  }
}
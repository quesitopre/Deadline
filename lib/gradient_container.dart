import 'package:flutter/material.dart';
import 'package:deadline_app/styledPageName.dart';

const beginAlignment = Alignment.topLeft; 
const endAlignment = Alignment.bottomRight;

class GradientContainer extends StatelessWidget{
  const GradientContainer({super.key}); // constructor function

  @override //annotation
  Widget build(context){
    return Container(
          decoration: const BoxDecoration(
            gradient:LinearGradient(
              colors: [
                Colors.white12,
                ],
                begin: beginAlignment ,
                end: endAlignment,
             ),
            ),
            child: const Center(
              child: StyledPageName('Dashboard'),
      ),
    );
  }
}

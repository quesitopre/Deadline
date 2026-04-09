import 'package:flutter/material.dart';

const beginAlignment = Alignment.topLeft; 
const endAlignment = Alignment.bottomRight;

class GradientContainer extends StatelessWidget{
  const GradientContainer({ super.key}); // constructor function

  @override //annotation
  Widget build(context){
    return Container(
          decoration: const BoxDecoration(
            gradient:LinearGradient(
              colors: [
                Colors.white38,
                Colors.indigo,
                ],
                begin: beginAlignment ,
                end: endAlignment,
             ),
            ),
            child: const Center(
            //  child: StyledPageName('Dashboard'),
      ),
    );
  }
}

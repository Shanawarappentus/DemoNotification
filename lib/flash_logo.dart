import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FlashLogo extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _FlashLogoState();
  }

}

class _FlashLogoState extends State<FlashLogo> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Center(
            child: Lottie.asset('assets/star_animation.json',height: 250,width: 250)),
      ),
    );
  }
}
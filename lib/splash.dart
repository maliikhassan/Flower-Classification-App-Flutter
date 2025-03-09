import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:seeds_classification/HomeScreen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Get.off(HomeScreen()); // Removes splash screen from navigation stack
    });
  }

  @override
  Widget build(BuildContext context) {

    const colorizeColors = [
  Colors.purple,
  Colors.blue,
  Colors.yellow,
  Colors.red,
];

const colorizeTextStyle = TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.bold
);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          spacing: 30,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/anim.json",width: 250),
            AnimatedTextKit(
            animatedTexts: [
        ColorizeAnimatedText(
          'Flower Identifier.',
          textStyle: colorizeTextStyle,
          colors: colorizeColors,
        ),
            ],
            isRepeatingAnimation: true,
            onTap: () {
        print("Tap Event");
            },
          ),
          ],
        ),
      )
    );
  }
}

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/services/auth_wrapper.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  SplashscreenState createState() => SplashscreenState();
}

class SplashscreenState extends State<Splashscreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get the smaller value between width and height for a square size
    double size =
        MediaQuery.of(context).size.width < MediaQuery.of(context).size.height
            ? MediaQuery.of(context).size.width * 0.7
            : MediaQuery.of(context).size.height * 0.7;

    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: LottieBuilder.asset(
              "assets/animation/splash.json",
              width: size, // Set width
              height: size, // Set height equal to width
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      nextScreen: const AuthWrapper(), // Navigate to AuthWrapper after the splash screen
      splashIconSize: size, // Using the same size for both height and width
      backgroundColor: AppColors.primaryBackground,
      splashTransition: SplashTransition.fadeTransition, // Smooth fade effect
      duration: 3000, // Duration in milliseconds
    );
  }
}

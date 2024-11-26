import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Correct import for connectivity check
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:taga_cuyo/src/features/common_widgets/custom_alert_dialog.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/services/auth_wrapper.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  SplashscreenState createState() => SplashscreenState();
}

class SplashscreenState extends State<Splashscreen> {
  ConnectivityResult? _connectivityResult;

  @override
  void initState() {
    super.initState();
    _checkConnectivity(); // Check internet connectivity after splash screen delay

    // Listen for connectivity changes (such as switching between Wi-Fi and mobile data)
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _handleConnectivityChange(result);
    } as void Function(List<ConnectivityResult> event)?);
  }

  // Function to handle connectivity change
  void _handleConnectivityChange(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      // No internet connection, show the dialog
      showCustomAlertDialog(
        context,
        'No Internet Connection',
        'Your internet connection has been lost. Please check your connection.',
        buttonText: 'Close',
      ).then((_) {
        SystemNavigator.pop(); // Close the app if the user clicks "Close"
      });
    } else {
      // If the internet connection is restored, proceed to the next screen
      if (_connectivityResult != ConnectivityResult.none) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    }
    setState(() {
      _connectivityResult = result;
    });
  }

  Future<void> _checkConnectivity() async {
    await Future.delayed(const Duration(seconds: 5)); // Wait for 5 seconds before checking connectivity

    // Check the current network connectivity status
    final connectivityResult = await Connectivity().checkConnectivity();

    // Check if the result is ConnectivityResult.none (no connection)
    if (connectivityResult == ConnectivityResult.none) {
      // If no internet connection, show the custom alert dialog
      if (mounted) {
        showCustomAlertDialog(
          context,
          'No Internet Connection',
          'Please check your internet connection to proceed.',
          buttonText: 'Close',
        ).then((_) {
          // If the user clicks "Close", exit the app
          SystemNavigator.pop(); // Close the app
        });
      }
    } else {
      // Proceed to the next screen if there is an internet connection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
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

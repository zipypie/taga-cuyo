import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/translator/language_model.dart';

class LanguageSwitcher extends StatefulWidget {
  final LanguagePair languagePair;
  final VoidCallback onLanguageSwap;

  const LanguageSwitcher({
    super.key,
    required this.languagePair,
    required this.onLanguageSwap,
  });

  @override
  LanguageSwitcherState createState() => LanguageSwitcherState();
}

class LanguageSwitcherState extends State<LanguageSwitcher> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation1;
  late Animation<Offset> _slideAnimation2;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Initialize the slide animations with adjusted positions
    _slideAnimation1 = Tween<Offset>(begin: Offset(0, 0), end: Offset(1.5, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation2 = Tween<Offset>(begin: Offset(0, 0), end: Offset(-1.5, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void swapLanguages() {
    widget.onLanguageSwap(); // Call the callback to swap languages in TranslatorScreen
    _controller.reset(); // Reset the animation controller
    _controller.forward(from: 0.0); // Restart the slide animation
    setState(() {}); // Ensure the state is updated
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Language 1 container with SlideTransition
            SizedBox(
              width: 100,
              child: SlideTransition(
                position: _slideAnimation1,
                child: Container(
                  key: ValueKey<String>(widget.languagePair.language1), // Use the current language
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    widget.languagePair.language2, // Display language1
                    style: const TextStyle(
                      color: AppColors.titleColor,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.fcr,
                    ),
                  ),
                ),
              ),
            ),
            // Swap Button
            IconButton(
              onPressed: swapLanguages,
              icon: Icon(Icons.swap_horiz),
              color: Colors.grey[600],
              iconSize: 30,
            ),
            // Language 2 container with SlideTransition
            SizedBox(
              width: 100,
              child: SlideTransition(
                position: _slideAnimation2,
                child: Container(
                  key: ValueKey<String>(widget.languagePair.language2), // Use the current language
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    widget.languagePair.language1, // Display language2
                    style: const TextStyle(
                      color: AppColors.titleColor,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.fcr,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller when no longer needed
    super.dispose();
  }
}

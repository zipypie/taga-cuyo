import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/translator/language_model.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/translator/language_switch.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  // Initialize LanguagePair with default languages
  LanguagePair languagePair =
      LanguagePair(language1: 'Tagalog', language2: 'Cuyonon');

  int _inputCharCount = 0;
  int _outputCharCount = 0;

  @override
  void initState() {
    super.initState();

    // Add listeners to update character count dynamically
    _inputController.addListener(() {
      setState(() {
        _inputCharCount = _inputController.text.length;
      });
    });

    _outputController.addListener(() {
      setState(() {
        _outputCharCount = _outputController.text.length;
      });
    });
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the media query data for screen size
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Adjust padding and font sizes based on screen width
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 40 : 20,
          vertical: isLargeScreen ? 40 : 25,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Pass the languagePair to LanguageSwitcher
            LanguageSwitcher(
              languagePair: languagePair,
              onLanguageSwap: _swapLanguages,
            ),
            SizedBox(height: screenHeight * 0.03), // 3% of screen height
            _buildInputContainer(),
            SizedBox(height: screenHeight * 0.02), // 2% of screen height
            _buildOutputContainer(),
            SizedBox(height: screenHeight * 0.04), // 4% of screen height
            MyButton(
              onTab: () {
                setState(() {
                  _outputController.text =
                      _inputController.text; // Copy text from input to output
                });
              },
              text: 'I-translate', // Button label, change it as needed
            )
          ],
        ),
      ),
    );
  }

  void _swapLanguages() {
    setState(() {
      languagePair.swap(); // Swap the languages in the LanguagePair
    });
  }

  Widget _buildInputContainer() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languagePair.language1, // Show the current language1
            style: TextStyle(
              fontSize: screenWidth * 0.05, // Font size based on screen width
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            controller: _inputController,
            maxLines: 5,
            decoration: const InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide.none),
              hintText: "Ilagay ang guston malaman...",
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "$_inputCharCount characters",
              style: TextStyle(
                fontSize: screenWidth * 0.03, // Font size based on screen width
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputContainer() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languagePair.language2, // Show the current language2
            style: TextStyle(
              fontSize: screenWidth * 0.05, // Font size based on screen width
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            controller: _outputController,
            maxLines: 5,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide.none),
              hintText: "Translation will appear here...",
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "$_outputCharCount characters",
              style: TextStyle(
                fontSize: screenWidth * 0.03, // Font size based on screen width
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

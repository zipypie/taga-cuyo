import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taga_cuyo/src/exceptions/logger.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/translator/language_model.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/translator/language_switch.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/translator/translate_service.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/translator/translation_service.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  FirebaseService firebaseService = FirebaseService();
  final TranslationService service = TranslationService();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _outputController =
      TextEditingController(); // Add a new controller for output

  String _translation = "";
  LanguagePair languagePair =
      LanguagePair(language1: 'Tagalog', language2: 'Cuyonon');

  int _inputCharCount = 0;
  int _outputCharCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to update character count dynamically
    _controller.addListener(() {
      setState(() {
        _inputCharCount = _controller.text.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose controllers to avoid memory leaks
    _outputController.dispose(); // Dispose the output controller as well
    super.dispose();
  }

 Future<void> _translateText() async {
  setState(() {
    _isLoading = true; // Start loading when translation starts
  });

  String inputText = _controller.text.trim();

  // Check if the input text ends with a period, question mark, or exclamation mark
  if (!inputText.endsWith(".") &&
      !inputText.endsWith("?") &&
      !inputText.endsWith("!")) {
    // If not, add a space and then a period
    inputText += " .";
  } else {

    inputText += " .";
  }

  try {
    final result = await service.translate(
      inputText,
      sourceLang: languagePair.language1,
      targetLang: languagePair.language2,
    );
    
    setState(() {
      _translation = result;
      _outputCharCount = _translation.length;
      _outputController.text = _translation; // Update output controller text
      _isLoading = false; // Stop loading after translation is complete
    });

    // Save only the sentence and source language to Firebase
    if (result != "Translation failed" && result != "Error: Max retries reached") {
      await firebaseService.saveTranslationToFirebase(inputText, languagePair.language1);
    } else {
      Logger.log("Translation failed or error occurred, not saving to Firestore.");
    }
  } catch (error) {
    setState(() {
      _isLoading = false; // Stop loading if there is an error
    });
    Logger.log("Error during translation: $error");
  }
}


  void _swapLanguages() {
    setState(() {
      languagePair.swap();
    });
    // Reset translation and output fields after swap
    _controller.clear();
    _outputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 40 : 20,
          vertical: isLargeScreen ? 40 : 25,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            LanguageSwitcher(
              languagePair: languagePair,
              onLanguageSwap: _swapLanguages, // Only swap languages
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildInputContainer(),
            SizedBox(height: screenHeight * 0.02),
            _buildOutputContainer(),
            SizedBox(height: screenHeight * 0.018),
            _isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryBackground),
                  ) // Show the loading indicator while translating
                : MyButton(
                    onTab: _translateText, // Trigger translation here
                    text: 'I-translate',
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputContainer() {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Container(
      height: screenHeight * 0.27,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languagePair.language1,
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: const InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide.none),
              hintText: "Ilagay ang gustong malaman...",
              hintStyle: TextStyle(color: Color.fromARGB(221, 89, 86, 86)),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "$_inputCharCount characters",
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputContainer() {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Container(
      height: screenHeight * 0.27,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                languagePair.language2,
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: _outputController, // Use the output controller
                readOnly: true,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: "Dito ang isinalin",
                  hintStyle: TextStyle(color: Color.fromARGB(221, 89, 86, 86)),
                ),
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: const Color.fromARGB(221, 89, 86, 86),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "$_outputCharCount characters",
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: IconButton(
              onPressed: () {
                if (_translation.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: _translation));
                }
              },
              icon: Icon(
                Icons.copy,
                color: Colors.black54,
                size: screenWidth * 0.06,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

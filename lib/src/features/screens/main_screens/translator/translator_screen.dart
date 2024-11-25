import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/translator/language_model.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/translator/language_switch.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/translator/translation_service.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TranslationService service = TranslationService();
  final TextEditingController _controller = TextEditingController();
  String _translation = "";

  LanguagePair languagePair =
      LanguagePair(language1: 'Tagalog', language2: 'Cuyonon');

  int _inputCharCount = 0;
  int _outputCharCount = 0;

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
    super.dispose();
  }

  Future<void> _translateText() async {
    String inputText = _controller.text.trim();

    // Check if the input text ends with a period, question mark, or exclamation mark
    if (!inputText.endsWith(".") && !inputText.endsWith("?") && !inputText.endsWith("!")) {
      // If not, add a space and then a period
      inputText += " .";
    } else {
      // Add a space before the punctuation mark if necessary
      inputText = inputText.replaceAll(RegExp(r'([^\s])([.?!])'), r'\1 \2');
    }

    final result = await service.translate(
      inputText,
      sourceLang: languagePair.language1,
      targetLang: languagePair.language2,
    );
    setState(() {
      _translation = result;
      _outputCharCount = _translation.length;
    });
  }

  void _swapLanguages() {
    setState(() {
      languagePair.swap();
    });
    // Do not trigger translation here
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensure layout resizes when keyboard shows
      body: SingleChildScrollView(
        // Wrap entire body with a scrollable view
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
            SizedBox(height: screenHeight * 0.03),
            _buildInputContainer(),
            SizedBox(height: screenHeight * 0.02),
            _buildOutputContainer(),
            SizedBox(height: screenHeight * 0.03),
            MyButton(
              onTab: _translateText,  // Trigger translation here
              text: 'I-translate',
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputContainer() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languagePair.language2,
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _translation.isNotEmpty
                ? _translation
                : "Dito makikita ang naisalin na salita...",
            maxLines: 5,
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
    );
  }
}

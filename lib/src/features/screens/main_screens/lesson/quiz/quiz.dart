// lesson_quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/common_widgets/custom_alert_dialog.dart';
import 'package:taga_cuyo/src/features/constants/capitalize.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:taga_cuyo/src/features/services/lesson_service.dart';
import 'package:taga_cuyo/src/exceptions/logger.dart';

class LessonQuizScreen extends StatefulWidget {
  final String lessonName;
  final String documentId;
  const LessonQuizScreen({
    super.key,
    required this.lessonName,
    required this.documentId,
  });

  @override
  LessonQuizScreenState createState() => LessonQuizScreenState();
}

class LessonQuizScreenState extends State<LessonQuizScreen> {
  final LessonProgressService _progressService = LessonProgressService();
  late int completedLessons = 0;
  final AuthService _authService = AuthService();
  int _currentQuizIndex = 0;
  List<String> quizIds = [];
  List<Map<String, dynamic>> _words = [];
  bool _isLoading = true;
  int _currentWordIndex = 0;
  final TextEditingController _translationController = TextEditingController();
  Set<String> selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _fetchWords();
    _initializeCompletedLessons();
  }

  Future<void> _initializeCompletedLessons() async {
    String? userId = _authService.getUserId();
    if (userId != null) {
      completedLessons = await _progressService.getCompletedLessons(userId);
      Logger.log('Completed Lessons: $completedLessons');
    } else {
      Logger.log('User ID is null.');
    }
  }

  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
  }

  Future<void> _updateLessonProgress() async {
    String? userId = _authService.getUserId();
    if (userId == null) {
      await showCustomAlertDialog(
        context,
        'Error', // Title for the dialog
        'Hindi naka-log in ang user.', // Content for the dialog
        buttonText: 'OK', // Button text
      );
      return;
    }

    try {
      await _progressService.updateLessonProgress(widget.documentId, userId);
    } catch (e) {
      Logger.log(e.toString());
    }
  }

  Future<void> _fetchWords() async {
    _words = await _progressService.fetchWords(widget.lessonName);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkAnswer() async {
    if (_words.isNotEmpty && _currentWordIndex < _words.length) {
      String selectedAnswer = selectedOptions
          .join(' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim()
          .toLowerCase();

      String expectedTranslation =
          _words[_currentWordIndex]['translated'].trim().toLowerCase();

      if (expectedTranslation == selectedAnswer) {
        // Show the correct answer dialog
        _showCorrectAnswerDialog(expectedTranslation);

        // Move to the next word/quiz after dialog is dismissed
        if (_currentWordIndex < _words.length - 1) {
          setState(() {
            _currentWordIndex++;
            selectedOptions.clear();
            _updateTextField();
          });
        } else {
          if (_currentQuizIndex < quizIds.length - 1) {
            _loadNextQuiz();
          } else {
            // Update lesson progress when the last quiz is completed
            await _updateLessonProgress();
            _showCompletionDialog();
          }
        }
      } else {
        _showIncorrectAnswerDialog(expectedTranslation);
      }
    }
  }

  void _loadNextQuiz() async {
    setState(() {
      _currentQuizIndex++;
      _currentWordIndex = 0; // Reset word index for new quiz
      selectedOptions.clear();
      _translationController.clear(); // Clear the text field
      _fetchWords(); // Fetch words for the new quiz
    });
  }

  void _showCompletionDialog() {
    showCustomAlertDialog(
      context,
      'Binabati kita!', // Title of the dialog
      'Natapos mo na ang pagsubok sa aralin.', // Content of the dialog
      buttonText: 'OK', // Button text
    ).then((_) {
      Navigator.pop(context); // Close the dialog
      Navigator.pushReplacementNamed(
          context, 'LessonScreenPage'); // Navigate to LessonScreenPage
    });
  }

  void _showCorrectAnswerDialog(String correctAnswer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          // Use Dialog instead of AlertDialog for more customization
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          elevation: 10, // Shadow effect
          child: Container(
            padding: const EdgeInsets.all(20), // Padding inside the dialog
            decoration: BoxDecoration(
              color: AppColors
                  .secondaryBackground, // Background color of the dialog
              borderRadius:
                  BorderRadius.circular(12), // Match the shape's border radius
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Size the dialog to fit its content
              children: [
                const Text(
                  'Bravo! Tamang sagot',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    fontFamily:
                        AppFonts.fcb, // Set the font family for the title
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ang sagot ay "$correctAnswer".',
                  style: const TextStyle(
                    fontSize: 21,
                    fontFamily:
                        AppFonts.fcr, // Set the font family for the content
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors
                        .primaryBackground, // Set the text color on the button
                    backgroundColor:
                        AppColors.correct, // Set the button's background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          25), // Rounded corners for button
                    ),
                  ),
                  child: const Text(
                    'Magpatuloy',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: AppFonts
                          .fcb, // Set the font family for the button text
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showIncorrectAnswerDialog(String correctAnswer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          // Use Dialog instead of AlertDialog for more customization
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          elevation: 10, // Shadow effect
          child: Container(
            padding: const EdgeInsets.all(20), // Padding inside the dialog
            decoration: BoxDecoration(
              color: AppColors
                  .secondaryBackground, // Background color of the dialog
              borderRadius:
                  BorderRadius.circular(12), // Match the shape's border radius
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Size the dialog to fit its content
              children: [
                const Text(
                  'Oops! Maling sagot',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    fontFamily:
                        AppFonts.fcb, // Set the font family for the title
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ang tamang sagot ay "$correctAnswer"',
                  style: const TextStyle(
                    fontSize: 21,
                    fontFamily:
                        AppFonts.fcr, // Set the font family for the content
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors
                        .primaryBackground, // Set the text color on the button
                    backgroundColor:
                        AppColors.wrong, // Set the button's background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          25), // Rounded corners for button
                    ),
                  ),
                  child: const Text(
                    'Ulitin',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: AppFonts
                          .fcb, // Set the font family for the button text
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleOption(String option) {
    setState(() {
      if (selectedOptions.contains(option)) {
        selectedOptions.remove(option); // Remove option if already selected
      } else {
        selectedOptions.add(option); // Add option if not selected
      }
      _updateTextField(); // Update the text field based on selection
    });
  }

  void _updateTextField() {
    _translationController.text =
        selectedOptions.join(' '); // Join selected options with a comma
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    // Calculate progress based on total words in the current quiz
    double progress = _words.isNotEmpty
        ? (_currentWordIndex + 1) / _words.length // Total words in current quiz
        : 0;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding:
                      EdgeInsets.fromLTRB(0, width * 0.12, 0, width * 0.045),
                  child: Column(
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        capitalizeFirstLetter('${widget.documentId}:'),
                        style: TextStyle(
                          fontSize: width * 0.048,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.fcr,
                          color: Color.fromARGB(255, 97, 97, 97),
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        textAlign: TextAlign.center,
                        capitalizeFirstLetter(widget.lessonName),
                        style: TextStyle(
                          fontFamily: AppFonts.fcb,
                          fontSize: width * 0.062,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: width * 0.075),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Isalin ang pangungusap na ito',
                    style: TextStyle(
                      fontFamily: AppFonts.kanitLight,
                      fontSize: width * 0.043,
                    ),
                  ),
                ),
              ),
              SizedBox(height: width * 0.035),
              _buildQuestionContainer(),
              _buildTranslationTextField(),
              _buildOptions(),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyButton(
                    onTab: () {
                      if (selectedOptions.isNotEmpty) {
                        _checkAnswer(); // Check answer against selected options
                      } else {
                        showCustomAlertDialog(
                          context,
                          'Oops!',
                          'Kailangan mong pumili ng sagot',
                          buttonText: 'OK!', // Custom button text
                        );
                      }
                    },
                    text: 'Isumite',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // LinearProgressIndicator
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor:
                              AppColors.primaryBackground.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accentColor),
                        ),
                      ),
                      // Add a number indicator
                      Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 10),
                          child: Text(
                              '${_currentWordIndex + 1} / ${_words.length}', // Show finished and max length
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    Colors.black, // Customize color as needed
                              ))

                          // Percentage
                          // child: Text(
                          //   '${(progress * 100).toStringAsFixed(0)}%', // Show the percentage of progress
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.black
                          //   ),
                          // ),
                          ),
                    ],
                  )
                ],
              ),
            ],
          ),
          Positioned(
            top: 45, // Adjust this value to position vertically
            right: 30, // Adjust this value to position horizontally
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(50), // Circular border for the icon
                border: Border.all(
                  width: 1,
                  color: Colors.black, // Optional: Add a color to the border
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.close),
                padding: EdgeInsets
                    .zero, // Remove padding to fit the icon inside the border
                alignment:
                    Alignment.center, // Center the icon inside the container
                iconSize: 20, // Adjust icon size if needed
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContainer() {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.21,
      padding: EdgeInsets.fromLTRB(0, width * 0.04, 0, width * 0.04),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 243, 188),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // Center the row items
        children: [
          Image.asset(
            'assets/images/teacher.png',
            height: width * 0.38,
            width: width * 0.38,
          ),
          SizedBox(
              width: width *
                  0.02), // Add spacing between the image and the text container
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 3, // Blur to soften the shadow edges
                  spreadRadius: 2, // Keep the shadow focused
                  offset:
                      const Offset(10, 10), // Slightly off to the bottom right
                ),
                const BoxShadow(
                  color: Colors
                      .transparent, // Use transparent to avoid shadow on top and left
                  blurRadius: 5, // Same blur radius
                  spreadRadius: 2,
                  offset: Offset(2, -2), // Slightly off to the top right
                ),
              ],
            ),
            // ignore: sized_box_for_whitespace
            child: Padding(
              padding: EdgeInsets.all(width * 0.03),
              child: SizedBox(
                height: height * 0.12,
                width: width * 0.42,
                child: Center(
                  child: _isLoading
                      ? Text(
                          'Loading...',
                          style: TextStyle(fontSize: width * 0.048),
                        )
                      : _words.isNotEmpty && _currentWordIndex < _words.length
                          ? Container(
                              width:
                                  width, // Set width to limit the container width
                              alignment:
                                  Alignment.center, // Align text to the bottom
                              child: Text(
                                capitalizeFirstLetter(
                                    _words[_currentWordIndex]['word']),
                                textAlign:
                                    TextAlign.center, // Center text alignment
                                style: TextStyle(
                                    fontSize: width * 0.054,
                                    fontFamily: AppFonts.fcr,
                                    fontWeight: FontWeight.bold),
                                maxLines: 5, // Set maximum lines allowed
                                overflow: TextOverflow
                                    .ellipsis, // Show ellipsis if text exceeds max lines
                              ),
                            )
                          : Text(
                              'Hindi matagpuan ang salita',
                              textAlign:
                                  TextAlign.center, // Center text alignment
                              style: TextStyle(
                                fontSize: width * 0.048,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationTextField() {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          height * 0.06, width * 0.05, height * 0.06, width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'i-click ang text sa pagpipilian upang alisin',
            style: TextStyle(
              fontFamily: AppFonts.kanitLight,
              fontSize: width * 0.038,
              fontStyle: FontStyle.italic, // Correct way to italicize text
            ),
          ),
          SizedBox(
              height: width *
                  0.03), // Add some spacing between the text and text field
          GestureDetector(
            onTap: () {
              setState(() {
                selectedOptions
                    .clear(); // Clear selected options when text field is tapped
                _translationController.clear(); // Clear the text field
              });
            },
            child: Container(
              height: height * 0.31, // Set the height
              alignment: Alignment.center, // Center the text horizontally
              decoration: BoxDecoration(
                border:
                    Border.all(width: 1.0, color: Colors.black), // Same border
                borderRadius:
                    BorderRadius.circular(4.0), // Similar border radius
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: width * 0.03), // Vertical padding
                child: Text(
                  _translationController
                      .text, // Display text from the controller
                  textAlign: TextAlign.center, // Center text horizontally
                  style: TextStyle(
                    fontSize: width * 0.054,
                    fontFamily: AppFonts.fcr,
                    fontWeight: FontWeight.bold,
                  ), // Text styling
                  maxLines: 2, // Set maximum number of lines
                  overflow:
                      TextOverflow.ellipsis, // Show ellipsis if text overflows
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    if (_isLoading || _words.isEmpty || _currentWordIndex >= _words.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final options = _words[_currentWordIndex]['options'] ?? [];

    return SizedBox(
      height: height * 0.24,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Pagpipilian',
              style: TextStyle(
                  fontSize: height * 0.025,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.fcr),
            ),
            const SizedBox(height: 8),
            options.isNotEmpty
                ? Center(
                    child: Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      alignment: WrapAlignment.center,
                      children: options.map<Widget>((option) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 4, horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () => _toggleOption(option),
                            child: Container(
                              padding: EdgeInsets.all(height * 0.017),
                              decoration: BoxDecoration(
                                color: selectedOptions.contains(option)
                                    ? Colors.lightBlue[100]
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                option, // Display each option here
                                style: TextStyle(
                                    fontSize: height * 0.019),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const Text('Hindi available ang pagpipilian',
                    style: TextStyle(fontSize: 24, fontFamily: AppFonts.fcb)),
          ],
        ),
      ),
    );
  }
}

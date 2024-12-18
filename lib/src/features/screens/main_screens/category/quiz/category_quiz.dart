import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/common_widgets/custom_alert_dialog.dart';
import 'package:taga_cuyo/src/features/constants/capitalize.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/services/category_service.dart';
import 'package:taga_cuyo/src/exceptions/logger.dart';

class CategoryQuizScreen extends StatefulWidget {
  final String categoryId;
  final String subcategoryTitle;
  final String subcategoryId;
  final String currentWord;
  final String userId;

  const CategoryQuizScreen({
    super.key,
    required this.categoryId,
    required this.subcategoryTitle,
    required this.currentWord,
    required this.userId,
    required this.subcategoryId,
  });

  @override
  State<CategoryQuizScreen> createState() => _CategoryQuizScreenState();
}

class _CategoryQuizScreenState extends State<CategoryQuizScreen> {
  bool _isCorrect = false;
  bool _isAnswered = false;
  String correctAnswer = '';
  List<dynamic> options = [];
  String? selectedOption;
  int _currentWordIndex = 0;
  List<Map<String, dynamic>> dataList = [];

  final CategoryService _categoryService = CategoryService();

  // Add a variable to cache the image URL
  String? cachedImageUrl;

  @override
  void initState() {
    super.initState();
    fetchCategorySubcategoryData();
  }

  @override
  Widget build(BuildContext context) {
    if (dataList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentWordIndex >= dataList.length) {
      _showCongratulationsDialog(widget.subcategoryTitle);
      return const Center(child: Text('Natapos na ang pagsubok'));
    }

    final data = dataList[_currentWordIndex];
    correctAnswer = data['translated'];

    // Shuffle only if options are not set yet
    if (options.isEmpty) {
      options = List<dynamic>.from(data['options']);
      options.shuffle(); // Shuffle only when options are first loaded
    }

    // Calculate the progress as a fraction of total quizzes
    double progress = (_currentWordIndex + 1) / dataList.length;

    // Fetch the image if it's not already fetched
    if (cachedImageUrl == null) {
      fetchImageFromStorage(data['image_path']).then((url) {
        setState(() {
          cachedImageUrl = url;
        });
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                _headerTitle(
                    context, widget.categoryId, widget.subcategoryTitle),
                const SizedBox(height: 20),
                // Directly show the image if it exists
                cachedImageUrl == null
                    ? const Center(child: CircularProgressIndicator())
                    : _imageWithWordContainer(
                        context, cachedImageUrl, data['word']),
                const SizedBox(height: 20),
                _notifText(),
                const SizedBox(height: 20),
                _buildOptions(context, options),
                if (_isAnswered && !_isCorrect)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Pumiling muli',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  ),
                const Spacer(),
                if (_isAnswered && _isCorrect)
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom:
                            10), // Add padding between button and progress bar
                    child: MyButton(
                      onTab: () {
                        navigateToNextWord();
                      },
                      text: 'Sunod',
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accentColor),
                      ),
                    ),
                    const SizedBox(
                        width:
                            10), // Add some space between the progress bar and the number
                    Text(
                      '${_currentWordIndex + 1}/${dataList.length}',
                      style: const TextStyle(
                        fontFamily: AppFonts.fcb,
                        fontSize: 20,
                        color: Colors.black, // Change the color as needed
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Future<void> fetchCategorySubcategoryData() async {
    try {
      Logger.log(
          'Fetching data for Category ID: ${widget.categoryId}, Subcategory Title: ${widget.subcategoryTitle}');

      var snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .collection('subcategories')
          .doc(widget.subcategoryId)
          .collection('words')
          .get();

      Logger.log(
          'Fetched ${snapshot.docs.length} words'); // Log the number of documents fetched
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          Logger.log('Fetched word: ${doc.data()}'); // Log each fetched word
        }

        setState(() {
          dataList = snapshot.docs.map((doc) => doc.data()).toList();
          _currentWordIndex = 0; // Reset index
        });
      } else {
        _showCongratulationsDialog(
            widget.subcategoryTitle); // Consider handling this more gracefully
      }
    } catch (e) {
      Logger.log('Error fetching Category subcategory data: $e');
    }
  }

  Future<String> fetchImageFromStorage(String imagePath) async {
    try {
      Reference imageRef = FirebaseStorage.instance.refFromURL(imagePath);
      return await imageRef.getDownloadURL();
    } catch (e) {
      Logger.log("Error fetching image from storage: $e");
      return '';
    }
  }

  void _showCongratulationsDialog(String subcategoryTitle) async {
    // Check if the subcategory is finished
    bool isFinished = await _categoryService.isSubcategoryFinished(
      userId: widget.userId,
      categoryId: widget.categoryId,
      subcategoryId: widget.subcategoryId,
    );

    // If not finished, update user progress
    if (!isFinished) {
      await _categoryService.updateUserProgress(
        userId: widget.userId,
        categoryId: widget.categoryId,
        subcategoryId: widget.subcategoryId,
      );
    }

    await showCustomAlertDialog(
      context,
      'Binabati Kita!', // Title for the dialog
      'Natapos mo na ang lahat ng pagsubok sa $subcategoryTitle', // Content for the dialog
      buttonText: 'OK', // Button text
    ).then((_) {
      Navigator.pop(context); // Close the dialog
      Navigator.pushReplacementNamed(
          context, 'CategoryScreen'); // Navigate to LessonScreenPage
    });
  }

  void handleAnswer(String selectedAnswer) {
    if (_isAnswered && _isCorrect) return; // Don't update if already correct

    setState(() {
      selectedOption = selectedAnswer;
      _isAnswered = true;
      _isCorrect = selectedAnswer == correctAnswer;
    });

    // Check if the answer is correct and if we're at the last word
    if (_isCorrect && _currentWordIndex + 1 >= dataList.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCongratulationsDialog(widget.subcategoryTitle);
      });
    }
  }

  void navigateToNextWord() {
    if (_currentWordIndex + 1 < dataList.length) {
      setState(() {
        _currentWordIndex++;
        _isAnswered = false;
        selectedOption = null;
        cachedImageUrl = null;
        options = [];
      });
    }
  }

  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      top: 40,
      right: 25,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          border: Border.all(
              width: 1, color: const Color.fromARGB(255, 67, 67, 67)),
          borderRadius: BorderRadius.circular(50),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          iconSize: 15,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context, List<dynamic> options) {
    return Column(
      children: options.map((option) {
        return _buildOption(context, option);
      }).toList(),
    );
  }

  Widget _buildOption(BuildContext context, String option) {
    final isSelected = selectedOption == option;
    final isCorrectOption = option == correctAnswer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          handleAnswer(option); // Handle answer selection
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 3 / 4,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? (isCorrectOption ? AppColors.correct : AppColors.wrong)
                : AppColors.accentColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              capitalizeFirstLetter(option),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerTitle(
      BuildContext context, String categoryId, String subcategoryTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Center(
        child: Column(
          children: [
            Text(
              capitalizeFirstLetter(categoryId),
              style: const TextStyle(
                fontFamily: AppFonts.fcr,
                color: AppColors.titleColor,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              capitalizeFirstLetter(subcategoryTitle),
              style: const TextStyle(
                fontFamily: AppFonts.fcr,
                fontSize: 26,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageWithWordContainer(
      BuildContext context, String? imageUrl, String word) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _imageContainer(context, imageUrl),
        _wordContainer(context, word),
      ],
    );
  }

  Widget _imageContainer(BuildContext context, String? imageUrl) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        color: const Color.fromARGB(
            150, 255, 255, 255), // Semi-transparent background
        border: Border.all(
          color: const Color.fromARGB(255, 100, 142, 190), // Border color
          width: 5, // Adjust the width of the border if needed
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(imageUrl)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _wordContainer(BuildContext context, String word) {
    return Positioned(
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: Color.fromARGB(150, 255, 255, 255), // Set opacity here (0-255)
        ),
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width * 2.3 / 3,
        child: Center(
          child: Text(
            capitalizeFirstLetter(word),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.fcr,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.titleColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _notifText() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color:
            _isAnswered && _isCorrect ? AppColors.correct : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: _isAnswered && _isCorrect
            ? const Text(
                'Tama ang iyong sagot!',
                style: TextStyle(
                    fontFamily: AppFonts.fcr,
                    fontSize: 21,
                    color: Color.fromARGB(255, 0, 0, 0)),
              )
            : const Text(''),
      ),
    );
  }
}

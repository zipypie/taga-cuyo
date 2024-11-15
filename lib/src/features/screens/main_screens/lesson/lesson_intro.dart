import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/lesson/lesson_strings.dart';

class LessonIntroduction extends StatefulWidget {
  const LessonIntroduction({super.key});

  @override
  LessonIntroductionState createState() => LessonIntroductionState();
}

class LessonIntroductionState extends State<LessonIntroduction> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Helper method to get responsive padding
  double getResponsivePadding(double factor) {
    return MediaQuery.of(context).size.width * factor;
  }

  // Helper method to get responsive font size
  double getResponsiveFontSize(double factor) {
    return MediaQuery.of(context).size.height * factor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildAppBarContent(),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildPageOne(),
                _buildPageTwo(),
                _buildPageThree(),
              ],
            ),
          ),
          _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildPageOne() {
    return Padding(
      padding: EdgeInsets.fromLTRB(getResponsivePadding(0.05), 0, getResponsivePadding(0.05), getResponsivePadding(0.05)),
      child: Column(
        children: [
          SizedBox(height: getResponsivePadding(0.03)),
          _buildHeader(LessonStrings.introductionTitle),
          _buildSection(content: LessonStrings.introductionText),
          SizedBox(height: getResponsivePadding(0.03)),
          _buildHeader(LessonStrings.glottalStopTitle),
          _buildSection(content: LessonStrings.glottalStopText, examples: LessonStrings.glottalStopExamples),
        ],
      ),
    );
  }

  Widget _buildPageTwo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(getResponsivePadding(0.05), 0, getResponsivePadding(0.05), getResponsivePadding(0.05)),
      child: Column(
        children: [
          SizedBox(height: getResponsivePadding(0.03)),
          _buildHeader(LessonStrings.vowelsTitle),
          SizedBox(height: getResponsivePadding(0.015)),
          _buildSection(content: LessonStrings.getVowelsText()),
          SizedBox(height: getResponsivePadding(0.015)),
          _buildHeader(LessonStrings.clustersTitle),
          _buildSection(content: LessonStrings.getClustersText()),
        ],
      ),
    );
  }

  Widget _buildPageThree() {
    return Padding(
      padding: EdgeInsets.fromLTRB(getResponsivePadding(0.05), 0, getResponsivePadding(0.05), getResponsivePadding(0.05)),
      child: Column(
        children: [
          SizedBox(height: getResponsivePadding(0.03)),
          _buildHeader(LessonStrings.consonantsTitle),
          _buildSection(content: LessonStrings.getConsonantsText()),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: getResponsivePadding(0.015)),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: AppFonts.fcb,
          fontSize: getResponsiveFontSize(0.024), // Adjusted font size
          color: const Color.fromARGB(255, 69, 72, 73),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String content,
    String? examples,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(getResponsivePadding(0.03)), // Responsive padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: TextStyle(fontSize: getResponsiveFontSize(0.019)), // Adjusted font size
          ),
          if (examples != null) ...[
            Text(
              examples,
              style: TextStyle(fontSize: getResponsiveFontSize(0.019)), // Adjusted font size
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.all(4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? AppColors.titleColor : Colors.grey,
          ),
        );
      }),
    );
  }

  Widget _buildAppBarContent() {
    return Container(
      padding: EdgeInsets.fromLTRB(getResponsivePadding(0.08), getResponsivePadding(0.08), getResponsivePadding(0.08), 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            LessonStrings.title,
            style: TextStyle(
              fontSize: getResponsiveFontSize(0.027), // Adjusted font size
              fontFamily: AppFonts.fcb,
            ),
          ),
          // Close icon container
          Container(
            width: getResponsivePadding(0.08), // Responsive width
            height: getResponsivePadding(0.08), // Responsive height
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1), // Black border
              shape: BoxShape.circle, // Makes the container circular
            ),
            child: IconButton(
              padding: EdgeInsets.zero, // Remove padding from IconButton
              iconSize: getResponsiveFontSize(0.03), // Adjusted icon size
              icon: Icon(Icons.close, color: Colors.black), // Close icon
              onPressed: () {
                Navigator.pop(context); // Close the screen
              },
            ),
          ),
        ],
      ),
    );
  }
}

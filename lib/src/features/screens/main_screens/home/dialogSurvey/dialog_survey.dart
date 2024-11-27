import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/exceptions/logger.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

class SurveyDialog extends StatefulWidget {
  final String uid;
  final VoidCallback onCompleted; // Callback for when survey is completed

  const SurveyDialog(
      {super.key,
      required this.uid,
      required this.onCompleted}); // Add onCompleted to constructor

  @override
  SurveyDialogState createState() => SurveyDialogState();
}

class SurveyDialogState extends State<SurveyDialog> {
  String? selectedLanguage;

  // Function to save the selected language to Firestore
  Future<void> saveLanguage(String language) async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(widget.uid);

    try {
      await userDoc.set({
        'mother_tongue': language, // Save as 'mother_tongue' field
        'hasCompletedSurvey': true, // Mark survey as completed
      }, SetOptions(merge: true));
      Logger.log("Saved language: $language"); // Log success
      widget.onCompleted(); // Invoke the callback
    } catch (e) {
      Logger.log("Error saving language: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width*0.5;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor:
          const Color.fromARGB(255, 250, 238, 203), // Background color
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Ano ang iyong unang/katutubong wika?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.fcr,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Tagalog Button
            SizedBox(
              width: width, // Ensures the button takes full width
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedLanguage = "Tagalog";
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedLanguage == "Tagalog"
                      ? AppColors.correct
                      : AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("Tagalog",
                    style: TextStyle(
                      fontFamily: AppFonts.fcr,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            const SizedBox(height: 10),

            // Cuyonon Button
            SizedBox(
              width: width, // Ensures the button takes full width
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedLanguage = "Cuyonon";
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedLanguage == "Cuyonon"
                      ? AppColors.correct
                      : AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("Cuyonon",
                    style: TextStyle(
                      fontFamily: AppFonts.fcr,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            const SizedBox(height: 10),

            // Iba Button
            SizedBox(
              width: width, // Ensures the button takes full width
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedLanguage = "Iba";
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedLanguage == "Iba"
                      ? AppColors.correct
                      : AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("Iba",
                    style: TextStyle(
                      fontFamily: AppFonts.fcr,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            const SizedBox(height: 20),

            // Magsimula Button
            SizedBox(
              width: double.infinity, // Ensures the button takes full width
              child: ElevatedButton(
                onPressed: selectedLanguage != null
                    ? () {
                        saveLanguage(selectedLanguage!);
                        Navigator.of(context).pop(); // Close the dialog
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Button color
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                ),
                child: const Text("Magsimula",
                    style: TextStyle(
                      color: AppColors.primaryBackground,
                      fontFamily: AppFonts.fcb,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

class TermsAndConditionsDialog extends StatelessWidget {
  const TermsAndConditionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog title
            Text(
              'Terms and Conditions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please read these Terms and Conditions carefully before using the TAGA-CUYO: Tagalog Cuyonon Translator and Learning Application operated by our company.\n\n'
                      'By accessing, or using our Service, you agree to be bound by these Terms. If you disagree with any part of the Terms, you may not access or use the Service.\n\n',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '1. Acceptance of Terms',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'By accessing or using TAGA-CUYO, you agree to these Terms, which constitute a legally binding agreement between you as user and our company. These Terms govern your use of our Service, including any updates or new features provided.\n\n',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '2. User Account',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '• You may be required to create an account to access certain features of the Service.\n'
                      '• You agree to provide accurate, current, and complete information during registration.\n'
                      '• You are responsible for maintaining the confidentiality of your account and password, and for restricting access to your device. You accept responsibility for all activities that occur under your account.\n\n',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '3. Use of the Service',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '• The Service is intended for personal, non-commercial use.\n'
                      '• You may not use the Service for any illegal or unauthorized purposes.\n'
                      '• You agree not to attempt to copy, modify, reverse engineer, or distribute any part of the Service.\n'
                      '• You must not misuse the Service by knowingly introducing viruses or other malicious or harmful material.\n\n',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '4. Prohibited Conduct',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '• Violating any local, national, or international law.\n'
                      '• Using the Service in a way that could harm, disable, overburden, or impair its functionality.\n'
                      '• Interfering with other users\' enjoyment of the Service.\n'
                      '• Harvesting or collecting personal data from the Service without consent.\n\n',
                      style: TextStyle(fontSize: 16),
                    ),
                    // Add more sections as needed
                  ],
                ),
              ),
            ),
            const Divider(),
            // Bottom row for buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel button
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('Cancel',
                        style: TextStyle(
                            fontSize: 19,
                            fontFamily: AppFonts.fcr,
                            fontWeight: FontWeight.bold)),
                ),
                // Agree button
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryBackground),
                    child: Text('Agree',
                        style: TextStyle(
                            fontSize: 19,
                            fontFamily: AppFonts.fcr,
                            fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

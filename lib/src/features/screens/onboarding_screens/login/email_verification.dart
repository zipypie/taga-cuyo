import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';

class EmailVerificationDialog extends StatefulWidget {
  final String email;

  const EmailVerificationDialog({super.key, required this.email});

  @override
  State<EmailVerificationDialog> createState() => _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  AuthService _authService = AuthService();
  bool isLoading = false;

  // Function to send email verification link
  Future<void> sendVerificationToEmail() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Call AuthService to send the verification email
      await _authService.sendEmailVerification(widget.email);
      // Show confirmation message when email is sent
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Verification email sent!",
            style: TextStyle(
              fontFamily: AppFonts.fcr, // Set the font family for SnackBar text
              fontSize: 18,
            ),
          ),
          backgroundColor: AppColors.primary, // Match SnackBar background with button
          behavior: SnackBarBehavior.floating, // Optionally, make the SnackBar float
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Match dialog rounded corners
          ),
          margin: EdgeInsets.all(20), // Add margin for better positioning
        ),
      );
      Navigator.of(context).pop(); // Close the dialog after sending the email
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to send verification email",
            style: TextStyle(
              fontFamily: AppFonts.fcr, // Set the font family for SnackBar text
              fontSize: 18,
            ),
          ),
          backgroundColor: AppColors.wrong, // Customize error color
          behavior: SnackBarBehavior.floating, // Optionally, make the SnackBar float
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Match dialog rounded corners
          ),
          margin: EdgeInsets.all(20), // Add margin for better positioning
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      elevation: 10, // Shadow effect
      child: Container(
        padding: const EdgeInsets.all(20), // Padding inside the dialog
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground, // Background color of the dialog
          borderRadius: BorderRadius.circular(12), // Match the shape's border radius
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Size the dialog to fit its content
          children: [
            Text(
              "Email Verification Required",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                fontFamily: AppFonts.fcb, // Set the font family for the title
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your email is not verified. Please check your inbox and verify your email address.',
              style: const TextStyle(
                fontSize: 21,
                fontFamily: AppFonts.fcr, // Set the font family for the content
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : sendVerificationToEmail,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // Set the text color on the button
                backgroundColor: AppColors.primary, // Set the button's background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Rounded corners for button
                ),
              ),
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      "Send Verification Email",
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: AppFonts.fcb, // Set the font family for the button text
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

void showEmailVerificationDialog(BuildContext context, String email) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return EmailVerificationDialog(email: email);
    },
  );
}

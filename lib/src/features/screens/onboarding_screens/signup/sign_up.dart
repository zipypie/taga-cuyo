import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/common_widgets/dropdown_input.dart';
import 'package:taga_cuyo/src/features/common_widgets/text_input.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/constants/logo.dart';
import 'package:taga_cuyo/src/features/screens/onboarding_screens/login/login.dart';
import 'package:taga_cuyo/src/features/screens/onboarding_screens/signup/tac.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:taga_cuyo/src/features/common_widgets/custom_alert_dialog.dart'; // Import your custom alert dialog

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String? selectedGender;
  bool isLoading = false;
  bool isChecked = false;

  void showTermsAndConditionsDialog() async {
    // Show the Terms and Conditions dialog
    bool? agreed = await showDialog<bool>(
      context: context,
      builder: (context) => TermsAndConditionsDialog(),
    );

    // If the user agrees, check the checkbox
    if (agreed == true) {
      setState(() {
        isChecked = true;
      });
    }
  }

  void signUpUser() async {
    // Ensure all fields are filled
    if (firstnameController.text.isEmpty ||
        lastnameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        ageController.text.isEmpty ||
        selectedGender == null) {
      await showCustomAlertDialog(
        context,
        'Dapat gawin',
        'Pakipunan ang lahat ng form',
      );
      return;
    }

    if (passwordController.text.length < 6) {
      await showCustomAlertDialog(
        context,
        'Error',
        'Ang password ay dapat may 6 o higit pang characters.',
      );
      return;
    }

    if (!isChecked) {
      await showCustomAlertDialog(
        context,
        'Dapat gawin',
        'Tanggapin ang mga Tuntunin at Kundisyon upang makarehistro.',
      );
      return;
    }

    setState(() {
      isLoading = true; // Show loading indicator
    });

    // Sign up the user using the AuthService
    String res = await AuthService().signUpUser(
      firstname: firstnameController.text,
      lastname: lastnameController.text,
      email: emailController.text,
      password: passwordController.text,
      age: int.parse(ageController.text),
      gender: selectedGender!,
    );

    setState(() {
      isLoading = false; // Hide loading indicator
    });

    // Handle the result
    if (res == "Success") {
      await showCustomAlertDialog(
        context,
        'Success',
        'Ang iyong account ay matagumpay na nalikha.',
        buttonText: 'OK',
      );

      // Navigate to SignInScreen after closing the dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } else {
      await showCustomAlertDialog(
        context,
        'Hindi available ang email',
        'Pumili ng ibang email account',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: AppColors.primaryBackground,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.15,
                      child: LogoImage.logo,
                    ),
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Magrehistro',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: 1,
                              fontFamily: AppFonts.kanitLight,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Punan ang form na nasa ibaba',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: 1,
                              fontFamily: AppFonts.kanitLight,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryBackground,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFieldInputF(
                      textEditingController: firstnameController,
                      hintText: "Aran (Pangalan)",
                      icon: Icons.person,
                    ),
                    TextFieldInputF(
                      textEditingController: lastnameController,
                      hintText: "Apilido (Apelyido)",
                      icon: Icons.person,
                    ),
                    TextFieldInputF(
                      textEditingController: emailController,
                      hintText: "E-mail",
                      icon: Icons.email,
                    ),
                    TextFieldInputF(
                      textEditingController: passwordController,
                      hintText: "Password",
                      icon: Icons.lock,
                      isPass: true,
                    ),
                    TextFieldInputF(
                      textEditingController: ageController,
                      hintText: "Idad (Edad)",
                      icon: Icons.person_2_outlined,
                    ),
                    DropdownInputF(
                      value: selectedGender,
                      items: const [
                        'Lalaki',
                        'Babae',
                        'Iba',
                        'Hindi gustong ilagay'
                      ],
                      hintText: "Pumili ng Kasarian",
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGender = newValue;
                        });
                      },
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (bool? value) async {
                            if (value == true) {
                              // Show the Terms and Conditions dialog
                              bool? agreed = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return TermsAndConditionsDialog();
                                },
                              );

                              // If the user agrees, check the checkbox
                              if (agreed == true) {
                                setState(() {
                                  isChecked = true;
                                });
                              } else {
                                // If the user cancels, keep the checkbox unchecked
                                setState(() {
                                  isChecked = false;
                                });
                              }
                            } else {
                              // Allow unchecking directly
                              setState(() {
                                isChecked = false;
                              });
                            }
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Sumasang-ayon ako sa mga tuntunin at kondisyon.',
                            style: TextStyle(
                                fontSize: 18, fontFamily: AppFonts.fcr),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Show loading indicator or button
                    isLoading
                        ? const CircularProgressIndicator() // Loading spinner
                        : MyButton(onTab: signUpUser, text: "Isumite"),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Mayroon ng account? Piliin ang',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: AppFonts.kanitLight,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to SignInScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            ' Login.',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: AppFonts.kanitLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

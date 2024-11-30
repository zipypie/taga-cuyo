import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/common_widgets/custom_alert_dialog.dart';
import 'package:taga_cuyo/src/features/common_widgets/text_input.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/logo.dart';
import 'package:taga_cuyo/src/features/screens/onboarding_screens/forget_password/forget_password.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/home/home_screen.dart';
import 'package:taga_cuyo/src/features/screens/onboarding_screens/login/email_verification.dart';
import 'package:taga_cuyo/src/features/screens/onboarding_screens/signup/sign_up.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/exceptions/logger.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      } else {
        await showCustomAlertDialog(
          context,
          'Walang account ang natagpuan',
          'Gumawa muna ng bagong account sa Signup',
        );
        return null;
      }
    } catch (e) {
      showCustomAlertDialog(
        context,
        'Walang account ang natagpuan',
        'Gumawa muna ng bagong account sa Signup',
      );
      return null;
    }
  }

  void signInUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      await showCustomAlertDialog(
        context,
        'Ulitin muli!',
        'Pakipunan ang lahat ng form',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> res = await AuthService().signInUser(
        email: emailController.text,
        password: passwordController.text,
      );

      if (res['res'] == "Success" && res['uid'] != null) {
        String uid = res['uid'];
        Map<String, dynamic>? userData = await getUserData(uid);

        if (userData != null) {
          bool isEmailVerified =
              res['isEmailVerified']; // I-check kung na-verify ang email

          if (isEmailVerified) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  uid: uid,
                  userData: userData,
                ),
              ),
            );
          } else {
            // Ipakita ang email verification dialog kung hindi pa na-verify ang email
            showEmailVerificationDialog(context, emailController.text);
          }
        } else {
          await showCustomAlertDialog(
            context,
            'Walang account',
            'Gumawa ng bagong account para makapag-login!',
          );
        }
      } else {
        await showCustomAlertDialog(
          context,
          'Walang account',
          'Gumawa ng bagong account para makapag-login!',
        );
      }
    } catch (e) {
      Logger.log(e.toString());
      await showCustomAlertDialog(
        context,
        'Error',
        'May nangyaring error habang naglo-login: ${e.toString()}',
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: AppColors.primaryBackground,
                child: Column(
                  children: [
                    SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.28,
                      child: LogoImage.logo,
                    ),
                    Container(
                      margin: const EdgeInsets.all(30),
                      child: const Center(
                        child: Text(
                          'Maligayang Pagdating sa Taga-Cuyo: Tagalog-Cuyonon isang Pagsasalin at Pag-aaral gamit ang Aplikasyon',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            letterSpacing: 1,
                            fontFamily: AppFonts.kanitLight,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      TextFieldInputF(
                        textEditingController: emailController,
                        hintText: "E-mail",
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 10),
                      TextFieldInputF(
                        textEditingController: passwordController,
                        hintText: "Password",
                        icon: Icons.lock,
                        isPass: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgetPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Nakalimutan ang password?',
                              style: TextStyle(
                                letterSpacing: 1,
                                fontFamily: AppFonts.kanitLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0089EA),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      isLoading
                          ? const CircularProgressIndicator()
                          : MyButton(onTab: signInUser, text: "Mag-login"),
                      SizedBox(height: height / 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Wala pang account? Piliin ang',
                            style: TextStyle(
                                fontFamily: AppFonts.kanitLight,
                                fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              ' SignUp.',
                              style: TextStyle(
                                fontFamily: AppFonts.kanitLight,
                                fontSize: 17,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

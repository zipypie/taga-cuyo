import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/home/dialogSurvey/dialog_survey.dart';
import 'package:taga_cuyo/src/features/services/auth_wrapper.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:taga_cuyo/src/features/services/day_count.dart';
import 'package:taga_cuyo/src/features/services/streak_count.dart';
import 'package:taga_cuyo/src/features/services/user_service.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_bloc.dart';
import 'package:taga_cuyo/src/features/services/user_session_manager.dart';
import 'package:taga_cuyo/src/exceptions/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA_VoT0W3zD6u5GVEa24dLcMkt3DJtnqYg",
        authDomain: "tagalog-cuyonon-mobile-app.firebaseapp.com",
        databaseURL:
            "https://tagalog-cuyonon-mobile-app-default-rtdb.firebaseio.com",
        projectId: "tagalog-cuyonon-mobile-app",
        storageBucket: "tagalog-cuyonon-mobile-app.appspot.com",
        messagingSenderId: "598478516019",
        appId: "1:598478516019:web:e680422657a9ebde305846",
        measurementId: "G-9R8PRFSXQ1",
      ),
    );

    // Initialize Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    await Hive.openBox('images'); // Open Hive box for storing images

    // Activate Firebase App Check for both Android and iOS
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
  } catch (e) {
    Logger.log('Error initializing Firebase or Hive: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late UserService userService;
  late UserSessionManager userSessionManager;
  late StreakCounterService streakCounterService;
  late AuthService authService;
  bool _dialogShown = false; // Flag to prevent multiple dialogs

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    userService = UserService();
    userSessionManager = UserSessionManager(userService);
    DayCounterService dayCounterService = DayCounterService();
    dayCounterService.updateDayInSession();

    streakCounterService = StreakCounterService();
    streakCounterService.updateStreak();

    authService = AuthService(); // Initialize AuthService

    _checkAndShowSurveyDialog(); // Check and show dialog
  }

  void setStatus(String status) async {
    if (authService.currentUser == null) {
      Logger.log("No current user found");
    } else {
      Logger.log("Current user UID: ${authService.currentUser!.uid}");
    }

    await _firestore.collection('users').doc(authService.currentUser!.uid).set({
      "status": status,
    }, SetOptions(merge: true)); // This ensures other fields aren't overwritten

    Logger.log("Status updated to $status");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Logger.log("App lifecycle state changed: $state");

    if (state == AppLifecycleState.resumed) {
      setStatus("Online");
    } else {
      setStatus("Offline");
    }
  }

  Future<void> _checkAndShowSurveyDialog() async {
    String? uid = authService.getUserId(); // Get the user's UID

    if (uid != null) {
      Logger.log("Current User UID: $uid"); // Debug Logger.log

      final userData = await authService.getUserData();

      // Debugging information
      if (userData == null) {
        Logger.log("User data is null");
        return; // Exit early if userData is null
      } else {
        Logger.log("User data retrieved: ${userData.data()}");
      }

      // Check if the user has completed the survey
      var hasCompletedSurvey =
          (userData.data() as Map<String, dynamic>)['hasCompletedSurvey'] ??
              false;

      if (!hasCompletedSurvey) {
        // Only show dialog if the survey is not completed
        if (mounted && !_dialogShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SurveyDialog(
                  uid: uid,
                  onCompleted: () {
                    _dialogShown =
                        false; // Reset the dialogShown flag after survey is completed
                  },
                );
              },
            );
            _dialogShown = true; // Ensure the dialog is only shown once
            Logger.log(
                "Showing SurveyDialog for UID: $uid"); // Debug Logger.log
          });
        }
      } else {
        Logger.log("Survey already completed.");
      }
    } else {
      Logger.log(
          "No user is logged in."); // Handle case where no user is logged in
    }
  }

  @override
  void dispose() {
    userSessionManager.dispose(); // Dispose session manager
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => userService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ProfileBloc(
              RepositoryProvider.of<UserService>(context),
            ),
          ),
        ],
        child: const MaterialApp(
          title: 'Taga-Cuyo App',
          debugShowCheckedModeBanner: false,
          home: AuthWrapper(),
        ),
      ),
    );
  }
}

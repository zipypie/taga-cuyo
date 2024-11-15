import 'package:firebase_core/firebase_core.dart';

void initializeFirebase() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA_VoT0W3zD6u5GVEa24dLcMkt3DJtnqYg",
      authDomain: "tagalog-cuyonon-mobile-app.firebaseapp.com",
      databaseURL: "https://tagalog-cuyonon-mobile-app-default-rtdb.firebaseio.com",
      projectId: "tagalog-cuyonon-mobile-app",
      storageBucket: "tagalog-cuyonon-mobile-app.appspot.com",
      messagingSenderId: "598478516019",
      appId: "1:598478516019:web:e680422657a9ebde305846",
      measurementId: "G-9R8PRFSXQ1",
    ),
  );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taga_cuyo/src/exceptions/logger.dart';

class ProfileService {
  // Stream to get current user data
  static Stream<DocumentSnapshot> currentUser() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots();
    } else {
      throw Exception('No current user found');
    }
  }

  // Method to update user profile
  Future<void> updateUserProfile({
    required String firstname,
    required String lastname,
    required int age,
    required String gender,
    String? profileImage,
  }) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
          'firstname': firstname,
          'lastname': lastname,
          'age': age,
          'gender': gender,
          'profile_image': profileImage,
        });
      } else {
        throw Exception('No current user found');
      }
    } catch (e) {
      // Handle errors (e.g., network issues, permissions)
      Logger.log('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}

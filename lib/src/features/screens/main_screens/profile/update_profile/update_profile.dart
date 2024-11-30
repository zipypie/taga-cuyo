import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/services/profile_service.dart';
import 'package:taga_cuyo/src/features/common_widgets/custom_alert_dialog.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfileScreen> {
  final ProfileService profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();
  XFile? _image; // For storing selected image

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  // Individual variables to track editable states for each field
  bool _isFirstnameEditable = false;
  bool _isLastnameEditable = false;
  bool _isEmailEditable = false;
  bool _isGenderEditable = false;
  bool _isAgeEditable = false;

  bool _isLoading = false; // Add this variable to track the loading state

  // Local variable to track user data
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on initialization
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot snapshot = await ProfileService.currentUser().first;
    if (snapshot.exists) {
      userData = snapshot.data() as Map<String, dynamic>;
      firstnameController.text = userData!['firstname'] ?? '';
      lastnameController.text = userData!['lastname'] ?? '';
      emailController.text = userData!['email'] ?? '';
      genderController.text = userData!['gender'] ?? '';
      ageController.text = userData!['age']?.toString() ?? '0';
      setState(() {}); // Rebuild the widget to display the data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _image != null
                            ? FileImage(File(_image!.path))
                            : (userData?['profile_image'] != null &&
                                    userData!['profile_image'].isNotEmpty
                                ? NetworkImage(userData!['profile_image'])
                                : null),
                        child: _image == null &&
                                (userData?['profile_image'] == null ||
                                    userData!['profile_image'].isEmpty)
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Text fields for updating profile
                  _buildTextField(
                    icon: Icons.person,
                    controller: firstnameController,
                    isEditable: _isFirstnameEditable,
                    onEditTap: () {
                      setState(() {
                        _isFirstnameEditable = !_isFirstnameEditable;
                      });
                    },
                    labelText: 'Unang Pangalan',
                  ),
                  const Divider(),
                  _buildTextField(
                    icon: Icons.person,
                    controller: lastnameController,
                    isEditable: _isLastnameEditable,
                    onEditTap: () {
                      setState(() {
                        _isLastnameEditable = !_isLastnameEditable;
                      });
                    },
                    labelText: 'Apelyido',
                  ),
                  const Divider(),
                  _buildTextField(
                    icon: Icons.email,
                    controller: emailController,
                    isEditable: _isEmailEditable,
                    onEditTap: () {
                      setState(() {
                        _isEmailEditable = !_isEmailEditable;
                      });
                    },
                    labelText: 'Email',
                  ),
                  const Divider(),
                  _buildTextField(
                    icon: Icons.person_outline,
                    controller: genderController,
                    isEditable: _isGenderEditable,
                    onEditTap: () {
                      setState(() {
                        _isGenderEditable = !_isGenderEditable;
                      });
                    },
                    labelText: 'Kasarian',
                  ),
                  const Divider(),
                  _buildTextField(
                    icon: Icons.cake,
                    controller: ageController,
                    isEditable: _isAgeEditable,
                    onEditTap: () {
                      setState(() {
                        _isAgeEditable = !_isAgeEditable;
                      });
                    },
                    labelText: 'Edad',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Update button with indicator
                  MyButton(
                    onTab: (_image != null ||
                            _isFirstnameEditable ||
                            _isLastnameEditable ||
                            _isEmailEditable ||
                            _isGenderEditable ||
                            _isAgeEditable)
                        ? _updateProfile
                        : () {}, // No-op function for disabled state
                    text: _isLoading
                        ? 'I-update ang Profile...'
                        : 'I-update ang Profile', // Text update based on loading state
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          ) // Show a loading spinner if updating
                        : null,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required TextEditingController controller,
    required bool isEditable,
    required VoidCallback onEditTap,
    required String labelText,
    TextInputType? keyboardType,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: TextField(
        controller: controller,
        enabled: isEditable, // Control editing
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
        ),
        keyboardType: keyboardType,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: onEditTap,
      ),
    );
  }

  // Function to pick image from gallery or camera
// Function to pick image from gallery or camera
  Future<void> _pickImage() async {
    final pickedImage = await showDialog<XFile>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pumili ng opsyon'),
          content: const Text('Piliin ang pinagmulan para mag-upload ng iyong larawan sa profile.'),
          actions: [
            TextButton(
              child: const Text('Camera'),
              onPressed: () async {
                final image =
                    await _picker.pickImage(source: ImageSource.camera);
                Navigator.of(context).pop(image); // Return the selected image
              },
            ),
            TextButton(
              child: const Text('Gallery'),
              onPressed: () async {
                final image =
                    await _picker.pickImage(source: ImageSource.gallery);
                Navigator.of(context).pop(image); // Return the selected image
              },
            ),
            TextButton(
              child: const Text('Kanselahin'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close dialog without returning an image
              },
            ),
          ],
        );
      },
    );

    // Update the state with the selected image
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage; // Update the image state
      });
    }
  }

  // Example function to update the profile
 void _updateProfile() async {
      setState(() {
      _isLoading = true; // Set loading state to true when the update begins
    });
  String firstname = firstnameController.text;
  String lastname = lastnameController.text;
  int age = int.tryParse(ageController.text) ?? 0; // Ensure valid integer input
  String gender = genderController.text;

  try {
    String? profileImageUrl; // Variable to hold the uploaded image URL

    if (_image != null) {
      // Upload the image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file
      await imageRef.putFile(File(_image!.path));

      // Get the download URL
      profileImageUrl = await imageRef.getDownloadURL();
    }

    // Now, update the Firestore document with the new profile data
    await profileService.updateUserProfile(
      firstname: firstname,
      lastname: lastname,
      age: age,
      gender: gender,
      profileImage: profileImageUrl, // Use the new image URL
    );

    // Show success message

  await showCustomAlertDialog(
    context,
    'Matagumpay', // Dialog title
    'Ang iyong profile ay na update na!', // Dialog content
    buttonText: 'OK', // Button text
  );

  } catch (e) {
  await showCustomAlertDialog(
    context,
    'Hindi na-update', // Dialog title
    'Uliting muli ang pag-upload!', // Dialog content
    buttonText: 'OK', // Button text
  );
  }setState(() {
        _isLoading = false; // Set loading state to false when update finishes
      });
}

}

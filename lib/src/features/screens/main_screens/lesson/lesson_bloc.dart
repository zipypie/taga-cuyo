import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:taga_cuyo/src/exceptions/logger.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';

class LessonBloc {
  final AuthService _authService = AuthService(); // Correctly instantiate AuthService

  final CollectionReference lessonsCollection = FirebaseFirestore.instance.collection('lessons');
  final Map<String, String> _imageCache = {}; // Cache for image URLs

  // Stream controllers for managing lesson events and states
  final _eventController = StreamController<LessonEvent>();
  final _stateController = StreamController<LessonState>();

  Stream<LessonState> get stateStream => _stateController.stream;

  LessonBloc() {
    // Listen to events and process them
    _eventController.stream.listen(_mapEventToState);
  }

  // Method to handle incoming events
  void _mapEventToState(LessonEvent event) {
    if (event is FetchLessonsEvent) {
      // Fetch userId from the AuthService and pass it to _fetchLessons
      final userId = _authService.getUserId();
      if (userId != null) {
        _fetchLessons(userId);
      } else {
        _stateController.add(LessonError('User not authenticated.'));
      }
    }
  }

  Future<String> fetchImageFromStorage(String imagePath) async {
    if (_imageCache.containsKey(imagePath)) {
      // If image is already cached, return the cached URL
      return _imageCache[imagePath]!;
    }
    
    try {
      if (imagePath.isEmpty) return ''; // Avoid unnecessary fetches
      Reference imageRef = FirebaseStorage.instance.refFromURL(imagePath);
      final downloadUrl = await imageRef.getDownloadURL();
      
      // Cache the image URL for future use
      _imageCache[imagePath] = downloadUrl;
      return downloadUrl;
    } catch (e) {
      Logger.log("Error fetching image from storage: $e");
      return ''; // Return empty string in case of error
    }
  }

  // Fetch lessons and emit states
  Future<void> _fetchLessons(String userId) async {
    _stateController.add(LessonLoading());
    try {
      final snapshot = await lessonsCollection.get();
      final lessonsList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          'lesson_name': data['lesson_name'] ?? 'No name provided',
          'image_path': data['image_path'] ?? '', // Correctly fetch image_path
        };
      }).toList();

      _stateController.add(LessonLoaded(lessonsList, lessonsList.length));
    } catch (error) {
      _stateController.add(LessonError('Error fetching lessons: $error'));
    }
  }

  // Method to add events to the event controller
  void addEvent(LessonEvent event) {
    _eventController.add(event);
  }

  void dispose() {
    _eventController.close();
    _stateController.close();
  }
}

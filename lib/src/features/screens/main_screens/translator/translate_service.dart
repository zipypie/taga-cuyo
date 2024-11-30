import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/exceptions/logger.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveTranslationToFirebase(String sentence, String sourceLang, String targetLang) async {
    try {
      await _firestore.collection('translations').add({
        'sentence': sentence,
        'source_language': sourceLang,
        'target_language' : targetLang,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Logger.log("Translation saved successfully to Firestore!");
    } catch (e) {
      Logger.log("Error saving translation to Firebase: $e");
    }
  } 
}

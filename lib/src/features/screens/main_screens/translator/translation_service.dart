import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taga_cuyo/src/exceptions/logger.dart';

class TranslationService {
  final String apiUrl =
      "https://taga-cuyo-translator-598478516019.asia-southeast1.run.app/translate";

  Future<String> translate(String sentence,
      {required String sourceLang, required String targetLang}) async {
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 3);

    // Convert the sentence to lowercase
    sentence = sentence.toLowerCase();

    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "sentence": sentence,
            "source_lang": sourceLang,
            "target_lang": targetLang,
          }),
        );

        // Log the response to debug
        Logger.log('Response status: ${response.statusCode}');
        Logger.log('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data["translated_sentence"] ?? "Translation failed";
        } else {
          return "Error: ${response.statusCode}";
        }
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          return "Error: $e after $maxRetries attempts";
        }
        await Future.delayed(retryDelay);
      }
    }
    return "Error: Max retries reached";
  }
}

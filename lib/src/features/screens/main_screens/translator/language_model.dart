class LanguagePair {
  String language1;
  String language2;

  LanguagePair({required this.language1, required this.language2});

  // Method to swap the languages
  void swap() {
    String temp = language1;
    language1 = language2;
    language2 = temp;
  }

  // Method to get the current language pair
  List<String> getCurrentLanguages() {
    return [language1, language2];
  }
}

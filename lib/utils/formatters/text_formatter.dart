class TFormatter {
  static String toSentenceCase(String text) {
    if (text.isEmpty) return text;
    // Handle all-caps strings by converting to lowercase first
    String lower = text.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}

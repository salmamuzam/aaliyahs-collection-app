class TFormatter {
  static String toSentenceCase(String text) {
    if (text.isEmpty) return text;
    
    // Split by spaces and hyphens, capitalize each word
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      
      // Handle hyphenated words
      if (word.contains('-')) {
        return word.split('-').map((part) {
          if (part.isEmpty) return part;
          return part[0].toUpperCase() + part.substring(1).toLowerCase();
        }).join('-');
      }
      
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

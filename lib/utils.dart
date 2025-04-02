/// Utility functions for the laptop_reco app

/// Splits a string by comma and returns the first part.
///
/// If the string doesn't contain any commas, returns the original string.
/// If the string is null or empty, returns an empty string.
///
/// Example:
/// ```
/// getFirstPart("Apple MacBook Pro, 16-inch, 2021") => "Apple MacBook Pro"
/// getFirstPart("Dell XPS 13") => "Dell XPS 13"
/// getFirstPart(null) => ""
/// ```
String getFirstPart(String? input) {
  if (input == null || input.isEmpty) {
    return '';
  }

  final part = input.split(',')[0].trim().split("-")[0].trim();
  return part;
}

/// Extracts the brand name from a laptop title.
///
/// Returns the first word of the title, assuming it's the brand name.
/// If the title is null or empty, returns an empty string.
///
/// Example:
/// ```
/// extractBrand("Apple MacBook Pro 16-inch") => "Apple"
/// extractBrand("Dell XPS 13") => "Dell"
/// extractBrand(null) => ""
/// ```
String extractBrand(String? title) {
  if (title == null || title.isEmpty) {
    return '';
  }

  final words = title.trim().split(' ');
  return words.isNotEmpty ? words[0] : '';
}

/// Formats a price string to ensure it has a currency symbol and proper formatting.
///
/// If the price is already formatted with a currency symbol, returns it unchanged.
/// If the price is a number without a symbol, adds a dollar sign.
/// If the price is null or can't be parsed, returns "Price unavailable".
///
/// Example:
/// ```
/// formatPrice("599") => "$599"
/// formatPrice("$599") => "$599"
/// formatPrice("599.99") => "$599.99"
/// formatPrice(null) => "Price unavailable"
/// ```
String formatPrice(String? price) {
  if (price == null || price.isEmpty) {
    return 'Price unavailable';
  }

  // If it already has a currency symbol, return as is
  if (price.contains('\$') || price.contains('€') || price.contains('£')) {
    return price;
  }

  // Try to parse as a number to validate
  try {
    double.parse(price.replaceAll(',', ''));
    return '\$$price';
  } catch (e) {
    return 'Price unavailable';
  }
}

/// Truncates a long string to a specified length and adds ellipsis if needed.
///
/// Example:
/// ```
/// truncateString("This is a very long description that needs to be shortened", 20)
/// => "This is a very long..."
/// ```
String truncateString(String? input, int maxLength) {
  if (input == null || input.isEmpty || input.length <= maxLength) {
    return input ?? '';
  }

  return '${input.substring(0, maxLength)}...';
}

// Add a static utility function for text sanitization at the end of the file
class TextSanitizer {
  /// Sanitizes text by fixing common encoding issues with smart quotes and apostrophes
  static String sanitize(String? text) {
    if (text == null) return '';

    return text
        .replaceAll('\u201D', '"')
        // Handle 3-byte UTF-8 sequences that appear as "â" + two chars
        .replaceAllMapped(
            RegExp('â[\u0080-\u00FF][\u0080-\u00FF]'), (match) => '"')
        // Add specific handling for quote marks
        .replaceAll('â€œ', '"') // Left double quote
        .replaceAll('â€', '"') // Right double quote
        .replaceAll('â€™', "'") // Right single quote
        .replaceAll('â€˜', "'") // Left single quote
        // Direct Unicode replacements for good measure
        .replaceAll('\u201C', '"') // Left double quote mark
        .replaceAll('\u201D', '"') // Right double quote mark
        .replaceAll('\u2018', "'") // Left single quote mark
        .replaceAll('\u2019', "'"); // Right single quote mark
  }
}

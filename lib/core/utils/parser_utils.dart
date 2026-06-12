class ParserUtils {
  /// Safely parses a value to double, handling strings with commas and null values.
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Replace comma with dot for proper parsing
      final normalized = value.replaceAll(',', '.').trim();
      return double.tryParse(normalized);
    }
    return null;
  }

  /// Safely parses a value to int, handling strings and null values.
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) {
      final normalized = value.trim();
      return int.tryParse(normalized) ?? double.tryParse(normalized.replaceAll(',', '.'))?.toInt();
    }
    return null;
  }
}

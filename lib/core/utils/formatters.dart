/// Common formatting utilities.
class Formatters {
  static String formatScorePercentage(double score, double total) {
    if (total == 0) return '0%';
    final percentage = (score / total) * 100;
    return '${percentage.toStringAsFixed(0)}%';
  }

  /// Formats an integer with thousands separators, e.g. 12450 -> "12,450".
  static String formatWithCommas(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i - 1;
      buffer.write(digits[i]);
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }
    return value < 0 ? '-$buffer' : buffer.toString();
  }

  /// Formats a date as an ISO-like numeric string, e.g. "2026-01-31".
  /// Used until an [intl] dependency is introduced for locale-aware dates.
  static String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Formatters._();
}

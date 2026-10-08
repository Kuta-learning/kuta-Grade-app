/// Common formatting utilities.
class Formatters {
  static String formatScorePercentage(double score, double total) {
    if (total == 0) return '0%';
    final percentage = (score / total) * 100;
    return '${percentage.toStringAsFixed(0)}%';
  }

  Formatters._();
}

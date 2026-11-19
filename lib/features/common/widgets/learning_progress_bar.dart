import 'package:flutter/material.dart';

/// Reusable learning progress visualizer.
class LearningProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const LearningProgressBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress.clamp(0.0, 1.0),
    );
  }
}

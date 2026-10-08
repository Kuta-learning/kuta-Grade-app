import 'package:flutter/material.dart';

/// Grade 8 timed mock test timer widget.
class Grade8ExamTimerWidget extends StatelessWidget {
  final int remainingSeconds;

  const Grade8ExamTimerWidget({
    super.key,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Text('Time Remaining: ${remainingSeconds}s');
  }
}

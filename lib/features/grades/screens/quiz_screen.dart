import 'package:flutter/material.dart';

/// Assessment and quiz screen for Grade 6, 8, and 12.
class QuizScreen extends StatelessWidget {
  final String quizId;

  const QuizScreen({
    super.key,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Assessment'),
      ),
      body: Center(
        child: Text('Quiz Assessment $quizId'),
      ),
    );
  }
}

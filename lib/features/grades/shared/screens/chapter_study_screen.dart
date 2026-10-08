import 'package:flutter/material.dart';

/// Chapter reading / lesson view screen.
class ChapterStudyScreen extends StatelessWidget {
  final String chapterId;

  const ChapterStudyScreen({
    super.key,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chapter Study'),
      ),
      body: Center(
        child: Text('Study Content for Chapter $chapterId'),
      ),
    );
  }
}

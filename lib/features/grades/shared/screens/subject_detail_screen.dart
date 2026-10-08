import 'package:flutter/material.dart';

/// Subject chapters and curriculum overview screen.
class SubjectDetailScreen extends StatelessWidget {
  final String subjectId;

  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Details'),
      ),
      body: Center(
        child: Text('Subject Details for $subjectId'),
      ),
    );
  }
}

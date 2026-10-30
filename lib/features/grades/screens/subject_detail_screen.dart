import 'package:flutter/material.dart';
import 'course_detail_screen.dart';

/// Backward-compatible subject chapters and course overview screen.
class SubjectDetailScreen extends StatelessWidget {
  final String subjectId;
  final String? subjectTitle;

  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
    this.subjectTitle,
  });

  @override
  Widget build(BuildContext context) {
    return CourseDetailScreen(
      courseId: subjectId,
      title: subjectTitle ?? 'Course Details',
    );
  }
}

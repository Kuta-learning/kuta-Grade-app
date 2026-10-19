import 'package:flutter/material.dart';
import '../../../../core/constants/grade_level.dart';

import '../../grade_12/screens/grade_12_matric_exam_screen.dart';

/// Reusable dashboard screen for Grades 6, 8, and 12 sharing the same Figma design.
class GradeDashboardScreen extends StatelessWidget {
  final GradeLevel gradeLevel;

  const GradeDashboardScreen({
    super.key,
    required this.gradeLevel,
  });

  @override
  Widget build(BuildContext context) {
    if (gradeLevel == GradeLevel.grade12) {
      return const Grade12MatricExamScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Dashboard (${gradeLevel.displayName})'),
      ),
      body: Center(
        child: Text('Dashboard for ${gradeLevel.displayName}'),
      ),
    );
  }
}

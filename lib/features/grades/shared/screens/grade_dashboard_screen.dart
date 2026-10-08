import 'package:flutter/material.dart';
import '../../../../core/constants/grade_level.dart';

/// Reusable dashboard screen for Grades 6, 8, and 12 sharing the same Figma design.
class GradeDashboardScreen extends StatelessWidget {
  final GradeLevel gradeLevel;

  const GradeDashboardScreen({
    super.key,
    required this.gradeLevel,
  });

  @override
  Widget build(BuildContext context) {
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

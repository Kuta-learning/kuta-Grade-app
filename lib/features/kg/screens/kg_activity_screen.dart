import 'package:flutter/material.dart';

/// Interactive game/lesson screen for Kindergarten.
class KgActivityScreen extends StatelessWidget {
  final String activityId;

  const KgActivityScreen({
    super.key,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Kindergarten Activity: $activityId'),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Reusable profile avatar component.
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      child: const Icon(Icons.person),
    );
  }
}

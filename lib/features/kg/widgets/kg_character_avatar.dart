import 'package:flutter/material.dart';

/// Animated/illustrated mascot avatar for Kindergarten learners.
class KgCharacterAvatar extends StatelessWidget {
  final String assetPath;
  final double size;

  const KgCharacterAvatar({
    super.key,
    required this.assetPath,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: const Icon(Icons.face, size: 48),
    );
  }
}

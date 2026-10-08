import 'package:flutter/material.dart';

/// Colorful, tactile card component tailored for young Kindergarten learners.
class KgCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;

  const KgCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? Colors.amber.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_typography.dart';

/// Reusable header displayed on authentication screens.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poppins heading (pixel parity with the previous Material 3
        // headlineMedium: 28px / 36px, Regular 400)
        Text(
          title,
          style: AppTypography.displayLg.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            height: 36 / 28,
            letterSpacing: 0.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        // Open Sans body (pixel parity with the previous Material 3
        // bodyMedium: 14px / 20px, Regular 400)
        Text(
          subtitle,
          style: AppTypography.bodyLg.copyWith(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

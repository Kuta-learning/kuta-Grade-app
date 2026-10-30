import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Reusable white elevated card used across the Profile screen.
/// Matches the Figma ref: `#FFFFFF`, warm 30% border, 12px radius,
/// soft 0 1px 2px shadow — all derived from existing design tokens.
class ProfileCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final GestureTapCallback? onTap;

  const ProfileCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(
          color: AppColors.authIconBrown.withValues(alpha: 0.3),
        ),
        boxShadow: AppElevation.elevation1,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      return Material(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.roundedXl,
        child: InkWell(
          borderRadius: AppRadius.roundedXl,
          onTap: onTap,
          child: card,
        ),
      );
    }
    return card;
  }
}

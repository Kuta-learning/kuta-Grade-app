import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';

/// Action buttons row: Edit Profile (outlined navy) and
/// Manage Subscription (filled orange CTA).
class ProfileActionButtons extends StatelessWidget {
  final VoidCallback? onEditProfile;
  final VoidCallback? onManageSubscription;

  const ProfileActionButtons({
    super.key,
    this.onEditProfile,
    this.onManageSubscription,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onEditProfile,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surfaceWhite,
              foregroundColor: AppColors.navy700,
              side: const BorderSide(color: AppColors.navy700),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.roundedLg,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.space4,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit_outlined, size: 18),
                AppSpacing.hGap2,
                Text('Edit Profile', style: AppTypography.bodyXl),
              ],
            ),
          ),
        ),
        AppSpacing.hGap4,
        Expanded(
          child: ElevatedButton(
            onPressed: onManageSubscription,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange500,
              foregroundColor: AppColors.surfaceWhite,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.roundedLg,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.space4,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sell_outlined, size: 18),
                AppSpacing.hGap2,
                Text('Manage Subscription', style: AppTypography.bodyXl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

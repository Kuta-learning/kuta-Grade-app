import 'package:flutter/material.dart';
import '../../../core/constants/app_typography.dart';

/// Action buttons row: Edit Profile (outlined blue) and
/// Manage Subscription (filled orange CTA) matching Screenshot 1.
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
        // Left: Edit Profile
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onEditProfile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1E5BB0),
                    width: 1.4,
                  ),
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 17,
                        color: Color(0xFF1E5BB0),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Edit Profile',
                        maxLines: 1,
                        style: AppTypography.labelMdMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E5BB0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Right: Manage Subscription
        Expanded(
          child: Material(
            color: const Color(0xFFFF6A00),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onManageSubscription,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_offer_outlined,
                        size: 17,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Manage Subscription',
                        maxLines: 1,
                        style: AppTypography.labelMdMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

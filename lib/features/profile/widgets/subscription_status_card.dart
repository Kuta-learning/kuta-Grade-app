import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../models/profile_model.dart';
import 'profile_card.dart';

/// Subscription status card: heading with ACTIVE/FREE pill badge,
/// plan row with "Change Subscription" link, and renewal date display.
class SubscriptionStatusCard extends StatelessWidget {
  final ProfileModel? profile;
  final VoidCallback? onChangeSubscription;

  const SubscriptionStatusCard({
    super.key,
    required this.profile,
    this.onChangeSubscription,
  });

  @override
  Widget build(BuildContext context) {
    final isPremium = profile?.isPremium ?? false;
    final isActive = profile?.subscriptionActive ?? isPremium;

    return ProfileCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space6,
        AppSpacing.space6,
        AppSpacing.space4,
        AppSpacing.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading + status badge
          Row(
            children: [
              Expanded(
                child: Text(
                  'SUBSCRIPTION STATUS',
                  style: AppTypography.bodyXl.copyWith(
                    color: AppColors.authBrown,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              _buildBadge(isPremium, isActive),
            ],
          ),
          AppSpacing.vGap2,
          // Plan row + change link
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.planName ??
                          (isPremium ? 'Premium Plan' : 'Free Plan'),
                      style: AppTypography.bodyXl
                          .copyWith(color: AppColors.navy700),
                    ),
                    Text(
                      _billingLabel,
                      style: AppTypography.labelMdMedium
                          .copyWith(color: AppColors.authBrown),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onChangeSubscription,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size.fromHeight(AppSpacing.space8 / 2),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Change Subscription',
                  style: AppTypography.bodyXl
                      .copyWith(color: AppColors.orange900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(bool isPremium, bool isActive) {
    final active = isPremium && isActive;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: active
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.containerHigh,
        borderRadius: BorderRadius.circular(AppRadius.xl), // pill for 24px height
      ),
      child: Text(
        active ? 'ACTIVE' : 'FREE',
        style: AppTypography.labelMdMedium.copyWith(
          color: active ? AppColors.success : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String get _billingLabel {
    final date = profile?.nextBillingDate;
    final formatted =
        date != null ? Formatters.formatDate(date) : null;
    return 'Next billing renewal: ${formatted ?? '—'}';
  }
}

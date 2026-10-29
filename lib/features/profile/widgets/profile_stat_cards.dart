import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../models/profile_model.dart';
import 'profile_card.dart';

/// Dual performance metrics row: Total Points (peach) and Global Rank (sky blue),
/// matching the Figma stat mini-cards. Nullable stats render as dash placeholders.
class ProfileStatCards extends StatelessWidget {
  final ProfileModel? profile;

  const ProfileStatCards({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProfileStatCard(
            icon: Icons.star_rounded,
            label: 'TOTAL POINTS',
            value: _pointsValue,
            backgroundColor:
                AppColors.orange500.withValues(alpha: 0.1),
            borderColor: AppColors.orange500.withValues(alpha: 0.2),
            iconColor: AppColors.orange900,
            labelColor: AppColors.buttonTextBrown,
            valueColor: AppColors.buttonTextBrown,
          ),
        ),
        AppSpacing.hGap4,
        Expanded(
          child: _ProfileStatCard(
            icon: Icons.bar_chart_rounded,
            label: 'GLOBAL RANK',
            value: _rankValue,
            backgroundColor: AppColors.navyLight100,
            borderColor: AppColors.brandBlue.withValues(alpha: 0.15),
            iconColor: AppColors.brandBlue,
            labelColor: AppColors.navy900,
            valueColor: AppColors.navy900,
          ),
        ),
      ],
    );
  }

  String get _pointsValue {
    final points = profile?.totalPoints;
    return points != null ? Formatters.formatWithCommas(points) : '—';
  }

  String get _rankValue {
    final rank = profile?.globalRank;
    return rank != null ? '#$rank' : '—';
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color labelColor;
  final Color valueColor;

  const _ProfileStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: iconColor),
          AppSpacing.vGap2,
          Text(
            label,
            style: AppTypography.labelMdMedium.copyWith(
              color: labelColor,
              letterSpacing: 0.6,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: AppTypography.statValue.copyWith(color: valueColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

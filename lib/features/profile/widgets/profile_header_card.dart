import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../models/profile_model.dart';
import 'profile_avatar.dart';
import 'profile_card.dart';

/// White elevated profile card: avatar, user name, and grade/stream subtitle.
/// Includes the subtle atmospheric brand gradient overlay from the Figma ref.
class ProfileHeaderCard extends StatelessWidget {
  final ProfileModel? profile;
  final VoidCallback? onEditTapped;

  const ProfileHeaderCard({
    super.key,
    required this.profile,
    this.onEditTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: Stack(
        children: [
          // Atmospheric gradient overlay (orange900 -> brandBlue @ 5%)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: AppRadii.card,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.orange900.withValues(alpha: 0.05),
                      AppColors.brandBlue.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfileAvatar(
                profile: profile,
                onEditTapped: onEditTapped,
              ),
              AppSpacing.vGap6,
              Text(
                _displayName,
                style: AppTypography.displayLg,
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGap1,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 20,
                    color: AppColors.orange900,
                  ),
                  AppSpacing.hGap1,
                  Flexible(
                    child: Text(
                      _subtitle,
                      style: AppTypography.subtitleLg
                          .copyWith(color: AppColors.authBrown),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _displayName {
    final name = profile?.fullName.trim() ?? '';
    return name.isNotEmpty ? name : '—';
  }

  String get _subtitle {
    final grade = profile?.gradeLevel?.displayName;
    final secondary = profile?.secondaryLine;
    final parts = [
      ?grade,
      ?secondary,
    ];
    return parts.isNotEmpty ? parts.join(' • ') : '—';
  }
}

/// Local radius alias so the decorative overlay matches the card radius
/// (12px = [AppRadius.xl]) without leaking raw values.
class AppRadii {
  static const BorderRadius card = BorderRadius.all(
    Radius.circular(AppRadius.xl),
  );
}

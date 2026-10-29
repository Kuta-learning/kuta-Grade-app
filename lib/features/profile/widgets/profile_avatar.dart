import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/profile_model.dart';
/// Circular avatar with the orange brand ring, soft peach glow, and a
/// bottom-right pencil edit badge — matching the Figma profile header.
/// The edit badge is visual-only this phase (avatar editing comes later).
class ProfileAvatar extends StatelessWidget {
  final ProfileModel? profile;
  final double size;
  final VoidCallback? onEditTapped;

  const ProfileAvatar({
    super.key,
    this.profile,
    this.size = 96,
    this.onEditTapped,
  });

  String get _initials {
    final name = profile?.fullName ?? '';
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    final buffer = StringBuffer(parts.first[0].toUpperCase());
    if (parts.length > 1) {
      buffer.write(parts.last[0].toUpperCase());
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * 0.35;
    final ringWidth = 4.0;
    final hasImage = profile?.avatarUrl?.isNotEmpty ?? false;

    return SizedBox(
      width: size + badgeSize / 2,
      height: size + badgeSize / 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ring + soft peach glow + avatar image
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.containerHigh,
                border: Border.all(
                  color: AppColors.orange500,
                  width: ringWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange500.withValues(alpha: 0.25),
                    spreadRadius: ringWidth,
                    blurRadius: 0,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: (size - ringWidth * 2) / 2,
                backgroundColor: AppColors.navyLight100,
                backgroundImage:
                    hasImage ? NetworkImage(profile!.avatarUrl!) : null,
                child: hasImage
                    ? null
                    : _buildFallback(badgeSize * 0.55),
              ),
            ),
          ),
          // Pencil edit badge (bottom-right)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEditTapped, // visual-only this phase
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.orange900,
                  border: Border.all(
                    color: AppColors.surfaceWhite,
                    width: 2,
                  ),
                  boxShadow: AppElevation.elevationLg,
                ),
                child: Icon(
                  Icons.edit,
                  size: badgeSize * 0.4,
                  color: AppColors.surfaceWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(double iconSize) {
    final initials = _initials;
    if (initials.isEmpty) {
      return Icon(
        Icons.person,
        size: size * 0.5,
        color: AppColors.navy700,
      );
    }
    return Text(
      initials,
      style: TextStyle(
        fontSize: size * 0.3,
        fontWeight: FontWeight.w600,
        color: AppColors.navy700,
      ),
    );
  }
}

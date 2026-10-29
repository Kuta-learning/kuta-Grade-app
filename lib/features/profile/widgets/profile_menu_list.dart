import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_snackbar.dart';
import 'profile_card.dart';

/// Support & security menu list: Payment Methods, Help Center, Privacy Policy.
/// Tiles show "Coming soon" snackbars until dedicated screens exist.
class ProfileMenuList extends StatelessWidget {
  const ProfileMenuList({super.key});

  static const List<({IconData icon, String title})> _items = [
    (icon: Icons.credit_card, title: 'Payment Methods'),
    (icon: Icons.help_outline, title: 'Help Center'),
    (icon: Icons.security, title: 'Privacy Policy'),
  ];

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      padding: const EdgeInsets.only(top: AppSpacing.space2 / 2),
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.authIconBrown.withValues(alpha: 0.3),
              ),
            _MenuTile(
              item: _items[i],
              isLast: i == _items.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final ({IconData icon, String title}) item;
  final bool isLast;

  const _MenuTile({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl))
          : null,
      child: InkWell(
        onTap: () => AppSnackBar.showInfo(
          context,
          '${item.title} is coming soon.',
          title: 'Coming soon',
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Row(
            children: [
              Icon(item.icon, size: 24, color: AppColors.navy700),
              AppSpacing.hGap4,
              Expanded(
                child: Text(item.title, style: AppTypography.bodyXl),
              ),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: AppColors.authIconBrown,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_typography.dart';

import '../../../core/widgets/app_snackbar.dart';

/// Support & settings menu list matching Screenshot 1 reference design.
/// Three items: Payment Methods, Help Center, Privacy Policy with blue icons and chevrons.
class ProfileMenuList extends StatelessWidget {
  const ProfileMenuList({super.key});

  static const List<({IconData icon, String title})> _items = [
    (icon: Icons.payments_outlined, title: 'Payment Methods'),
    (icon: Icons.help_outline_rounded, title: 'Help Center'),
    (icon: Icons.shield_outlined, title: 'Privacy Policy'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFF1F5F9),
              ),
            _MenuTile(
              item: _items[i],
              isFirst: i == 0,
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
  final bool isFirst;
  final bool isLast;

  const _MenuTile({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        onTap: () => AppSnackBar.showInfo(
          context,
          '${item.title} is coming soon.',
          title: 'Coming soon',
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 22,
                color: const Color(0xFF1D4ED8), // Royal blue icon from screenshot
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTypography.bodyMdMedium.copyWith(
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


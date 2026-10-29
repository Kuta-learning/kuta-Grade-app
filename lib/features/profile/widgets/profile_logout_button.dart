import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../authentication/bloc/auth_bloc.dart';
import 'profile_card.dart';

/// Outlined logout card. Delegates session clearing exclusively to [AuthBloc]'s
/// `LogoutRequested` event (single source of truth), whose handler invokes
/// `authService.logout()` and emits `AuthUnauthenticated` — the screen-level
/// listener then resets this module and navigates to the Login screen.
class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      padding: EdgeInsets.zero,
      onTap: () => context.read<AuthBloc>().add(const LogoutRequested()),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: AppColors.error, size: 20),
            AppSpacing.hGap2,
            Text(
              'Logout',
              style: AppTypography.bodyXl.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

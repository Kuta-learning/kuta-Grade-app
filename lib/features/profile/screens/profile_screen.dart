import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_typography.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../grades/widgets/grade_screen_shell.dart';
import '../bloc/profile_bloc.dart';
import '../models/profile_model.dart';
import '../widgets/profile_action_buttons.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/profile_menu_list.dart';
import '../widgets/profile_stat_cards.dart';
import '../widgets/subscription_status_card.dart';

/// Premium profile screen matching Screenshot 1 reference design.
/// Header, dual performance stat cards, action buttons, subscription status,
/// support menu, and logout, backed by the 5-item orange capsule navbar from Screenshot 2.
class ProfileScreen extends StatefulWidget {
  final bool showBottomNav;

  const ProfileScreen({super.key, this.showBottomNav = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile data on entry
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.read<ProfileBloc>().add(const ProfileResetRequested());
          AppSnackBar.showSuccess(
            context,
            'You have been logged out successfully.',
            title: 'Goodbye',
          );
          context.go(RouteNames.login);
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final (profile, isLoading, errorMessage) = _resolve(state);

          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: _ProfileAppBar(
              onNotificationsPressed: () => AppSnackBar.showInfo(
                context,
                'No new notifications right now.',
                title: 'Notifications',
              ),
            ),
            body: SafeArea(
              top: false,
              child: _buildBody(context, profile, isLoading, errorMessage),
            ),
            bottomNavigationBar: widget.showBottomNav
                ? const GradeBottomNavBar(currentIndex: 3)
                : null,
          );
        },
      ),
    );
  }

  (ProfileModel?, bool, String?) _resolve(ProfileState state) {
    return switch (state) {
      ProfileLoaded(:final profile) => (profile, false, null),
      ProfileLoading(:final previous) => (previous, previous == null, null),
      ProfileError(:final message, :final lastProfile) => (
        lastProfile,
        false,
        message,
      ),
      ProfileInitial() => (null, true, null),
    };
  }

  Widget _buildBody(
    BuildContext context,
    ProfileModel? profile,
    bool isLoading,
    String? errorMessage,
  ) {
    // Full-screen loading
    if (profile == null && isLoading) {
      return const Center(
        child: AppLoadingIndicator(color: AppColors.orange500),
      );
    }

    // Full-screen error with retry when nothing is loaded yet
    if (profile == null && errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Something went wrong',
                style: AppTypography.subtitleLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.read<ProfileBloc>().add(
                  const ProfileLoadRequested(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C97),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    // Loaded content matching Screenshot 1 layout
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeaderCard(
            profile: profile,
            onEditTapped: () => _showComingSoon(context, 'Profile editing'),
          ),
          const SizedBox(height: 12),
          ProfileStatCards(profile: profile),
          const SizedBox(height: 12),
          ProfileActionButtons(
            onEditProfile: () => _showComingSoon(context, 'Profile editing'),
            onManageSubscription: () =>
                _showComingSoon(context, 'Subscription management'),
          ),
          const SizedBox(height: 12),
          SubscriptionStatusCard(
            profile: profile,
            onChangeSubscription: () =>
                _showComingSoon(context, 'Subscription management'),
          ),
          const SizedBox(height: 12),
          const ProfileMenuList(),
          const SizedBox(height: 14),
          const ProfileLogoutButton(),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    AppSnackBar.showInfo(
      context,
      '$feature is coming in an upcoming update.',
      title: 'Coming soon',
    );
  }
}

/// Navy/Royal blue app bar matching Screenshot 1:
/// "Kuta Learning" title and notification bell (no back arrow on this main tab screen).
class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationsPressed;

  const _ProfileAppBar({this.onNotificationsPressed});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0F4C97), // Brand Primary Royal Blue
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Text(
        'Kuta Learning',
        style: AppTypography.headlineMd.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 24,
          ),
          tooltip: 'Notifications',
          onPressed: onNotificationsPressed,
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

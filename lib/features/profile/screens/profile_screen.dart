import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../models/profile_model.dart';
import '../widgets/profile_action_buttons.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/profile_menu_list.dart';
import '../widgets/profile_stat_cards.dart';
import '../widgets/subscription_status_card.dart';

/// Premium profile screen: bento-style header, performance metrics,
/// account actions, subscription status, support menu, and logout.
///
/// State: provided by the root-level [ProfileBloc] (loaded/dispatched here);
/// logout: delegates to [AuthBloc]'s `LogoutRequested` and reacts to the
/// resulting `AuthUnauthenticated` state (same listener pattern as Login).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load on first entry; silent refresh on later uses via previous data.
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Reset the singleton ProfileBloc so no stale data survives logout,
          // then return the user to the Login screen (design contract).
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
            backgroundColor: AppColors.surfaceApp,
            appBar: _ProfileAppBar(
              onNotificationsPressed: () => AppSnackBar.showInfo(
                context,
                'No new notifications right now.',
                title: 'Notifications',
              ),
            ),
            body: SafeArea(
              child: _buildBody(context, profile, isLoading, errorMessage),
            ),
          );
        },
      ),
    );
  }

  (ProfileModel?, bool, String?) _resolve(ProfileState state) {
    return switch (state) {
      ProfileLoaded(:final profile) => (profile, false, null),
      ProfileLoading(:final previous) => (previous, previous == null, null),
      ProfileError(:final message, :final lastProfile) =>
        (lastProfile, false, message),
      ProfileInitial() => (null, true, null),
    };
  }

  Widget _buildBody(
    BuildContext context,
    ProfileModel? profile,
    bool isLoading,
    String? errorMessage,
  ) {
    // Full-screen loading (normal spinner, not the Rive animation)
    if (profile == null && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Full-screen error with retry when nothing is loaded yet
    if (profile == null && errorMessage != null) {
      return Center(
        child: Padding(
          padding: AppSpacing.p4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Something went wrong',
                style: AppTypography.headlineMd,
              ),
              AppSpacing.vGap2,
              Text(
                errorMessage,
                style: AppTypography.bodyMd
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGap4,
              TextButton.icon(
                onPressed: () => context
                    .read<ProfileBloc>()
                    .add(const ProfileLoadRequested()),
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    // Loaded content (or silent refresh keeping previous data)
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeaderCard(
            profile: profile,
            onEditTapped: () => _showComingSoon(context, 'Profile editing'),
          ),
          AppSpacing.vGap4,
          ProfileStatCards(profile: profile),
          AppSpacing.vGap4,
          ProfileActionButtons(
            onEditProfile: () => _showComingSoon(context, 'Profile editing'),
            onManageSubscription: () =>
                _showComingSoon(context, 'Subscription management'),
          ),
          AppSpacing.vGap4,
          SubscriptionStatusCard(
            profile: profile,
            onChangeSubscription: () =>
                _showComingSoon(context, 'Subscription management'),
          ),
          AppSpacing.vGap4,
          const ProfileMenuList(),
          AppSpacing.vGap4,
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

/// Navy blue app bar: back arrow, screen title, and notification bell.
class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationsPressed;

  const _ProfileAppBar({this.onNotificationsPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.navy700,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.surfaceWhite),
        tooltip: 'Back',
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.examSimulator);
          }
        },
      ),
      title: Text(
        'Kuta Learning',
        style: AppTypography.titleMd.copyWith(color: AppColors.surfaceWhite),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.surfaceWhite,
            size: 24,
          ),
          tooltip: 'Notifications',
          onPressed: onNotificationsPressed,
        ),
        const SizedBox(width: AppSpacing.space1),
      ],
    );
  }
}

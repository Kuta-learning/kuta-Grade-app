import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../storage/shared_prefs_storage.dart';
import '../storage/storage_keys.dart';
import '../../features/authentication/bloc/auth_bloc.dart';
import '../../features/authentication/models/user_model.dart';
import '../../features/authentication/screens/grade_selection_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/common/screens/onboarding_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/common/screens/splash_screen.dart';
import '../../features/grades/shared/screens/grade_dashboard_screen.dart';
import '../../features/kg/screens/kg_home_screen.dart';
import 'route_names.dart';

/// Top-level application router configuration using GoRouter.
/// Directs users across splash, authentication, KG, and Grade modules.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.gradeSelection,
        name: 'gradeSelection',
        builder: (context, state) => const GradeSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.kgHome,
        name: 'kgHome',
        builder: (context, state) => const KgHomeScreen(),
      ),
      GoRoute(
        path: RouteNames.gradeDashboard,
        name: 'gradeDashboard',
        builder: (context, state) => const GradeDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.subjectDetail,
        name: 'subjectDetail',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Subject Detail Screen'))),
      ),
      GoRoute(
        path: RouteNames.quiz,
        name: 'quiz',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Quiz Screen'))),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Profile Screen'))),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('No route defined for ${state.uri}')),
    ),
  );

  /// Resolves which screen the app should route to after the splash screen finishes:
  /// 1. If the user has NOT seen onboarding -> [RouteNames.onboarding]
  /// 2. If the user has seen onboarding, but has NOT registered/authenticated -> [RouteNames.register]
  /// 3. If the user is authenticated, but has NOT selected their grade level -> [RouteNames.gradeSelection]
  /// 4. If the user is authenticated AND has selected their grade level -> [RouteNames.gradeDashboard] (or [RouteNames.kgHome])
  static Future<String> resolveInitialRoute() async {
    final storage = await SharedPrefsStorage.getInstance();

    // 1. Check if user has completed introductory onboarding slides
    final hasSeenOnboarding = await storage.getBool(StorageKeys.hasSeenOnboarding) ?? false;
    if (!hasSeenOnboarding) {
      return RouteNames.onboarding;
    }

    // 2. Check if user has registered / logged in (authenticated session)
    final authUserRaw = await storage.getString(StorageKeys.authUser);
    final isAuthenticated = authUserRaw != null && authUserRaw.isNotEmpty;
    if (!isAuthenticated) {
      return RouteNames.register;
    }

    // 3. Check if user has completed grade & academic stream selection
    final hasSelectedGrade = await storage.getBool(StorageKeys.hasSelectedGrade) ?? false;
    if (!hasSelectedGrade) {
      return RouteNames.gradeSelection;
    }

    // 4. User is authenticated and grade is chosen: route to appropriate dashboard
    final user = UserModel.fromJsonString(authUserRaw);
    if (user != null && user.isKgStudent) {
      return RouteNames.kgHome;
    }
    return RouteNames.gradeDashboard;
  }

  /// Erases all navigation and session preferences from [SharedPreferences]
  /// and resets the [AuthBloc] state, redirecting the user back to [RouteNames.onboarding]
  /// so that the entire first-time user journey can be tested again.
  static Future<void> resetNavigationData(BuildContext context) async {
    final storage = await SharedPrefsStorage.getInstance();
    await storage.clear();

    if (context.mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
      context.go(RouteNames.onboarding);
    }
  }

  AppRouter._();
}

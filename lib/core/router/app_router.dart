import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/common/screens/splash_screen.dart';
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
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.kgHome,
        name: 'kgHome',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('KG Home Screen')),
        ),
      ),
      GoRoute(
        path: RouteNames.gradeDashboard,
        name: 'gradeDashboard',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Grade Dashboard Screen')),
        ),
      ),
      GoRoute(
        path: RouteNames.subjectDetail,
        name: 'subjectDetail',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Subject Detail Screen')),
        ),
      ),
      GoRoute(
        path: RouteNames.quiz,
        name: 'quiz',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Quiz Screen')),
        ),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Profile Screen')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('No route defined for ${state.uri}'),
      ),
    ),
  );

  AppRouter._();
}

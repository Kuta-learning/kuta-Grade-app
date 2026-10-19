import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/common/screens/onboarding_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/common/screens/splash_screen.dart';
import '../../features/grades/grade_12/screens/grade_12_matric_exam_screen.dart';
import '../../features/grades/grade_12/screens/grade_12_subject_exams_screen.dart';
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
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.kgHome,
        name: 'kgHome',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('KG Home Screen'))),
      ),
      GoRoute(
        path: RouteNames.gradeDashboard,
        name: 'gradeDashboard',
        builder: (context, state) => const Grade12MatricExamScreen(),
      ),
      GoRoute(
        path: RouteNames.examSimulator,
        name: 'examSimulator',
        builder: (context, state) => const Grade12MatricExamScreen(),
      ),
      GoRoute(
        path: RouteNames.grade12MatricExam,
        name: 'grade12MatricExam',
        builder: (context, state) => const Grade12MatricExamScreen(),
      ),
      GoRoute(
        path: RouteNames.subjectExams,
        name: 'subjectExams',
        builder: (context, state) {
          final title = state.uri.queryParameters['subject'] ?? 'Mathematics';
          final stream = state.uri.queryParameters['stream'] ?? 'NATURAL SCIENCE STREAM';
          final subtitle = state.uri.queryParameters['subtitle'] ?? 'Official National University Entrance Papers';
          return Grade12SubjectExamsScreen(
            subjectTitle: title,
            streamTitle: stream,
            subtitle: subtitle,
          );
        },
      ),
      GoRoute(
        path: RouteNames.subjectDetail,
        name: 'subjectDetail',
        builder: (context, state) {
          final title = state.uri.queryParameters['subject'] ?? 'Mathematics';
          return Grade12SubjectExamsScreen(subjectTitle: title);
        },
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

  AppRouter._();
}

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
import '../../features/authentication/screens/otp_verification_screen.dart';
import '../../features/authentication/screens/reset_password_screen.dart';
import '../screens/animation_preview_screen.dart';
import '../../features/common/screens/onboarding_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/common/screens/splash_screen.dart';
import '../../features/kg/screens/kg_home_screen.dart';
import '../../features/grades/screens/exam_simulator_screen.dart';
import '../../features/grades/screens/subject_exams_screen.dart';
import '../../features/grades/screens/bookmarks_screen.dart';
import '../../features/grades/widgets/grade_screen_shell.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/grades/screens/high_school_notes_screen.dart';
import '../../features/grades/screens/note_detail_screen.dart';
import '../../features/grades/screens/lesson_detail_screen.dart';
import 'route_names.dart';

/// Top-level application router configuration using GoRouter.
/// Directs users across splash, authentication, KG, and Grade modules.
class AppRouter {
  static final GoRouter router = GoRouter(
    // Default app startup flow (Splash -> Onboarding / Auth / Dashboard)

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
        builder: (context, state) {
          final prefillEmail = state.uri.queryParameters['email'];
          final isRegistered =
              state.uri.queryParameters['registered'] == 'true';
          return LoginScreen(
            prefillEmail: prefillEmail,
            isJustRegistered: isRegistered,
          );
        },
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.gradeSelection,
        name: 'gradeSelection',
        builder: (context, state) {
          final stepParam = state.uri.queryParameters['step'];
          final initialStep = int.tryParse(stepParam ?? '1') ?? 1;
          return GradeSelectionScreen(initialStep: initialStep);
        },
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.otpVerification,
        name: 'otpVerification',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: 'resetPassword',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(email: email, resetToken: token);
        },
      ),
      GoRoute(
        path: RouteNames.kgHome,
        name: 'kgHome',
        builder: (context, state) => const KgHomeScreen(),
      ),
      // ── Grade Module with Persistent Bottom Navigation Shell ─────
      ShellRoute(
        builder: (context, state, child) {
          return MainGradeAppShell(
            location: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: RouteNames.grade12MatricExam,
            name: 'grade12MatricExam',
            builder: (context, state) => const ExamSimulatorScreen(),
          ),
          GoRoute(
            path: RouteNames.examSimulator,
            name: 'examSimulator',
            builder: (context, state) => const ExamSimulatorScreen(),
          ),
          GoRoute(
            path: RouteNames.subjectDetail,
            name: 'subjectDetail',
            builder: (context, state) {
              final title =
                  state.uri.queryParameters['subject'] ?? 'Mathematics';
              final subjectId = state.uri.queryParameters['subjectId'];
              return SubjectExamsScreen(
                subjectId: subjectId,
                subjectTitle: title,
              );
            },
          ),
          GoRoute(
            path: RouteNames.subjectExams,
            name: 'subjectExams',
            builder: (context, state) {
              final subject =
                  state.uri.queryParameters['subject'] ?? 'Mathematics';
              final subtitle = state.uri.queryParameters['subtitle'] ??
                  'Official National University Entrance Papers';
              final subjectId = state.uri.queryParameters['subjectId'];
              return SubjectExamsScreen(
                subjectId: subjectId,
                subjectTitle: subject,
                subtitle: subtitle,
              );
            },
          ),
          GoRoute(
            path: RouteNames.quiz,
            name: 'quiz',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Quiz Screen'))),
          ),
          GoRoute(
            path: RouteNames.bookmarks,
            name: 'bookmarks',
            builder: (context, state) => const BookmarksScreen(),
          ),
          GoRoute(
            path: RouteNames.highSchoolNotes,
            name: 'highSchoolNotes',
            builder: (context, state) => const HighSchoolNotesScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // ── DEV ONLY: Animation preview ────────────────────────────
      GoRoute(
        path: RouteNames.animationPreview,
        name: 'animationPreview',
        builder: (context, state) => const AnimationPreviewScreen(),
      ),

      // ── Note detail screen ─────────────────────────────────────
      GoRoute(
        path: RouteNames.noteDetail,
        name: 'noteDetail',
        builder: (context, state) {
          final subject = state.uri.queryParameters['subject'] ?? 'Mathematics';
          final gradeLevel =
              state.uri.queryParameters['gradeLevel'] ?? 'Grade 12';
          return NoteDetailScreen(
            subjectTitle: subject,
            gradeLevel: gradeLevel,
          );
        },
      ),
      // ── Lesson detail (reader) screen ──────────────────────────
      GoRoute(
        path: RouteNames.lessonDetail,
        name: 'lessonDetail',
        builder: (context, state) {
          final subject =
              state.uri.queryParameters['subject'] ?? 'Fractions';
          final gradeLevel =
              state.uri.queryParameters['gradeLevel'] ?? 'Grade 8 Math';
          final chapterTitle =
              state.uri.queryParameters['chapterTitle'] ??
                  'Equivalence and Simplification';
          final chapterNumber =
              state.uri.queryParameters['chapterNumber'] ?? '4.2';
          final chapterId =
              state.uri.queryParameters['chapterId'] ?? '';
          return LessonDetailScreen(
            subject: subject,
            gradeLevel: gradeLevel,
            chapterTitle: chapterTitle,
            chapterNumber: chapterNumber,
            chapterId: chapterId,
          );
        },
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
  /// 4. If the user is authenticated AND has selected their grade level -> [RouteNames.grade12MatricExam] (or [RouteNames.kgHome])
  static Future<String> resolveInitialRoute() async {
    final storage = await SharedPrefsStorage.getInstance();

    // 1. Check if user has completed introductory onboarding slides
    final hasSeenOnboarding =
        await storage.getBool(StorageKeys.hasSeenOnboarding) ?? false;
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
    final user = UserModel.fromJsonString(authUserRaw);
    final hasSelectedGrade =
        (await storage.getBool(StorageKeys.hasSelectedGrade) ?? false) ||
        (user?.onboardingCompleted ?? false);
    if (!hasSelectedGrade) {
      return RouteNames.gradeSelection;
    }

    // 4. User is authenticated and grade is chosen: route to appropriate dashboard / exam screen
    if (user != null && user.isKgStudent) {
      return RouteNames.kgHome;
    }
    return RouteNames.grade12MatricExam;
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

/// Persistent App Shell hosting the unified bottom navigation bar for all Grade module screens.
class MainGradeAppShell extends StatelessWidget {
  final Widget child;
  final String location;

  const MainGradeAppShell({
    super.key,
    required this.child,
    required this.location,
  });

  int _calculateIndex() {
    if (location.startsWith(RouteNames.highSchoolNotes) ||
        location.startsWith(RouteNames.subjectDetail)) {
      return 1;
    }
    if (location.startsWith(RouteNames.quiz)) {
      return 2;
    }
    if (location.startsWith(RouteNames.profile)) {
      return 3;
    }
    // 0 is for exams (examSimulator, grade12MatricExam, subjectExams, bookmarks)
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.examSimulator);
        break;
      case 1:
        context.go(RouteNames.highSchoolNotes);
        break;
      case 2:
        context.push(RouteNames.quiz);
        break;
      case 3:
        context.push(RouteNames.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: GradeBottomNavBar(
        currentIndex: _calculateIndex(),
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}

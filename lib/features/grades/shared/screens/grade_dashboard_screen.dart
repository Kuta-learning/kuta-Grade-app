import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/grade_level.dart';
import '../../../../core/storage/shared_prefs_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../authentication/bloc/auth_bloc.dart';
import '../../grade_12/screens/grade_12_matric_exam_screen.dart';
import '../../grade_8/screens/grade_8_ministry_exam_screen.dart';
import '../../grade_6/screens/grade_6_special_screen.dart';

/// Reusable dashboard / exam screen for national exam takers (Grades 6, 8, and 12).
/// Automatically directs Grade 12 students to the Matriculation Exam Simulator screen
/// designed by team mate Emnet19, Grade 8 to Ministry Exam Prep, and Grade 6 to Primary Modules.
/// Displays an animated welcome SnackBar upon arrival.
class GradeDashboardScreen extends StatefulWidget {
  final GradeLevel? gradeLevel;

  const GradeDashboardScreen({
    super.key,
    this.gradeLevel,
  });

  @override
  State<GradeDashboardScreen> createState() => _GradeDashboardScreenState();
}

class _GradeDashboardScreenState extends State<GradeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showWelcomeSnackbarOnce();
    });
  }

  void _showWelcomeSnackbarOnce() async {
    final storage = SharedPrefsStorage.instanceOrNull;
    if (storage == null) return;
    final alreadySeen =
        await storage.getBool(StorageKeys.hasSeenWelcomeSnackbar) ?? false;
    if (alreadySeen || !mounted) return;

    await storage.setBool(StorageKeys.hasSeenWelcomeSnackbar, value: true);
    if (!mounted) return;

    String name = 'Student';
    String? subtitle;
    try {
      final authBloc =
          context.findAncestorWidgetOfExactType<BlocProvider<AuthBloc>>() !=
                  null
              ? context.read<AuthBloc>()
              : null;
      if (authBloc != null) {
        final freshUser = await authBloc.authService.getCurrentUser();
        if (freshUser?.name != null && freshUser!.name.trim().isNotEmpty) {
          name = freshUser.name.trim();
        }
        final currentGrade =
            freshUser?.gradeLevel ?? widget.gradeLevel ?? GradeLevel.grade12;
        final streamName = freshUser?.academicStream?.displayName;
        subtitle = streamName != null
            ? '${currentGrade.displayName} • $streamName'
            : currentGrade.displayName;
      }
    } catch (_) {}

    if (!mounted) return;
    AppSnackBar.showWelcome(context, name: name, subtitle: subtitle);
  }

  @override
  Widget build(BuildContext context) {
    final hasAuthBloc =
        context.findAncestorWidgetOfExactType<BlocProvider<AuthBloc>>() != null;

    if (!hasAuthBloc) {
      final grade = widget.gradeLevel ?? GradeLevel.grade12;
      return _buildScreenForGrade(grade);
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final grade =
            widget.gradeLevel ?? user?.gradeLevel ?? GradeLevel.grade12;
        return _buildScreenForGrade(grade);
      },
    );
  }

  Widget _buildScreenForGrade(GradeLevel grade) {
    if (grade == GradeLevel.grade12) {
      return const Grade12MatricExamScreen();
    } else if (grade == GradeLevel.grade8) {
      return const Grade8MinistryExamScreen();
    } else if (grade == GradeLevel.grade6) {
      return const Grade6SpecialScreen();
    }

    return const Grade12MatricExamScreen();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/grade_level.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/storage/shared_prefs_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../authentication/bloc/auth_bloc.dart';

/// Comprehensive dashboard screen for Grades 6, 8, and 12 students.
/// Displays student identity, exam simulator progress matching the Kuta backend API,
/// presents an animated welcome SnackBar upon arrival,
/// and includes testing controls (Reset Navigation & Logout) for developer workflow.
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
    final storage = SharedPrefsStorage.instance;
    final alreadySeen =
        await storage.getBool(StorageKeys.hasSeenWelcomeSnackbar) ?? false;
    if (alreadySeen || !mounted) return;

    // Mark as seen immediately so even a quick restart won't replay it
    await storage.setBool(StorageKeys.hasSeenWelcomeSnackbar, value: true);
    if (!mounted) return;

    final authBloc = context.read<AuthBloc>();
    final freshUser = await authBloc.authService.getCurrentUser();
    if (!mounted) return;

    final name = (freshUser?.name != null && freshUser!.name.trim().isNotEmpty)
        ? freshUser.name.trim()
        : 'Student';

    AppSnackBar.showWelcome(context, name: name);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final currentGrade =
            widget.gradeLevel ?? user?.gradeLevel ?? GradeLevel.grade12;
        final streamName = user?.academicStream?.displayName;

        return Scaffold(
          backgroundColor: AppColors.surfaceApp,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceWhite,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.orange500.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.school_rounded,
                      color: AppColors.orange500,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name.isNotEmpty == true
                          ? user!.name
                          : 'Student Portal',
                      style: AppTypography.headlineLg.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      streamName != null
                          ? '${currentGrade.displayName} • $streamName'
                          : currentGrade.displayName,
                      style: AppTypography.captionSm.copyWith(
                        color: AppColors.authBrown,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Log Out',
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.textSecondary),
                onPressed: () => _handleLogout(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==========================================
                // 1. NAVIGATION TESTING & RESET PANEL
                // ==========================================
                _buildTestingControlCard(context),

                const SizedBox(height: 20),

                // ==========================================
                // 2. ACTIVE EXAM SIMULATOR BANNER (API Collection Feed)
                // ==========================================
                _buildExamSimulatorBanner(currentGrade, streamName),

                const SizedBox(height: 20),

                // ==========================================
                // 3. EXAM SUBJECT STATS (GET /national-exams/subjects)
                // ==========================================
                Text(
                  'Preparation Subjects',
                  style: AppTypography.headlineLg.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on your ${currentGrade.displayName} curriculum',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),

                _buildSubjectCards(currentGrade),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Testing Controls Card ──────────────────────────────────────────────────
  Widget _buildTestingControlCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.orange500.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: AppElevation.elevation1,
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restore_page_rounded,
                  color: AppColors.accentDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Navigation Flow Testing',
                  style: AppTypography.labelMdSemiBold.copyWith(
                    fontSize: 15,
                    color: AppColors.accentDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Completed screens (Onboarding, Register, Grade Selection) are stored in SharedPreferences and skipped when reopening the app. Use the button below to erase SharedPreferences and test the flow again from scratch.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Primary Reset Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleResetNavigation(context),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Reset Navigation',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Secondary Logout Button
              OutlinedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout_rounded, size: 16),
                label: const Text('Log Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.authBrown,
                  side: const BorderSide(color: AppColors.borderVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Exam Simulator Banner ──────────────────────────────────────────────────
  Widget _buildExamSimulatorBanner(GradeLevel grade, String? stream) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A), // Slate 900
            Color(0xFF1E293B), // Slate 800
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: AppElevation.elevation2,
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange500.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.orange500.withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      color: AppColors.orange500,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'NATIONAL EXAM PREP',
                      style: TextStyle(
                        color: AppColors.orange500,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.military_tech_rounded,
                color: Color(0xFFFBBF24),
                size: 26,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${grade.displayName} Exam Simulator',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stream != null
                ? 'Standardized Matriculation Tests • $stream Track'
                : 'Interactive Practice Exams & Time Simulator',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: AppColors.orange500,
                  size: 22,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '2025 National Model Exam - Paper 1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Subject Cards ──────────────────────────────────────────────────────────
  Widget _buildSubjectCards(GradeLevel grade) {
    final subjects = grade == GradeLevel.grade12
        ? [
            _SubjectCardItem(
              title: 'Mathematics',
              examsCount: 12,
              accuracy: '84%',
              icon: Icons.calculate_rounded,
              color: const Color(0xFF2563EB),
            ),
            _SubjectCardItem(
              title: 'Physics',
              examsCount: 10,
              accuracy: '76%',
              icon: Icons.science_rounded,
              color: const Color(0xFFEA580C),
            ),
            _SubjectCardItem(
              title: 'Chemistry',
              examsCount: 8,
              accuracy: '81%',
              icon: Icons.biotech_rounded,
              color: const Color(0xFF16A34A),
            ),
            _SubjectCardItem(
              title: 'English',
              examsCount: 14,
              accuracy: '88%',
              icon: Icons.menu_book_rounded,
              color: const Color(0xFF9333EA),
            ),
          ]
        : [
            _SubjectCardItem(
              title: 'Mathematics',
              examsCount: 8,
              accuracy: '82%',
              icon: Icons.calculate_rounded,
              color: const Color(0xFF2563EB),
            ),
            _SubjectCardItem(
              title: 'General Science',
              examsCount: 6,
              accuracy: '79%',
              icon: Icons.science_rounded,
              color: const Color(0xFF16A34A),
            ),
            _SubjectCardItem(
              title: 'Social Studies',
              examsCount: 6,
              accuracy: '85%',
              icon: Icons.public_rounded,
              color: const Color(0xFFEA580C),
            ),
            _SubjectCardItem(
              title: 'English Language',
              examsCount: 9,
              accuracy: '90%',
              icon: Icons.menu_book_rounded,
              color: const Color(0xFF9333EA),
            ),
          ];

    return Column(
      children: subjects.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppColors.borderVariant),
            boxShadow: AppElevation.elevation1,
          ),
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.headlineLg.copyWith(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.examsCount} Practice Exams Available',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.containerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.accuracy,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  void _handleResetNavigation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Navigation Flow?'),
        content: const Text(
          'This will erase all SharedPreferences flags (onboarding completed, authentication session, and grade selection) so you can test the first-time user journey from the beginning.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange500,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              AppSnackBar.showInfo(
                context,
                'Preferences erased! Restarting from Onboarding...',
              );
              await AppRouter.resetNavigationData(context);
            },
            child: const Text('Reset & Restart'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(const LogoutRequested());
    AppSnackBar.showInfo(
      context,
      'Logged out successfully. Returning to registration screen.',
    );
    context.go(RouteNames.register);
  }
}

class _SubjectCardItem {
  final String title;
  final int examsCount;
  final String accuracy;
  final IconData icon;
  final Color color;

  _SubjectCardItem({
    required this.title,
    required this.examsCount,
    required this.accuracy,
    required this.icon,
    required this.color,
  });
}

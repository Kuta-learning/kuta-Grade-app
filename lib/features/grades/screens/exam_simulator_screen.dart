import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/storage/shared_prefs_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/rive_loading_widget.dart';
import '../models/national_exam_dashboard_model.dart';
import '../services/national_exam_service.dart';
import '../widgets/exam_header_skeleton.dart';
import '../widgets/grade_screen_shell.dart';

/// Unified National Exam Simulator Screen for Grades 6, 8, 12 and above.
/// Features live data binding, Rive custom loading animation, top skeleton loading,
/// back-navigation locking (leaving is only possible via explicit logout),
/// and error state with retry.
class ExamSimulatorScreen extends StatefulWidget {
  final NationalExamDashboardModel? initialDashboardData;

  const ExamSimulatorScreen({
    super.key,
    this.initialDashboardData,
  });

  @override
  State<ExamSimulatorScreen> createState() => _ExamSimulatorScreenState();
}

/// Backward compatibility alias for Grade 12 references
typedef Grade12MatricExamScreen = ExamSimulatorScreen;

class _ExamSimulatorScreenState extends State<ExamSimulatorScreen> {
  int _selectedBottomNavIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  NationalExamDashboardModel? _dashboardData;

  static const Color _primaryBlue = AppColors.brandPrimary;
  static const Color _pageBackground = AppColors.surfaceApp;
  static const Color _orangeAccent = AppColors.accentHover;
  static const Color _emeraldGreen = AppColors.success;
  static const Color _textPrimary = AppColors.textPrimary;
  static const Color _textSecondary = AppColors.textSecondary;
  static const Color _cardBorder = AppColors.containerHigh;

  @override
  void initState() {
    super.initState();
    if (widget.initialDashboardData != null) {
      _dashboardData = widget.initialDashboardData;
      _isLoading = false;
    } else {
      _loadDashboardData();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showWelcomeSnackbarOnce();
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = NationalExamService();
      final data = await service.getDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _showWelcomeSnackbarOnce() async {
    final storage = SharedPrefsStorage.instanceOrNull;
    if (storage == null) return;
    final alreadySeen =
        await storage.getBool(StorageKeys.hasSeenWelcomeSnackbar) ?? false;
    if (alreadySeen || !mounted) return;

    await storage.setBool(StorageKeys.hasSeenWelcomeSnackbar, value: true);
    if (!mounted) return;

    final student = _dashboardData?.student;
    final name = student != null && student.name.trim().isNotEmpty
        ? student.name.trim()
        : 'Student';
    final grade = student?.gradeLevel ?? 12;
    final stream = student?.stream == 'SOCIAL' ? 'Social' : 'Natural';
    final subtitle = 'Grade $grade • $stream Science';

    AppSnackBar.showWelcome(context, name: name, subtitle: subtitle);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    // Locked Screen: Prevents popping out to unauthenticated screens.
    // User can only leave via explicit logout (e.g. from Profile screen).
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Intentionally intercept and ignore system back navigation
      },
      child: Scaffold(
        backgroundColor: _pageBackground,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // TOP ROYAL BLUE HEADER SECTION
              // ==========================================
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: topPadding + 195,
                    color: _primaryBlue,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: topPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCustomAppBar(context),
                        const SizedBox(height: 12),
                        if (_isLoading)
                          const ExamHeaderSkeleton()
                        else if (_dashboardData != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildWelcomeBanner(_dashboardData!.student),
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildActiveExamCard(
                              context,
                              _dashboardData!.bannerExam,
                            ),
                          ),
                        ] else ...[
                          // Minimal top fallback when error occurs before data
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // ==========================================
              // BODY SECTION (Rive Loader / Error / Content)
              // ==========================================
              if (_isLoading) ...[
                const SizedBox(height: 36),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: KutaLoadingWidget(
                      size: 160,
                      label: 'Loading Exam Simulator...',
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ] else if (_errorMessage != null && _dashboardData == null) ...[
                _buildErrorState(),
              ] else if (_dashboardData != null) ...[
                _buildSubjectsSection(context, _dashboardData!),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  /// App Bar without back button (locked exam root dashboard)
  Widget _buildCustomAppBar(BuildContext context) {
    return GradeExamAppBar(
      title: 'Exam Simulator',
      showBackButton: false, // Back button removed per team lead requirement
      onBookmarkPressed: () {
        context.push(RouteNames.bookmarks);
      },
      onProfilePressed: () {
        context.push(RouteNames.profile);
      },
    );
  }

  /// Welcome Banner Card inside the blue header
  Widget _buildWelcomeBanner(StudentInfo student) {
    final streamDisplay =
        student.stream.toUpperCase() == 'SOCIAL' ? 'Social' : 'Natural';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${student.name.isNotEmpty ? student.name : "Student"}!',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Grade ${student.gradeLevel} $streamDisplay Science',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  /// Active or Recent Exam Card
  Widget _buildActiveExamCard(BuildContext context, BannerExamInfo? banner) {
    final title = banner != null
        ? '${banner.subjectName} ${banner.title}'
        : 'National Exam Simulator';
    final remainingTime = banner?.formattedRemainingTime ?? 'Ready to start';
    final actionText = banner?.action ?? 'Start Exam';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: _orangeAccent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13.5,
                          color: _emeraldGreen,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            remainingTime,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  banner != null ? 'Q 34/100' : 'Full Paper',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: const LinearProgressIndicator(
              value: 0.34,
              minHeight: 6,
              backgroundColor: Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(_orangeAccent),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  banner?.subjectName != null
                      ? 'Paper 1 • ${banner!.subjectName}'
                      : 'Paper 1 • General Review',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  context.push(RouteNames.quiz);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7.5,
                  ),
                  decoration: BoxDecoration(
                    color: _orangeAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionText,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Error state widget with retry button
  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load Exam Simulator',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Live Exam Subjects Section
  Widget _buildSubjectsSection(
    BuildContext context,
    NationalExamDashboardModel data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Exam Subjects',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '${data.subjects.length} Subjects',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tap a subject to practice real past national exam papers by year.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: _textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: data.subjects.map((subject) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSubjectCard(context, subject),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Individual Live Subject Card
  Widget _buildSubjectCard(
    BuildContext context,
    NationalExamSubjectModel subject,
  ) {
    final progressInt = (subject.progressPercentage * 100).round();
    final progressVal = (subject.progressPercentage > 1.0)
        ? (subject.progressPercentage / 100).clamp(0.0, 1.0)
        : subject.progressPercentage.clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: () {
          final encodedSubject = Uri.encodeComponent(subject.name);
          final encodedSubtitle = Uri.encodeComponent(
            subject.subcategories.isNotEmpty
                ? subject.subcategories
                : 'Official National University Entrance Papers',
          );
          final subjectId = subject.id;
          context.push(
            '${RouteNames.subjectExams}?subjectId=$subjectId&subject=$encodedSubject&subtitle=$encodedSubtitle',
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: subject.iconBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    subject.iconData,
                    color: subject.parsedColor,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subject.subcategories.isNotEmpty
                            ? subject.subcategories
                            : subject.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: _textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progressVal,
                        strokeWidth: 3.5,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          subject.parsedColor,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                      Text(
                        '$progressInt%',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 0.7,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${subject.completedExams}/${subject.totalExams} Exams completed',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF475569),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${subject.totalQuestions} Questions',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                index: 0,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
                label: 'Exams',
                onTap: () => setState(() => _selectedBottomNavIndex = 0),
              ),
              _buildBottomNavItem(
                index: 1,
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book_rounded,
                label: 'Notes',
                onTap: () {
                  setState(() => _selectedBottomNavIndex = 1);
                  context.push(RouteNames.subjectDetail);
                },
              ),
              _buildBottomNavItem(
                index: 2,
                icon: Icons.edit_note_rounded,
                activeIcon: Icons.edit_note_rounded,
                label: 'Practice',
                onTap: () {
                  setState(() => _selectedBottomNavIndex = 2);
                  context.push(RouteNames.quiz);
                },
              ),
              _buildBottomNavItem(
                index: 3,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                onTap: () {
                  setState(() => _selectedBottomNavIndex = 3);
                  context.push(RouteNames.profile);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedBottomNavIndex == index;
    final color = isSelected ? _primaryBlue : const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isSelected ? activeIcon : icon, color: color, size: 23),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

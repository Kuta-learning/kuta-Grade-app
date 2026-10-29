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

/// Grade 12 National University Entrance Exam Preparation & Simulator Screen.
/// Displays live integrated data from the backend with zero hardcoded fallbacks.
class ExamSimulatorScreen extends StatefulWidget {
  final NationalExamDashboardModel? initialDashboardData;
  final bool showBottomNav;

  const ExamSimulatorScreen({
    super.key,
    this.initialDashboardData,
    this.showBottomNav = false,
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

  /// Loads dashboard data from backend service. Supports Pull-Down-to-Refresh.
  Future<void> _loadDashboardData() async {
    if (_dashboardData == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final service = NationalExamService();
      final data = await service.getDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
          _errorMessage = null;
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
    final hasBannerExam = _dashboardData?.bannerExam != null;

    // Locked Screen: Prevents popping out to unauthenticated screens.
    // User can only leave via explicit logout from Profile screen.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Intercept system back navigation
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: _pageBackground,
          body: RefreshIndicator(
            color: _primaryBlue,
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
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
                        height: topPadding +
                            (_isLoading && _dashboardData == null
                                ? 145
                                : hasBannerExam
                                    ? 195
                                    : 125),
                        color: _primaryBlue,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCustomAppBar(context),
                            const SizedBox(height: 12),
                            if (_isLoading && _dashboardData == null) ...[
                              const ExamHeaderSkeleton(),
                              const SizedBox(height: 10),
                            ]
                            else if (_dashboardData != null) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: _buildWelcomeBanner(),
                              ),
                              if (hasBannerExam) ...[
                                const SizedBox(height: 14),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: _buildActiveExamCard(context),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ==========================================
                  // EXAM SUBJECTS SECTION HEADER
                  // ==========================================
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
                              '${_dashboardData?.subjects.length ?? _displaySubjects.length} Subjects',
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

                  // ==========================================
                  // BODY / SUBJECT CARDS / LOADING
                  // ==========================================
                  if (_isLoading && _dashboardData == null) ...[
                    const SizedBox(height: 36),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: KutaLoadingWidget(
                          size: 140,
                          label: 'Loading Exam Simulator...',
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                  ] else if (_errorMessage != null && _dashboardData == null) ...[
                    _buildErrorState(),
                  ] else if (_displaySubjects.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 32,
                      ),
                      child: Center(
                        child: Text(
                          'No exam subjects found for your grade level.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: _displaySubjects.map((subject) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSubjectCard(context, subject),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: widget.showBottomNav
              ? GradeBottomNavBar(
                  currentIndex: _selectedBottomNavIndex,
                  onTap: (index) {
                    setState(() => _selectedBottomNavIndex = index);
                    if (index == 1) {
                      context.push(RouteNames.subjectDetail);
                    } else if (index == 2) {
                      context.push(RouteNames.quiz);
                    } else if (index == 3) {
                      context.push(RouteNames.profile);
                    }
                  },
                )
              : null,
        ),
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
  Widget _buildWelcomeBanner() {
    final student = _dashboardData?.student;
    final name = student != null && student.name.trim().isNotEmpty
        ? student.name.trim()
        : 'Student';
    final gradeLevel = student?.gradeLevel ?? 12;
    final streamDisplay = student != null
        ? (student.stream.toUpperCase() == 'SOCIAL' ? 'Social' : 'Natural')
        : 'Natural';

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
            'Welcome back, $name!',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Grade $gradeLevel $streamDisplay Science',
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

  /// Active Exam Card: displays the live banner exam from backend
  Widget _buildActiveExamCard(BuildContext context) {
    final banner = _dashboardData?.bannerExam;
    if (banner == null) return const SizedBox.shrink();

    final title = banner.subjectName.isNotEmpty
        ? '${banner.subjectName} ${banner.title}'
        : banner.title;
    final remainingTime = banner.formattedRemainingTime;
    final actionText = banner.action;
    final paperSubtitle = banner.subjectName.isNotEmpty
        ? 'Paper 1 • ${banner.subjectName}'
        : 'Paper 1 • National Review';
    final badge = banner.badgeText;
    final progress = banner.progressValue;
    final showProgress = banner.isInProgress && progress > 0;

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
          // Top Row: Icon + Title & Remaining time + Question badge
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
                  badge,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),

          if (showProgress) ...[
            const SizedBox(height: 14),
            // Horizontal Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(_orangeAccent),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Footer Row: Paper Info + Action Button
          Row(
            children: [
              Expanded(
                child: Text(
                  paperSubtitle,
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

  /// Individual Subject Card matching Figma reference exactly
  Widget _buildSubjectCard(BuildContext context, _ExamSubjectItem subject) {
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
          final encodedSubject = Uri.encodeComponent(subject.title);
          final encodedSubtitle = Uri.encodeComponent(
            subject.subtitle.isNotEmpty
                ? subject.subtitle
                : 'Official National University Entrance Papers',
          );
          final subjectIdParam = subject.subjectId != null
              ? '&subjectId=${subject.subjectId}'
              : '';
          context.push(
            '${RouteNames.subjectExams}?subject=$encodedSubject&subtitle=$encodedSubtitle$subjectIdParam',
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Top Row: Icon + Title/Subtitle + Circular Progress
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: subject.iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    subject.icon,
                    color: subject.iconColor,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.title,
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
                        subject.subtitle,
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
                        value: subject.progress,
                        strokeWidth: 3.5,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          subject.progressColor,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                      Text(
                        subject.progressText,
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

            // Bottom Row: Exam history badge + Question count
            Row(
              children: [
                // History Badge with blue clock icon
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            subject.historyText,
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
                // Questions Count with emerald green icon
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.quiz_outlined,
                      size: 14,
                      color: _emeraldGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subject.questionsText,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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

  _ExamSubjectItem _fromBackendSubject(NationalExamSubjectModel model) {
    final pctInt = (model.progressPercentage > 1.0)
        ? model.progressPercentage.round()
        : (model.progressPercentage * 100).round();
    final progressVal = (model.progressPercentage > 1.0)
        ? (model.progressPercentage / 100.0).clamp(0.0, 1.0)
        : model.progressPercentage.clamp(0.0, 1.0);
    final color = model.parsedColor;

    return _ExamSubjectItem(
      subjectId: model.id,
      title: model.name,
      subtitle: model.subcategories.isNotEmpty
          ? model.subcategories
          : (model.stream == 'COMMON'
              ? 'Common Track'
              : '${model.stream} Science Track'),
      progress: progressVal,
      progressText: '$pctInt%',
      progressColor: pctInt >= 50 ? _emeraldGreen : _orangeAccent,
      icon: model.iconData,
      iconBgColor: model.iconBackgroundColor,
      iconColor: color,
      historyText: '${model.totalExams} Exam Papers Available',
      questionsText: '${model.totalQuestions} Questions',
    );
  }

  List<_ExamSubjectItem> get _displaySubjects {
    if (_dashboardData != null) {
      return _dashboardData!.subjects.map(_fromBackendSubject).toList();
    }
    return [];
  }
}

/// Helper model for subject items matching reference design
class _ExamSubjectItem {
  final String? subjectId;
  final String title;
  final String subtitle;
  final double progress;
  final String progressText;
  final Color progressColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String historyText;
  final String questionsText;

  const _ExamSubjectItem({
    this.subjectId,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressText,
    required this.progressColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.historyText,
    required this.questionsText,
  });
}

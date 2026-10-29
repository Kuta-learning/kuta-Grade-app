import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/storage/shared_prefs_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../authentication/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/national_exam_dashboard_model.dart';
import '../services/national_exam_service.dart';
import '../../shared/widgets/grade_screen_shell.dart';

/// Grade 12 National University Entrance Exam Preparation & Simulator Screen.
/// Matches the reference design with high visual accuracy.
class Grade12MatricExamScreen extends StatefulWidget {
  const Grade12MatricExamScreen({super.key});

  @override
  State<Grade12MatricExamScreen> createState() => _Grade12MatricExamScreenState();
}

/// Alias for Grade12MatricExamScreen
typedef ExamSimulatorScreen = Grade12MatricExamScreen;

class _Grade12MatricExamScreenState extends State<Grade12MatricExamScreen> {
  int _selectedBottomNavIndex = 0;
  NationalExamDashboardModel? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showWelcomeSnackbarOnce();
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      final service = NationalExamService();
      final data = await service.getDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = data;
        });
      }
    } catch (_) {
      // Gracefully fall back to reference design items
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

    String name = 'Student';
    String? subtitle = 'Grade 12 • Natural Science';
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
        final streamName = freshUser?.academicStream?.displayName;
        if (streamName != null) {
          subtitle = 'Grade 12 • $streamName';
        }
      }
    } catch (_) {}

    if (!mounted) return;
    AppSnackBar.showWelcome(context, name: name, subtitle: subtitle);
  }

  static const Color _primaryBlue = AppColors.brandPrimary;
  static const Color _pageBackground = AppColors.surfaceApp;
  static const Color _orangeAccent = AppColors.accentHover;
  static const Color _emeraldGreen = AppColors.success;
  static const Color _textPrimary = AppColors.textPrimary;
  static const Color _textSecondary = AppColors.textSecondary;
  static const Color _cardBorder = AppColors.containerHigh;

  final List<_ExamSubjectItem> _subjects = const [
    _ExamSubjectItem(
      title: 'Mathematics',
      subtitle: 'Natural Science Track',
      progress: 0.45,
      progressText: '45%',
      progressColor: _orangeAccent,
      icon: Icons.calculate_outlined,
      iconBgColor: Color(0xFFE0EDFD),
      iconColor: Color(0xFF2563EB),
      historyText: '2014 - 2023 Exams (10 Years)',
      questionsText: '850 Questions',
    ),
    _ExamSubjectItem(
      title: 'Physics',
      subtitle: 'Mechanics, Waves & Modern',
      progress: 0.30,
      progressText: '30%',
      progressColor: _orangeAccent,
      icon: Icons.bolt_rounded,
      iconBgColor: Color(0xFFFFEDD5),
      iconColor: _orangeAccent,
      historyText: '2015 - 2023 Exams (9 Years)',
      questionsText: '720 Questions',
    ),
    _ExamSubjectItem(
      title: 'Chemistry',
      subtitle: 'Organic, Inorganic & Physical',
      progress: 0.20,
      progressText: '20%',
      progressColor: _orangeAccent,
      icon: Icons.science_outlined,
      iconBgColor: Color(0xFFEEF2FF),
      iconColor: Color(0xFF4F46E5),
      historyText: '2014 - 2023 Exams (10 Years)',
      questionsText: '800 Questions',
    ),
    _ExamSubjectItem(
      title: 'Biology',
      subtitle: 'Genetics, Ecology & Human Bio',
      progress: 0.60,
      progressText: '60%',
      progressColor: _emeraldGreen,
      icon: Icons.psychology_outlined,
      iconBgColor: Color(0xFFDCFCE7),
      iconColor: Color(0xFF16A34A),
      historyText: '2014 - 2023 Exams (10 Years)',
      questionsText: '780 Questions',
    ),
    _ExamSubjectItem(
      title: 'English',
      subtitle: 'Grammar, Reading & Vocab',
      progress: 0.75,
      progressText: '75%',
      progressColor: _emeraldGreen,
      icon: Icons.translate_rounded,
      iconBgColor: Color(0xFFFFEDD5),
      iconColor: _orangeAccent,
      historyText: '2012 - 2023 Exams (12 Years)',
      questionsText: '1,200 Questions',
    ),
    _ExamSubjectItem(
      title: 'Civics & Ethical Education',
      subtitle: 'Constitution, Ethics & Society',
      progress: 0.50,
      progressText: '50%',
      progressColor: _orangeAccent,
      icon: Icons.balance_rounded,
      iconBgColor: Color(0xFFE0EDFD),
      iconColor: Color(0xFF2563EB),
      historyText: '2016 - 2023 Exams (8 Years)',
      questionsText: '640 Questions',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _pageBackground,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Section with Royal Blue Background
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Blue container extending behind AppBar, Welcome banner and upper part of active exam card
                  Container(
                    width: double.infinity,
                    height: topPadding + 195,
                    color: _primaryBlue,
                  ),
                  // Content: Header + Welcome Banner + Active Exam Card
                  Padding(
                    padding: EdgeInsets.only(top: topPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCustomAppBar(context),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildWelcomeBanner(),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildActiveExamCard(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Exam Subjects Section Header
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
                          '${_dashboardData?.subjectsCount ?? _subjects.length} Subjects',
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

              // Subject Cards List
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

              const SizedBox(height: 24),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  /// App Bar matching the screenshot
  Widget _buildCustomAppBar(BuildContext context) {
    return GradeExamAppBar(
      title: 'Exam Simulator',
      onBackPressed: () {
        context.go('${RouteNames.gradeSelection}?step=2');
      },
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
            _dashboardData != null && _dashboardData!.student.name.isNotEmpty
                ? 'Welcome back, ${_dashboardData!.student.name}!'
                : 'Welcome back, Ruth!',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _dashboardData != null
                ? 'Grade ${_dashboardData!.student.gradeLevel} ${_dashboardData!.student.stream == 'SOCIAL' ? 'Social' : 'Natural'} Science'
                : 'Grade 12 Natural Science',
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

  /// Active Exam Card
  Widget _buildActiveExamCard(BuildContext context) {
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
              // Light orange rounded square with lightning icon
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
              // Exam Title and Remaining Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dashboardData?.bannerExam != null
                          ? '${_dashboardData!.bannerExam!.subjectName} ${_dashboardData!.bannerExam!.title}'
                          : 'Physics 2022 National Exam',
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
                            _dashboardData?.bannerExam != null
                                ? _dashboardData!.bannerExam!.formattedRemainingTime
                                : '42 mins remaining',
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
              // Question Progress Badge: Q 34/100
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Q 34/100',
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

          // Horizontal Progress Bar (34%)
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

          // Footer Row: Paper Info + Resume Exam Button
          Row(
            children: [
              Expanded(
                child: Text(
                  'Paper 1 • General Physics',
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
                        _dashboardData?.bannerExam?.action ?? 'Resume Exam',
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

  /// Individual Subject Card
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
          final encodedSubtitle = Uri.encodeComponent('Official National University Entrance Papers');
          context.push(
            '${RouteNames.subjectExams}?subject=$encodedSubject&subtitle=$encodedSubtitle',
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Top Row: Icon + Title/Subtitle + Circular Progress
            Row(
              children: [
                // Rounded-square subject icon
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
                // Title and Subtitle
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
                // Circular Progress Indicator with percentage text
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
                // History Badge
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
                // Questions Count
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

  /// Bottom Navigation Bar reusing the shared GradeBottomNavBar component
  Widget _buildBottomNav(BuildContext context) {
    return GradeBottomNavBar(
      currentIndex: _selectedBottomNavIndex,
      onTap: (index) {
        if (index == 1) {
          context.go(RouteNames.highSchoolNotes);
        } else if (index == 3) {
          context.push(RouteNames.profile);
        } else {
          setState(() {
            _selectedBottomNavIndex = index;
          });
        }
      },
    );
  }
  _ExamSubjectItem _fromBackendSubject(NationalExamSubjectModel model) {
    final pctInt = model.progressPercentage.round();
    final progressVal = (model.progressPercentage / 100.0).clamp(0.0, 1.0);
    final color = model.parsedColor;

    return _ExamSubjectItem(
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
    if (_dashboardData != null && _dashboardData!.subjects.isNotEmpty) {
      return _dashboardData!.subjects.map(_fromBackendSubject).toList();
    }
    return _subjects;
  }
}

/// Helper model for subject items
class _ExamSubjectItem {
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


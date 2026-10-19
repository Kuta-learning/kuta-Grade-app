import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';

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

  static const Color _primaryBlue = Color(0xFF1B5EB8);
  static const Color _pageBackground = Color(0xFFF4F6F9);
  static const Color _orangeAccent = Color(0xFFEA580C);
  static const Color _emeraldGreen = Color(0xFF10B981);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFF1F5F9);

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
                          '6 Subjects',
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
                  children: _subjects.map((subject) {
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
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            splashRadius: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          Expanded(
            child: Text(
              'Exam Simulator',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.bookmark_border_rounded,
              color: Colors.white,
              size: 23,
            ),
            splashRadius: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bookmarks updated'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () {
              context.push(RouteNames.profile);
            },
            borderRadius: BorderRadius.circular(17),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFB45309), // Warm terracotta/brown avatar
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
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
            'Welcome back, Ruth!',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Grade 12 Natural Science',
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
                      'Physics 2022 National Exam',
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
                            '42 mins remaining',
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
                        'Resume Exam',
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
          final encodedSubtitle = Uri.encodeComponent(subject.subtitle);
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

  /// Bottom Navigation Bar with 4 items matching reference
  Widget _buildBottomNav(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      padding: EdgeInsets.only(
        top: 6,
        bottom: bottomInset > 0 ? bottomInset : 6,
      ),
      child: Row(
        children: [
          _buildBottomNavItem(
            index: 0,
            label: 'Exams',
            icon: Icons.assignment_outlined,
            onTap: () {
              setState(() {
                _selectedBottomNavIndex = 0;
              });
            },
          ),
          _buildBottomNavItem(
            index: 1,
            label: 'Notes',
            icon: Icons.article_outlined,
            onTap: () {
              setState(() {
                _selectedBottomNavIndex = 1;
              });
            },
          ),
          _buildBottomNavItem(
            index: 2,
            label: 'Practice',
            icon: Icons.edit_note_rounded,
            onTap: () {
              setState(() {
                _selectedBottomNavIndex = 2;
              });
            },
          ),
          _buildBottomNavItem(
            index: 3,
            label: 'Profile',
            icon: Icons.person_outline_rounded,
            onTap: () {
              setState(() {
                _selectedBottomNavIndex = 3;
              });
              context.push(RouteNames.profile);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedBottomNavIndex == index;
    final color = isSelected ? _orangeAccent : _textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w500,
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


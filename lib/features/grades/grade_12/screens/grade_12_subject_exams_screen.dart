import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';

/// Exam status enum indicating student progress for a national exam paper.
enum ExamPaperStatus { notStarted, inProgress, completed }

/// Grade 12 Subject National Entrance Exam Papers Screen (e.g. Mathematics).
/// Displays past official national exam papers with exact visual styling from reference.
class Grade12SubjectExamsScreen extends StatelessWidget {
  final String subjectTitle;
  final String streamTitle;
  final String subtitle;

  const Grade12SubjectExamsScreen({
    super.key,
    this.subjectTitle = 'Mathematics',
    this.streamTitle = 'NATURAL SCIENCE STREAM',
    this.subtitle = 'Official National University Entrance Papers',
  });

  static const Color _primaryBlue = Color(0xFF1B5EB8);
  static const Color _pageBackground = Color(0xFFF4F6F9);
  static const Color _orangeAccent = Color(0xFFEA580C);
  static const Color _resumeBlue = Color(0xFF2563EB);
  static const Color _completedGreen = Color(0xFF10B981);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFF1F5F9);
  static const Color _reviewBtnBg = Color(0xFFE2E8F0);
  static const Color _reviewBtnText = Color(0xFF2563EB);

  static const List<_ExamPaperModel> _papers = [
    _ExamPaperModel(
      year: '2023',
      displayTitle: '2023 National\nExam',
      duration: '2h 30m',
      questionsCount: '100 Qs',
      status: ExamPaperStatus.notStarted,
    ),
    _ExamPaperModel(
      year: '2022',
      displayTitle: '2022\nNational\nExam',
      duration: '2h 30m',
      questionsCount: '100 Qs',
      status: ExamPaperStatus.inProgress,
      timeLeft: '1:42m left',
    ),
    _ExamPaperModel(
      year: '2021',
      displayTitle: '2021 National\nExam',
      duration: '2h 10m',
      questionsCount: '100 Qs',
      status: ExamPaperStatus.completed,
      score: 'Score: 88/100',
    ),
    _ExamPaperModel(
      year: '2020',
      displayTitle: '2020\nNational\nExam',
      duration: '2h 30m',
      questionsCount: '100 Qs',
      status: ExamPaperStatus.notStarted,
    ),
    _ExamPaperModel(
      year: '2019',
      displayTitle: '2019\nNational\nExam',
      duration: '2h 30m',
      questionsCount: '100 Qs',
      status: ExamPaperStatus.notStarted,
    ),
    _ExamPaperModel(
      year: '2018',
      displayTitle: '2018\nNational\nExam',
      duration: '2h 30m',
      questionsCount: '100 Qs',
      status: ExamPaperStatus.notStarted,
    ),
    _ExamPaperModel(
      year: '2017',
      displayTitle: '2017\nNational\nExam',
      duration: '2h 30m',
      questionsCount: '100 Qs',
      status: ExamPaperStatus.notStarted,
    ),
    _ExamPaperModel(
      year: '2016',
      displayTitle: '2016\nNational\nExam',
      duration: '2h 30m',
      questionsCount: '100 Qs',
      status: ExamPaperStatus.notStarted,
    ),
    _ExamPaperModel(
      year: '2015',
      displayTitle: '2015\nNational\nExam',
      duration: '2h 30m',
      questionsCount: '100 Qs',
      status: ExamPaperStatus.notStarted,
    ),
    _ExamPaperModel(
      year: '2014',
      displayTitle: '2014\nNational\nExam',
      duration: '2h 30m',
      questionsCount: '100 Qs',
      status: ExamPaperStatus.notStarted,
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
        body: Column(
          children: [
            // Blue Header section
            Container(
              color: _primaryBlue,
              padding: EdgeInsets.only(
                top: topPadding,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCustomAppBar(context),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSubheader(),
                  ),
                ],
              ),
            ),

            // Scrollable List of Exam Papers
            Expanded(
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: _papers.length,
                itemBuilder: (context, index) {
                  final paper = _papers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildExamCard(context, paper),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// App Bar matching the reference design
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subjectTitle,
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
                  content: Text('Subject bookmarked'),
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
                color: Color(0xFFB45309), // Terracotta brown avatar
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

  /// Subheader inside the blue section
  Widget _buildSubheader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.school_outlined,
              size: 15,
              color: Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              streamTitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.95),
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  /// Individual Exam Year Card
  Widget _buildExamCard(BuildContext context, _ExamPaperModel paper) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Title and Meta details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  paper.displayTitle,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPaperMeta(paper),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right side: Action Button
          _buildActionButton(context, paper),
        ],
      ),
    );
  }

  /// Meta details row (Clock / Check + timing / score)
  Widget _buildPaperMeta(_ExamPaperModel paper) {
    switch (paper.status) {
      case ExamPaperStatus.notStarted:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 14,
              color: Color(0xFF2563EB),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${paper.duration} • ${paper.questionsCount}',
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
        );

      case ExamPaperStatus.inProgress:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 14,
              color: Color(0xFF2563EB),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${paper.duration} • ${paper.questionsCount} • ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary,
                      ),
                    ),
                    TextSpan(
                      text: '${paper.timeLeft ?? ''} In Progress',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _resumeBlue,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );

      case ExamPaperStatus.completed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 14,
              color: _completedGreen,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${paper.score ?? ''} • ${paper.duration} ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary,
                      ),
                    ),
                    TextSpan(
                      text: 'Completed',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _completedGreen,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
    }
  }

  /// Right action button based on exam paper status
  Widget _buildActionButton(BuildContext context, _ExamPaperModel paper) {
    switch (paper.status) {
      case ExamPaperStatus.notStarted:
        return InkWell(
          onTap: () {
            context.push(RouteNames.quiz);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9.5),
            decoration: BoxDecoration(
              color: _orangeAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Start Exam',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        );

      case ExamPaperStatus.inProgress:
        return InkWell(
          onTap: () {
            context.push(RouteNames.quiz);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9.5),
            decoration: BoxDecoration(
              color: _resumeBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Resume',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        );

      case ExamPaperStatus.completed:
        return InkWell(
          onTap: () {
            context.push(RouteNames.quiz);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9.5),
            decoration: BoxDecoration(
              color: _reviewBtnBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Review',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _reviewBtnText,
              ),
            ),
          ),
        );
    }
  }
}

/// Model representation for an exam paper year
class _ExamPaperModel {
  final String year;
  final String displayTitle;
  final String duration;
  final String questionsCount;
  final ExamPaperStatus status;
  final String? timeLeft;
  final String? score;

  const _ExamPaperModel({
    required this.year,
    required this.displayTitle,
    required this.duration,
    required this.questionsCount,
    required this.status,
    this.timeLeft,
    this.score,
  });
}


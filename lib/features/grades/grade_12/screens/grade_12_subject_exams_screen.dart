import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../shared/widgets/grade_screen_shell.dart';

/// Exam status enum indicating student progress for a national exam paper.
enum ExamPaperStatus { notStarted, inProgress, completed }

/// Grade 12 Subject National Entrance Exam Papers Screen (e.g. Mathematics).
/// Displays past official national exam papers matching the Figma reference design.
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
  ];

  @override
  Widget build(BuildContext context) {
    // Normalize subtitle to the official entrance papers banner matching the reference design
    final effectiveSubtitle =
        (subtitle.isEmpty || subtitle == 'Natural Science Track')
            ? 'Official National University Entrance Papers'
            : subtitle;

    return GradeScreenShell(
      title: subjectTitle,
      streamTitle: streamTitle,
      subtitle: effectiveSubtitle,
      onBackPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RouteNames.grade12MatricExam);
        }
      },
      showBottomNav: true,
      selectedNavIndex: 0,
      body: ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _papers.length,
        itemBuilder: (context, index) {
          final paper = _papers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildExamCard(context, paper),
          );
        },
      ),
    );
  }

  /// Individual Exam Year Card matching Figma reference
  Widget _buildExamCard(BuildContext context, _ExamPaperModel paper) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.containerHigh, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.22,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1.5),
              child: Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.brandBlue,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${paper.duration} • ${paper.questionsCount}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.25,
                ),
              ),
            ),
          ],
        );

      case ExamPaperStatus.inProgress:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1.5),
              child: Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.brandBlue,
              ),
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
                        color: AppColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                    TextSpan(
                      text: '${paper.timeLeft ?? ''} In Progress',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brandBlue,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case ExamPaperStatus.completed:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1.5),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 14,
                color: AppColors.success,
              ),
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
                        color: AppColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                    TextSpan(
                      text: 'Completed',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.orange500,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Start Exam',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.brandBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Resume',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.borderVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Review',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.brandBlue,
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

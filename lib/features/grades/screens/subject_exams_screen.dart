import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/rive_loading_widget.dart';
import '../models/national_exam_models.dart';
import '../services/national_exam_service.dart';
import '../widgets/grade_screen_shell.dart';

/// Exam status enum indicating student progress for a national exam paper.
enum ExamPaperStatus { notStarted, inProgress, completed }

/// Unified Subject Exam Papers Screen for all Grades (6, 8, 12).
/// Displays past official national exam papers matching the exact Figma reference design.
class SubjectExamsScreen extends StatefulWidget {
  final String? subjectId;
  final String subjectTitle;
  final String streamTitle;
  final String subtitle;

  const SubjectExamsScreen({
    super.key,
    this.subjectId,
    this.subjectTitle = 'Mathematics',
    this.streamTitle = 'NATURAL SCIENCE STREAM',
    this.subtitle = 'Official National University Entrance Papers',
  });

  @override
  State<SubjectExamsScreen> createState() => _SubjectExamsScreenState();
}

/// Backward compatibility alias for Grade 12 references
typedef Grade12SubjectExamsScreen = SubjectExamsScreen;

class _SubjectExamsScreenState extends State<SubjectExamsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<_ExamPaperModel> _papers = [];

  @override
  void initState() {
    super.initState();
    _fetchPapers();
  }

  /// Loads exam papers from backend. Supports pull-to-refresh.
  Future<void> _fetchPapers() async {
    if (widget.subjectId == null || widget.subjectId!.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No subject ID provided. Please go back and try again.';
      });
      return;
    }

    // Only show full loading state on initial load (not on refresh)
    if (_papers.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final service = NationalExamService();
      final list = await service.getExamsForSubject(widget.subjectId!);
      if (mounted) {
        setState(() {
          _papers = list.map(_fromBackendPaper).toList();
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

  _ExamPaperModel _fromBackendPaper(ExamPaperItem paper) {
    final hours = paper.durationMinutes ~/ 60;
    final minutes = paper.durationMinutes % 60;
    final durationStr =
        minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';

    ExamPaperStatus status;
    switch (paper.userStatus) {
      case ExamUserStatus.notStarted:
        status = ExamPaperStatus.notStarted;
        break;
      case ExamUserStatus.inProgress:
        status = ExamPaperStatus.inProgress;
        break;
      case ExamUserStatus.submitted:
        status = ExamPaperStatus.completed;
        break;
    }

    final isFourDigits = paper.year > 0;
    final displayTitle = isFourDigits
        ? '${paper.year} National Exam'
        : '${paper.title} National Exam';

    return _ExamPaperModel(
      id: paper.id,
      year: paper.year.toString(),
      displayTitle: displayTitle,
      duration: durationStr,
      questionsCount: '${paper.totalQuestions} Qs',
      status: status,
      timeLeft: status == ExamPaperStatus.inProgress ? '1:42m left' : null,
      score: paper.latestScore != null
          ? 'Score: ${paper.latestScore}/${paper.totalQuestions}'
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSubtitle =
        (widget.subtitle.isEmpty || widget.subtitle == 'Natural Science Track')
            ? 'Official National University Entrance Papers'
            : widget.subtitle;

    return GradeScreenShell(
      title: widget.subjectTitle,
      streamTitle: widget.streamTitle,
      subtitle: effectiveSubtitle,
      onBackPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RouteNames.examSimulator);
        }
      },
      showBottomNav: false,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Initial loading state with custom Rive animation
    if (_isLoading && _papers.isEmpty) {
      return const Center(
        child: KutaLoadingWidget(
          size: 140,
          label: 'Loading Exam Papers...',
        ),
      );
    }

    // Error state with retry
    if (_errorMessage != null && _papers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
                'Failed to load exam papers',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage ?? 'Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchPapers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
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

    // Empty state
    if (_papers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No exam papers found for this subject.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Papers list with pull-to-refresh
    return RefreshIndicator(
      color: AppColors.brandPrimary,
      onRefresh: _fetchPapers,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
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
            context.push(
              '${RouteNames.quiz}'
              '?quizId=${Uri.encodeComponent(paper.id.isNotEmpty ? paper.id : "exam-${paper.year}")}'
              '&title=${Uri.encodeComponent("${paper.year} ${widget.subjectTitle} National Exam")}',
            );
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
            context.push(
              '${RouteNames.quiz}'
              '?quizId=${Uri.encodeComponent(paper.id.isNotEmpty ? paper.id : "exam-${paper.year}")}'
              '&title=${Uri.encodeComponent("${paper.year} ${widget.subjectTitle} National Exam")}',
            );
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
            context.push(
              '${RouteNames.quiz}'
              '?quizId=${Uri.encodeComponent(paper.id.isNotEmpty ? paper.id : "exam-${paper.year}")}'
              '&title=${Uri.encodeComponent("${paper.year} ${widget.subjectTitle} National Exam")}',
            );
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
  final String id;
  final String year;
  final String displayTitle;
  final String duration;
  final String questionsCount;
  final ExamPaperStatus status;
  final String? timeLeft;
  final String? score;

  const _ExamPaperModel({
    required this.id,
    required this.year,
    required this.displayTitle,
    required this.duration,
    required this.questionsCount,
    required this.status,
    this.timeLeft,
    this.score,
  });
}

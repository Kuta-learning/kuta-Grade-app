import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/rive_loading_widget.dart';
import '../models/national_exam_models.dart';
import '../services/national_exam_service.dart';
import '../widgets/grade_screen_shell.dart';

/// Unified Subject Exam Papers Screen for all Grades (6, 8, 12).
/// Displays past official national exam papers with status, duration, and score.
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
    this.subtitle = 'Official National Entrance Papers',
  });

  @override
  State<SubjectExamsScreen> createState() => _SubjectExamsScreenState();
}

/// Backward compatibility alias for Grade 12 references
typedef Grade12SubjectExamsScreen = SubjectExamsScreen;

class _SubjectExamsScreenState extends State<SubjectExamsScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<ExamPaperItem> _papers = [];

  @override
  void initState() {
    super.initState();
    _fetchPapers();
  }

  Future<void> _fetchPapers() async {
    if (widget.subjectId == null || widget.subjectId!.isEmpty) {
      _initFallbackPapers();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = NationalExamService();
      final list = await service.getExamsForSubject(widget.subjectId!);
      if (mounted) {
        setState(() {
          _papers = list;
          _isLoading = false;
        });
        if (_papers.isEmpty) {
          _initFallbackPapers();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
        if (_papers.isEmpty) {
          _initFallbackPapers();
        }
      }
    }
  }

  void _initFallbackPapers() {
    _papers = const [
      ExamPaperItem(
        id: '2023',
        title: '2023 National Exam',
        year: 2023,
        durationMinutes: 150,
        totalQuestions: 100,
        userStatus: ExamUserStatus.notStarted,
      ),
      ExamPaperItem(
        id: '2022',
        title: '2022 National Exam',
        year: 2022,
        durationMinutes: 150,
        totalQuestions: 100,
        userStatus: ExamUserStatus.inProgress,
      ),
      ExamPaperItem(
        id: '2021',
        title: '2021 National Exam',
        year: 2021,
        durationMinutes: 130,
        totalQuestions: 100,
        userStatus: ExamUserStatus.submitted,
        latestScore: 88,
      ),
      ExamPaperItem(
        id: '2020',
        title: '2020 National Exam',
        year: 2020,
        durationMinutes: 150,
        totalQuestions: 100,
        userStatus: ExamUserStatus.notStarted,
      ),
      ExamPaperItem(
        id: '2019',
        title: '2019 National Exam',
        year: 2019,
        durationMinutes: 150,
        totalQuestions: 100,
        userStatus: ExamUserStatus.notStarted,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSubtitle =
        (widget.subtitle.isEmpty || widget.subtitle == 'Natural Science Track')
            ? 'Official National Entrance Papers'
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
      showBottomNav: true,
      selectedNavIndex: 0,
      body: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: KutaLoadingWidget(
                  size: 140,
                  label: 'Loading Exam Papers...',
                ),
              ),
            )
          : ListView.builder(
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

  Widget _buildExamCard(BuildContext context, ExamPaperItem paper) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${paper.year}\nNational\nExam',
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
          _buildActionButton(context, paper),
        ],
      ),
    );
  }

  Widget _buildPaperMeta(ExamPaperItem paper) {
    final hours = paper.durationMinutes ~/ 60;
    final minutes = paper.durationMinutes % 60;
    final durationStr = minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';

    switch (paper.userStatus) {
      case ExamUserStatus.notStarted:
        return Row(
          children: [
            const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              durationStr,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 10),
            Text(
              '${paper.totalQuestions} Qs',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        );
      case ExamUserStatus.inProgress:
        return Row(
          children: [
            const Icon(Icons.history_rounded, size: 14, color: AppColors.brandPrimary),
            const SizedBox(width: 4),
            Text(
              'In Progress',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.brandPrimary,
              ),
            ),
          ],
        );
      case ExamUserStatus.submitted:
        return Row(
          children: [
            const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
            const SizedBox(width: 4),
            Text(
              paper.latestScore != null ? 'Score: ${paper.latestScore}/${paper.totalQuestions}' : 'Completed',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildActionButton(BuildContext context, ExamPaperItem paper) {
    final isSubmitted = paper.userStatus == ExamUserStatus.submitted;
    final isInProgress = paper.userStatus == ExamUserStatus.inProgress;

    final bgColor = isSubmitted
        ? const Color(0xFFF1F5F9)
        : (isInProgress ? AppColors.accentHover : AppColors.brandPrimary);
    final textColor = isSubmitted ? AppColors.textPrimary : Colors.white;
    final label = isSubmitted
        ? 'Review'
        : (isInProgress ? 'Resume' : 'Start Exam');

    return ElevatedButton(
      onPressed: () {
        context.push(RouteNames.quiz);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

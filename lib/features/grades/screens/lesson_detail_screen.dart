import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../bloc/grades_bloc.dart';
import '../models/note_models.dart';

import '../widgets/learning_objectives_card.dart';
import '../widgets/lesson_resource_card.dart';
import '../widgets/lesson_step_card.dart';
import '../widgets/notes_loading_skeleton.dart';

/// Lesson Detail screen — displays interactive lesson content (objectives, body text,
/// visual diagrams, steps, resources, and reading progress) for a selected chapter.
class LessonDetailScreen extends StatefulWidget {
  final String chapterTitle;
  final String chapterNumber;
  final String subject;
  final String gradeLevel;
  final String chapterId;

  const LessonDetailScreen({
    super.key,
    this.chapterTitle = 'Equivalence and Simplification',
    this.chapterNumber = '4.2',
    this.subject = 'Fractions',
    this.gradeLevel = 'Grade 8 Math',
    this.chapterId = 'chap-4-2',
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  LessonDetail? _lesson;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final bloc = context.read<NotesBloc>();
        final cached = bloc.getCachedLesson(widget.chapterId);
        if (cached != null) {
          setState(() => _lesson = cached);
        } else {
          bloc.add(LoadChapterLessonDetail(widget.chapterId));
        }
        // Send reading progress to backend: POST /short-notes/chapters/:chapterId/progress {"isRead": true}
        bloc.add(UpdateChapterProgressEvent(widget.chapterId, isRead: true));
      } catch (_) {
        // BlocProvider unavailable — error shown via NotesError state
      }
    });
  }

  void _onDownloadResource(LessonResource res) {
    AppSnackBar.showSuccess(
      context,
      'Downloading ${res.title} (${res.fileSize})...',
    );
    try {
      context.read<NotesBloc>().add(DownloadChapterPdfEvent(widget.chapterId));
    } catch (_) {}
  }

  void _retry() {
    try {
      context.read<NotesBloc>().add(LoadChapterLessonDetail(widget.chapterId));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    NotesBloc? bloc;
    try {
      bloc = context.read<NotesBloc>();
    } catch (_) {
      bloc = null;
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          color: AppColors.brandBlue,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Back',
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.noteDetail);
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.subject,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Notifications',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: bloc != null
            ? BlocConsumer<NotesBloc, NotesState>(
                listener: (context, state) {
                  if (state is LessonDetailLoaded) {
                    setState(() => _lesson = state.lesson);
                  }
                },
                builder: (context, state) {
                  final lesson = (state is LessonDetailLoaded)
                      ? state.lesson
                      : (_lesson ?? bloc?.getCachedLesson(widget.chapterId));

                  if (lesson != null) {
                    return _buildContent(lesson);
                  }
                  if (state is NotesError) {
                    return _buildErrorState(state.message);
                  }
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: NotesLoadingSkeleton(itemCount: 3),
                  );
                },
              )
            : (_lesson != null
                  ? _buildContent(_lesson!)
                  : const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: NotesLoadingSkeleton(itemCount: 3),
                    )),
      ),
    );
  }

  String _formatContent(String raw) {
    var text = raw.replaceAll('\r\n', '\n');
    text = text.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');
    text = text.replaceAll('**', '');
    text = text.replaceAllMapped(
      RegExp(r'\$([^$]+)\$'),
      (match) => match.group(1) ?? '',
    );
    return text.trim();
  }

  Widget _buildContent(LessonDetail lesson) {
    final content = _formatContent(lesson.bodyText);
    final heading = lesson.sectionHeading.isNotEmpty
        ? lesson.sectionHeading
        : 'Chapter Content';
    final progress = lesson.progressPercent.clamp(0.0, 1.0).toDouble();
    final resourceCount = lesson.resources.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChapterHeaderCard(lesson: lesson),

        if (content.isEmpty && lesson.diagrams.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.borderVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Text(
                'No note content is available for this chapter yet.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        if (lesson.learningObjectives.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
            child: LearningObjectivesCard(
              objectives: lesson.learningObjectives,
            ),
          ),

        if (content.isNotEmpty || lesson.diagrams.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeading(text: heading),
                if (content.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    content,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
                if (lesson.diagrams.isNotEmpty) const SizedBox(height: 16),
                for (final diagram in lesson.diagrams) ...[
                  _DiagramCard(diagram: diagram),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (lesson.steps.isNotEmpty) ...[
                Text(
                  'Steps to Simplify',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E5B94),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: const Color(0xFFFFD8C2).withValues(alpha: 0.8),
                ),
                const SizedBox(height: 16),
                for (final step in lesson.steps) ...[
                  LessonStepCard(step: step),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 20),
              ],

              if (resourceCount > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Lesson Resources',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.headlineDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '$resourceCount ${resourceCount == 1 ? 'File' : 'Files'}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orange900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (final res in lesson.resources) ...[
                  LessonResourceCard(
                    resource: res,
                    onDownload: () => _onDownloadResource(res),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 24),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lesson Progress',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}% Read',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orange900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  color: const Color(0xFFE2E8F0),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(color: const Color(0xFF00C853)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    final cleanMessage = message.replaceFirst('Exception: ', '');
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderVariant.withValues(alpha: 0.6),
          ),
          boxShadow: AppElevation.cardLow,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load this chapter',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.headlineDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              cleanMessage,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange500,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header card showing the chapter title, number, subject and grade from the API.
class _ChapterHeaderCard extends StatelessWidget {
  final LessonDetail lesson;

  const _ChapterHeaderCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderVariant, width: 1),
        boxShadow: AppElevation.cardLow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 120,
              height: 100,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.2,
                  colors: [Color(0x33FFB68D), Color(0x00FFB68D)],
                ),
              ),
            ),
          ),
          const Positioned(
            right: 16,
            top: 18,
            child: Icon(
              Icons.menu_book_rounded,
              size: 42,
              color: Color(0xFFFDE8DE),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lesson.chapterNumber.isNotEmpty ||
                    lesson.gradeLevel.isNotEmpty)
                  Row(
                    children: [
                      if (lesson.chapterNumber.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEDE4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Chapter ${lesson.chapterNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.orange900,
                            ),
                          ),
                        ),
                      if (lesson.chapterNumber.isNotEmpty &&
                          lesson.gradeLevel.isNotEmpty)
                        const SizedBox(width: 8),
                      if (lesson.gradeLevel.isNotEmpty)
                        Text(
                          lesson.gradeLevel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                Text(
                  lesson.chapterTitle,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.headlineDark,
                    letterSpacing: -0.3,
                  ),
                ),
                if (lesson.chapterSubtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    lesson.chapterSubtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section heading with soft peach underline matching screenshot design.
class _SectionHeading extends StatelessWidget {
  final String text;

  const _SectionHeading({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 17.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E5B94),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 38,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB68D),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

/// Card presenting a visual fraction diagram item matching screenshot.
class _DiagramCard extends StatelessWidget {
  final LessonDiagram diagram;

  const _DiagramCard({required this.diagram});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderVariant.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: AppElevation.cardLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              diagram.imageAssetOrUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            diagram.title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4A3E38),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

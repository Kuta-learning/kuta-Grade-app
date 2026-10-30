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
import '../services/mock_notes_service.dart';
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
  LessonDetail? _fallbackLesson;

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
        MockNotesService().getChapterNoteDetail(widget.chapterId).then((data) {
          if (mounted) setState(() => _fallbackLesson = data);
        });
      }
    });
  }

  void _onDownloadResource(LessonResource res) {
    AppSnackBar.showSuccess(
      context,
      'Downloading ${res.title} (${res.fileSize})...',
    );
    try {
      context.read<NotesBloc>().add(DownloadChapterPdfEvent(res.id));
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
                      : (_lesson ??
                          bloc?.getCachedLesson(widget.chapterId) ??
                          _fallbackLesson);

                  if (lesson != null) {
                    return _buildContent(lesson);
                  }
                  if (state is NotesLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: NotesLoadingSkeleton(itemCount: 3),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: NotesLoadingSkeleton(itemCount: 3),
                  );
                },
              )
            : (_lesson != null || _fallbackLesson != null
                ? _buildContent((_lesson ?? _fallbackLesson)!)
                : const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: NotesLoadingSkeleton(itemCount: 3),
                  )),
      ),
    );
  }

  Widget _buildContent(LessonDetail lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Hero Card
        const _LessonHeroCard(),

        // 2. Learning Objectives Card (Target icon, orange heading, outlined checks)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
          child: LearningObjectivesCard(
            objectives: lesson.learningObjectives,
          ),
        ),

        // 3. Middle Section: Section Heading + Body Text + Diagram Cards
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeading(text: lesson.sectionHeading),
              const SizedBox(height: 10),
              Text(
                lesson.bodyText,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Diagram Cards matching screenshot
              for (final diagram in lesson.diagrams) ...[
                _DiagramCard(diagram: diagram),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),

        // 4. Lower Section: Steps to Simplify + Lesson Resources + Progress Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Steps Heading with horizontal line matching screenshot
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

              // Step Cards matching screenshot
              for (final step in lesson.steps) ...[
                LessonStepCard(step: step),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 20),

              // Lesson Resources Heading Row
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
                    '3 Files',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orange900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Resources List matching screenshot
              for (final res in lesson.resources) ...[
                LessonResourceCard(
                  resource: res,
                  onDownload: () => _onDownloadResource(res),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 24),

              // Lesson Progress Row
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
                    '100% Read',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orange900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Solid Green Progress Bar matching screenshot
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Hero card displaying the fraction illustration matching the screenshot.
class _LessonHeroCard extends StatelessWidget {
  const _LessonHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppElevation.cardLow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 269 / 193,
          child: Image.asset(
            'assets/images/fraction_lesson_hero.png',
            fit: BoxFit.cover,
          ),
        ),
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

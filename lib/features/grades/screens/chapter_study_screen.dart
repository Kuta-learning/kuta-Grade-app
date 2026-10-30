import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/rive_loading_widget.dart';
import '../bloc/grades_bloc.dart';
import '../models/course_models.dart';
import '../services/mock_courses_service.dart';
import '../widgets/learning_objectives_card.dart';

/// Screen displaying the lesson content, learning objectives, and completion action.
/// Connects to GET /lessons/:lessonId and POST /progress/lessons/:lessonId/complete.
class ChapterStudyScreen extends StatefulWidget {
  final String? lessonId;
  final String? chapterId;
  final String lessonTitle;
  final String chapterTitle;
  final String courseTitle;

  const ChapterStudyScreen({
    super.key,
    this.lessonId,
    this.chapterId,
    this.lessonTitle = 'Lesson Study',
    this.chapterTitle = 'Unit Overview',
    this.courseTitle = 'Course',
  });

  @override
  State<ChapterStudyScreen> createState() => _ChapterStudyScreenState();
}

class _ChapterStudyScreenState extends State<ChapterStudyScreen> {
  LessonDetailContentModel? _lesson;
  LessonDetailContentModel? _fallbackLesson;
  late String _activeLessonId;

  @override
  void initState() {
    super.initState();
    _activeLessonId = widget.lessonId ?? widget.chapterId ?? 'lesson-1-1';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLesson();
    });
  }

  void _loadLesson() {
    try {
      final bloc = context.read<CoursesBloc>();
      final cached = bloc.getCachedLesson(_activeLessonId);
      if (cached != null) {
        setState(() => _lesson = cached);
      } else {
        bloc.add(LoadLessonDetail(_activeLessonId));
      }
    } catch (_) {
      MockCoursesService().getLessonDetails(_activeLessonId).then((data) {
        if (mounted) setState(() => _fallbackLesson = data);
      });
    }
  }

  void _onCompleteLesson() {
    try {
      context.read<CoursesBloc>().add(CompleteLessonEvent(_activeLessonId));
      AppSnackBar.showSuccess(
        context,
        'Lesson marked as completed! Progress updated.',
      );
    } catch (_) {
      setState(() {
        if (_lesson != null) {
          _lesson = _lesson!.copyWith(isCompleted: true);
        }
        if (_fallbackLesson != null) {
          _fallbackLesson = _fallbackLesson!.copyWith(isCompleted: true);
        }
      });
      AppSnackBar.showSuccess(
        context,
        'Lesson marked as completed! Progress updated.',
      );
    }
  }

  void _onOpenQuiz(String quizId) {
    context.push(
      '${RouteNames.quiz}'
      '?quizId=${Uri.encodeComponent(quizId)}'
      '&title=${Uri.encodeComponent("${widget.lessonTitle} Quiz")}',
    );
  }

  @override
  Widget build(BuildContext context) {
    CoursesBloc? bloc;
    try {
      bloc = context.read<CoursesBloc>();
    } catch (_) {
      bloc = null;
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          color: AppColors.brandPrimary,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      tooltip: 'Back',
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.courses);
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.lessonTitle,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: bloc != null
          ? BlocConsumer<CoursesBloc, CoursesState>(
              listener: (context, state) {
                if (state is CourseLessonDetailLoaded &&
                    state.lesson.id == _activeLessonId) {
                  setState(() => _lesson = state.lesson);
                }
              },
              builder: (context, state) {
                final displayLesson = (state is CourseLessonDetailLoaded &&
                        state.lesson.id == _activeLessonId)
                    ? state.lesson
                    : (_lesson ??
                        bloc?.getCachedLesson(_activeLessonId) ??
                        _fallbackLesson);

                final isCompleting =
                    (state is CourseLessonDetailLoaded) ? state.isCompleting : false;

                if (displayLesson != null) {
                  return _buildLessonView(displayLesson, isCompleting);
                }
                if (state is CourseLessonDetailLoading) {
                  return const Center(
                    child: KutaLoadingWidget(
                      size: 130,
                      label: 'Loading Lesson Content...',
                    ),
                  );
                }
                return const Center(
                  child: KutaLoadingWidget(
                    size: 130,
                    label: 'Loading Lesson Content...',
                  ),
                );
              },
            )
          : (_lesson != null || _fallbackLesson != null
              ? _buildLessonView((_lesson ?? _fallbackLesson)!, false)
              : const Center(
                  child: KutaLoadingWidget(
                    size: 130,
                    label: 'Loading Lesson Content...',
                  ),
                )),
    );
  }

  Widget _buildLessonView(
      LessonDetailContentModel lesson, bool isCompleting) {
    if (lesson.isLocked) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 32,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Lesson Locked',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headlineDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please complete previous lessons in "${widget.chapterTitle}" to unlock this module.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${widget.courseTitle} • ${widget.chapterTitle}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Lesson Title & Duration
          Text(
            lesson.title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.headlineDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${lesson.durationMinutes ?? 15} minutes estimated reading',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              if (lesson.isCompleted) ...[
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 12, color: Color(0xFF065F46)),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Learning Objectives Card if present
          if (lesson.learningObjectives.isNotEmpty) ...[
            LearningObjectivesCard(objectives: lesson.learningObjectives),
            const SizedBox(height: 18),
          ],

          // Lesson Content Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderVariant.withValues(alpha: 0.6),
                width: 1,
              ),
              boxShadow: AppElevation.cardLow,
            ),
            child: Text(
              lesson.content,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.6,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Complete Lesson Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed:
                  (lesson.isCompleted || isCompleting) ? null : _onCompleteLesson,
              icon: isCompleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      lesson.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.check_rounded,
                      color: Colors.white,
                    ),
              label: Text(
                lesson.isCompleted
                    ? 'Lesson Completed'
                    : isCompleting
                        ? 'Saving Progress...'
                        : 'Mark as Completed',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: lesson.isCompleted
                    ? AppColors.success
                    : AppColors.brandPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Linked Quiz Button if available
          if (lesson.quizId != null && lesson.quizId!.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _onOpenQuiz(lesson.quizId!),
                icon: const Icon(Icons.quiz_outlined, color: AppColors.orange900),
                label: Text(
                  'Take Associated Quiz',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.orange900,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFB68D), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

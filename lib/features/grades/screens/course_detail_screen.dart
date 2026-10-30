import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/rive_loading_widget.dart';
import '../bloc/grades_bloc.dart';
import '../models/course_models.dart';
import '../services/mock_courses_service.dart';
import '../widgets/grade_screen_shell.dart';

/// Screen displaying the full structure of a course (chapters, topics, lessons, quizzes).
class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final String title;
  final int gradeLevel;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.title = 'Course Details',
    this.gradeLevel = 12,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  CourseModel? _course;
  CourseModel? _fallbackCourse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  void _loadDetails() {
    try {
      final bloc = context.read<CoursesBloc>();
      final cached = bloc.getCachedCourse(widget.courseId);
      if (cached != null) {
        setState(() => _course = cached);
      } else {
        bloc.add(LoadCourseDetail(widget.courseId));
      }
    } catch (_) {
      MockCoursesService().getCourseDetails(widget.courseId).then((data) {
        if (mounted) setState(() => _fallbackCourse = data);
      });
    }
  }

  void _onOpenLesson(CourseLessonItemModel lesson, CourseChapterModel chapter) {
    if (lesson.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Complete preceding lessons to unlock "${lesson.title}".',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppColors.headlineDark,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    context.push(
      '${RouteNames.chapterStudy}'
      '?lessonId=${Uri.encodeComponent(lesson.id)}'
      '&lessonTitle=${Uri.encodeComponent(lesson.title)}'
      '&chapterTitle=${Uri.encodeComponent(chapter.title)}'
      '&courseTitle=${Uri.encodeComponent(_course?.title ?? widget.title)}',
    );
  }

  void _onOpenQuiz(String quizId, String title) {
    context.push(
      '${RouteNames.quiz}'
      '?quizId=${Uri.encodeComponent(quizId)}'
      '&title=${Uri.encodeComponent(title)}',
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
            child: GradeExamAppBar(
              title: widget.title,
              onBackPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RouteNames.courses);
                }
              },
            ),
          ),
        ),
      ),
      body: bloc != null
          ? BlocConsumer<CoursesBloc, CoursesState>(
              listener: (context, state) {
                if (state is CourseDetailLoaded &&
                    state.course.id == widget.courseId) {
                  setState(() => _course = state.course);
                }
              },
              builder: (context, state) {
                final displayCourse = (state is CourseDetailLoaded &&
                        state.course.id == widget.courseId)
                    ? state.course
                    : (_course ??
                        bloc?.getCachedCourse(widget.courseId) ??
                        _fallbackCourse);

                if (displayCourse != null) {
                  return _buildContent(displayCourse);
                }
                if (state is CourseDetailLoading) {
                  return const Center(
                    child: KutaLoadingWidget(
                      size: 130,
                      label: 'Loading Course Structure...',
                    ),
                  );
                }
                return const Center(
                  child: KutaLoadingWidget(
                    size: 130,
                    label: 'Loading Course Structure...',
                  ),
                );
              },
            )
          : (_course != null || _fallbackCourse != null
              ? _buildContent((_course ?? _fallbackCourse)!)
              : const Center(
                  child: KutaLoadingWidget(
                    size: 130,
                    label: 'Loading Course Structure...',
                  ),
                )),
    );
  }

  Widget _buildContent(CourseModel course) {
    final progress = course.progressPercent.clamp(0.0, 1.0);
    final percentInt = (progress * 100).toInt();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Card
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.headlineDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  course.description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Completion',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$percentInt%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orange900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.accentHover),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Course Syllabus / Chapters Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course Curriculum',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headlineDark,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                '${course.chapters.length} Units',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Chapter list
          for (final chapter in course.chapters) ...[
            _buildChapterCard(chapter),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildChapterCard(CourseChapterModel chapter) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderVariant.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: AppElevation.cardLow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: chapter.chapterNumber == 1,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            chapter.title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.headlineDark,
            ),
          ),
          subtitle: chapter.description != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    chapter.description!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : null,
          trailing: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF475569),
              size: 20,
            ),
          ),
          children: [
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            for (final lesson in chapter.lessons) ...[
              _buildLessonTile(lesson, chapter),
            ],
            // Quiz item if present on any lesson
            if (chapter.lessons.any((l) => l.quizId != null)) ...[
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDD5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.quiz_outlined,
                        color: AppColors.orange900,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unit ${chapter.chapterNumber} Assessment Quiz',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.buttonTextBrown,
                            ),
                          ),
                          Text(
                            'Timed test with instant evaluation',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.authBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final quizId = chapter.lessons
                            .firstWhere((l) => l.quizId != null)
                            .quizId!;
                        _onOpenQuiz(quizId, 'Unit ${chapter.chapterNumber} Quiz');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange500,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Take Quiz',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLessonTile(
      CourseLessonItemModel lesson, CourseChapterModel chapter) {
    final isLocked = lesson.isLocked;
    final isCompleted = lesson.isCompleted;

    return InkWell(
      onTap: () => _onOpenLesson(lesson, chapter),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Status Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFD1FAE5)
                    : isLocked
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFFDBE9FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : isLocked
                        ? Icons.lock_outline_rounded
                        : Icons.play_arrow_rounded,
                size: 18,
                color: isCompleted
                    ? const Color(0xFF065F46)
                    : isLocked
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF1A56DB),
              ),
            ),
            const SizedBox(width: 14),

            // Lesson Title & Duration
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight:
                          isCompleted ? FontWeight.w600 : FontWeight.w500,
                      color: isLocked
                          ? const Color(0xFF94A3B8)
                          : AppColors.headlineDark,
                    ),
                  ),
                  if (lesson.duration != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      lesson.duration!,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (!isLocked)
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}


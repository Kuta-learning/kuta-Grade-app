import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/rive_loading_widget.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../bloc/grades_bloc.dart';
import '../models/course_models.dart';
import '../services/mock_courses_service.dart';
import '../widgets/grade_screen_shell.dart';

/// Screen listing curriculum courses, progress, and practice quizzes for the student's actual grade.
class CoursesScreen extends StatefulWidget {
  final int? initialGradeLevel;

  const CoursesScreen({super.key, this.initialGradeLevel});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  late int _selectedGrade;
  List<CourseModel>? _fallbackCourses;

  @override
  void initState() {
    super.initState();
    _selectedGrade = widget.initialGradeLevel ?? _resolveStudentGrade();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCoursesForCurrentGrade();
    });
  }

  int _resolveStudentGrade() {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.user.gradeLevel != null) {
        final val = authState.user.gradeLevel!.numericValue;
        if (val > 0) return val;
      }
    } catch (_) {}
    return 12; // Safe default
  }

  void _loadCoursesForCurrentGrade() {
    try {
      final bloc = context.read<CoursesBloc>();
      final cached = bloc.getCachedCourses(_selectedGrade);
      if (cached == null || cached.isEmpty) {
        bloc.add(LoadCoursesForGrade(_selectedGrade));
      }
    } catch (_) {
      MockCoursesService().getCoursesForGrade(_selectedGrade).then((list) {
        if (mounted) setState(() => _fallbackCourses = list);
      });
    }
  }

  void _onSwitchGrade(int grade) {
    if (_selectedGrade == grade) return;
    setState(() {
      _selectedGrade = grade;
      _fallbackCourses = null;
    });
    try {
      context.read<CoursesBloc>().add(LoadCoursesForGrade(grade));
    } catch (_) {
      MockCoursesService().getCoursesForGrade(grade).then((list) {
        if (mounted) setState(() => _fallbackCourses = list);
      });
    }
  }

  void _onOpenCourse(CourseModel course) {
    context.push(
      '${RouteNames.courseDetail}'
      '?courseId=${Uri.encodeComponent(course.id)}'
      '&title=${Uri.encodeComponent(course.title)}'
      '&gradeLevel=$_selectedGrade',
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

    return GradeScreenShell(
      title: 'Courses & Practice',
      streamTitle: 'CURRICULUM & PRACTICE',
      subtitle: 'Interactive Lessons, Chapter Topics & Quizzes',
      showBottomNav: false,
      selectedNavIndex: 2,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadCoursesForCurrentGrade();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grade level selection pills
              _buildGradePillSelector(),
              const SizedBox(height: 18),

              // Header summary row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Grade $_selectedGrade Courses',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.headlineDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    'Active Term',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Content based on BLoC state
              if (bloc != null)
                BlocBuilder<CoursesBloc, CoursesState>(
                  builder: (context, state) {
                    if (state is CoursesLoaded &&
                        state.gradeLevel == _selectedGrade) {
                      return _buildCourseList(state.courses);
                    }
                    if (state is CoursesLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: KutaLoadingWidget(
                            size: 130,
                            label: 'Loading Courses...',
                          ),
                        ),
                      );
                    }
                    final cached = bloc?.getCachedCourses(_selectedGrade) ??
                        _fallbackCourses;
                    if (cached != null && cached.isNotEmpty) {
                      return _buildCourseList(cached);
                    }
                    if (state is CoursesError) {
                      return _buildErrorState(state.message);
                    }
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: KutaLoadingWidget(
                          size: 130,
                          label: 'Loading Courses...',
                        ),
                      ),
                    );
                  },
                )
              else if (_fallbackCourses != null)
                _buildCourseList(_fallbackCourses!)
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: KutaLoadingWidget(
                      size: 130,
                      label: 'Loading Courses...',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradePillSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [6, 8, 12].map((grade) {
          final isSelected = _selectedGrade == grade;
          return Expanded(
            child: InkWell(
              onTap: () => _onSwitchGrade(grade),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected ? AppElevation.cardLow : null,
                ),
                child: Text(
                  'Grade $grade',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.brandPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCourseList(List<CourseModel> courses) {
    if (courses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.school_outlined, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                'No courses available for Grade $_selectedGrade',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headlineDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: courses.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final course = courses[index];
        return _CourseCard(
          course: course,
          onTap: () => _onOpenCourse(course),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 44, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              'Failed to load courses',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.headlineDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCoursesForCurrentGrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const _CourseCard({
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = course.progressPercent.clamp(0.0, 1.0);
    final percentInt = (progress * 100).toInt();

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIcon(course),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.headlineDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.description,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Progress bar & metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${course.totalChapters} Chapters • ${course.totalLessons} Lessons',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$percentInt% Completed',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: percentInt == 100
                          ? AppColors.success
                          : AppColors.orange900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentInt == 100
                        ? AppColors.success
                        : AppColors.accentHover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(CourseModel course) {
    Color bg = const Color(0xFFDBE9FF);
    Color iconColor = const Color(0xFF1A56DB);
    IconData iconData = Icons.menu_book_rounded;

    final lower = course.subject.toLowerCase();
    if (lower.contains('math')) {
      bg = const Color(0xFFFFDBCA);
      iconColor = const Color(0xFF341100);
      iconData = Icons.functions_rounded;
    } else if (lower.contains('physic')) {
      bg = const Color(0xFFDBE9FF);
      iconColor = const Color(0xFF1A56DB);
      iconData = Icons.offline_bolt_outlined;
    } else if (lower.contains('chem')) {
      bg = const Color(0xFFD1FAE5);
      iconColor = const Color(0xFF065F46);
      iconData = Icons.science_outlined;
    } else if (lower.contains('bio')) {
      bg = const Color(0xFFFFEDD5);
      iconColor = const Color(0xFF9A3412);
      iconData = Icons.psychology_outlined;
    } else if (lower.contains('civic') || lower.contains('ethic')) {
      bg = const Color(0xFFE8DCCA);
      iconColor = const Color(0xFF584237);
      iconData = Icons.balance_rounded;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }
}

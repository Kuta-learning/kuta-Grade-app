import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/router/route_names.dart';
import '../../../core/storage/shared_prefs_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/widgets/rive_loading_widget.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/models/user_model.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/models/profile_model.dart';
import '../bloc/grades_bloc.dart';
import '../models/course_models.dart';
import '../services/mock_courses_service.dart';
import '../widgets/grade_screen_shell.dart';

/// Screen listing curriculum courses, progress, and practice quizzes for the
/// authenticated student's specific grade level.
///
/// Strictly isolates content so Grade 12 students only see Grade 12 practice content,
/// and Grade 6 or Grade 8 students only see their respective grade content.
class CoursesScreen extends StatefulWidget {
  final int? initialGradeLevel;

  const CoursesScreen({super.key, this.initialGradeLevel});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  late int _studentGrade;
  List<CourseModel>? _fallbackCourses;
  bool _isResolvingGrade = false;

  @override
  void initState() {
    super.initState();
    _studentGrade = widget.initialGradeLevel ?? _resolveInitialStudentGrade();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCoursesForCurrentGrade();
      _fetchStudentGradeFromApi();
    });
  }

  /// Extracts the numeric grade level from [UserModel] or [ProfileModel].
  int? _extractGradeFromEntity(dynamic entity) {
    if (entity == null) return null;
    if (entity is UserModel && entity.gradeLevel != null) {
      final val = entity.gradeLevel!.numericValue;
      if (val > 0) return val;
    }
    if (entity is ProfileModel && entity.gradeLevel != null) {
      final val = entity.gradeLevel!.numericValue;
      if (val > 0) return val;
    }
    return null;
  }

  /// Fast synchronous grade resolution from in-memory Blocs and SharedPreferences cache.
  int _resolveInitialStudentGrade() {
    // 1. Check AuthBloc in-memory state
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final g = _extractGradeFromEntity(authState.user);
        if (g != null) return g;
      }
    } catch (_) {}

    // 2. Check ProfileBloc in-memory state
    try {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        final g = _extractGradeFromEntity(profileState.profile);
        if (g != null) return g;
      }
    } catch (_) {}

    // 3. Fallback to default Ethiopian National Exam senior grade
    return 12;
  }

  /// Fetches the authenticated student's actual grade from the backend `/auth/me` endpoint.
  Future<void> _fetchStudentGradeFromApi() async {
    if (_isResolvingGrade) return;
    final isTesting =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTesting) return;
    _isResolvingGrade = true;

    try {
      // 1. Check local storage cache first
      final storage = SharedPrefsStorage.instanceOrNull;
      if (storage != null) {
        final rawUser = await storage.getString(StorageKeys.authUser);
        if (rawUser != null && rawUser.isNotEmpty) {
          final user = UserModel.fromJsonString(rawUser);
          final cachedGrade = _extractGradeFromEntity(user);
          if (cachedGrade != null && cachedGrade != _studentGrade) {
            _updateStudentGrade(cachedGrade);
          }
        }
      }

      // 2. Query live GET /auth/me for authoritative profile data
      final apiClient = ApiClient();
      final response = await apiClient.client.get(ApiEndpoints.me);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final userMap = data['profile'] ?? data['user'] ?? data;
        if (userMap is Map<String, dynamic>) {
          final rawGrade = userMap['gradeLevel'];
          int? liveGrade;
          if (rawGrade is int) {
            liveGrade = rawGrade;
          } else if (rawGrade != null) {
            liveGrade = int.tryParse(rawGrade.toString());
          }
          if (liveGrade != null && liveGrade > 0 && liveGrade != _studentGrade) {
            _updateStudentGrade(liveGrade);
          }
        }
      }
    } catch (_) {
      // Retain current grade if offline or network error
    } finally {
      _isResolvingGrade = false;
    }
  }

  void _updateStudentGrade(int newGrade) {
    if (!mounted || newGrade == _studentGrade) return;
    setState(() {
      _studentGrade = newGrade;
      _fallbackCourses = null;
    });
    _loadCoursesForCurrentGrade();
  }

  void _loadCoursesForCurrentGrade() {
    try {
      final bloc = context.read<CoursesBloc>();
      final cached = bloc.getCachedCourses(_studentGrade);
      if (cached == null || cached.isEmpty) {
        bloc.add(LoadCoursesForGrade(_studentGrade));
      }
    } catch (_) {
      MockCoursesService().getCoursesForGrade(_studentGrade).then((list) {
        if (mounted) setState(() => _fallbackCourses = list);
      });
    }
  }

  void _onOpenCourse(CourseModel course) {
    context.push(
      '${RouteNames.courseDetail}'
      '?courseId=${Uri.encodeComponent(course.id)}'
      '&title=${Uri.encodeComponent(course.title)}'
      '&gradeLevel=$_studentGrade',
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

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              final g = _extractGradeFromEntity(state.user);
              if (g != null && g != _studentGrade) {
                _updateStudentGrade(g);
              }
            }
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              final g = _extractGradeFromEntity(state.profile);
              if (g != null && g != _studentGrade) {
                _updateStudentGrade(g);
              }
            }
          },
        ),
      ],
      child: GradeScreenShell(
        title: 'Courses & Practice',
        streamTitle: 'CURRICULUM & PRACTICE',
        subtitle: 'Interactive Lessons, Chapter Topics & Quizzes',
        showBottomNav: false,
        selectedNavIndex: 2,
        showBackButton: false, // Main tab screen: no back arrow
        body: RefreshIndicator(
          onRefresh: () async {
            await _fetchStudentGradeFromApi();
            _loadCoursesForCurrentGrade();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enrolled student grade indicator badge (No other grade options shown)
                _buildStudentGradeBanner(),
                const SizedBox(height: 18),

                // Header summary row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grade $_studentGrade Courses',
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
                          state.gradeLevel == _studentGrade) {
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
                      final cached = bloc?.getCachedCourses(_studentGrade) ??
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
      ),
    );
  }

  /// Displays the student's enrolled grade badge without showing other grade options.
  Widget _buildStudentGradeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppElevation.cardLow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school_rounded,
                  size: 16,
                  color: AppColors.brandPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Grade $_studentGrade',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Enrolled Curriculum & Practice',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(List<CourseModel> courses) {
    // Strictly filter to ensure only the student's grade content is rendered
    final gradeCourses = courses
        .where((course) => course.gradeLevel == _studentGrade)
        .toList();

    if (gradeCourses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Icon(Icons.school_outlined,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                'No courses available for Grade $_studentGrade',
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
      itemCount: gradeCourses.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final course = gradeCourses[index];
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

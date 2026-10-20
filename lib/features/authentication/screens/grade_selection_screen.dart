import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/academic_stream.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/grade_level.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../bloc/academic_selection/academic_selection_bloc.dart';
import '../bloc/auth_bloc.dart';

/// Screen allowing newly registered or onboarding students to select their grade level
/// and (for Grade 12) their academic specialization stream (Natural vs Social Science).
/// Integrates with [AcademicSelectionBloc] for dynamic step calculation and state persistence.
class GradeSelectionScreen extends StatelessWidget {
  const GradeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // If AuthBloc is available in context (standard app runtime), instantiate AcademicSelectionBloc wired to it.
    // If not (e.g. In isolated widget tests providing AcademicSelectionBloc directly), render view directly.
    final hasAuthBloc =
        context.findAncestorWidgetOfExactType<BlocProvider<AuthBloc>>() != null;

    if (!hasAuthBloc) {
      return const _GradeSelectionView();
    }

    // Provide AcademicSelectionBloc wired to AuthBloc's shared service
    return BlocProvider(
      create: (ctx) {
        final authBloc = ctx.read<AuthBloc>();
        return AcademicSelectionBloc(
          authService: authBloc.authService,
          authBloc: authBloc,
        );
      },
      child: const _GradeSelectionView(),
    );
  }
}

class _GradeSelectionView extends StatelessWidget {
  const _GradeSelectionView();

  void _onCtaPressed(BuildContext context, AcademicSelectionState state) {
    if (state.currentStep == 1 && state.isGrade12) {
      // Advance to Step 2 for Grade 12 Stream Selection
      context.read<AcademicSelectionBloc>().add(const ChangeStep(2));
    } else {
      // Complete academic selection
      context.read<AcademicSelectionBloc>().add(
        const SubmitAcademicSelection(),
      );
    }
  }

  void _onBackPressed(BuildContext context) {
    context.read<AcademicSelectionBloc>().add(const ChangeStep(1));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AcademicSelectionBloc, AcademicSelectionState>(
      listener: (context, state) {
        if (state.status == AcademicSelectionStatus.success) {
          // Route user according to selected grade level per routing architecture
          final grade = state.selectedGrade;
          if (grade == GradeLevel.kg) {
            context.go(RouteNames.kgHome);
          } else {
            context.go(RouteNames.grade12MatricExam);
          }
        } else if (state.status == AcademicSelectionStatus.failure &&
            state.errorMessage != null) {
          AppSnackBar.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == AcademicSelectionStatus.submitting;

        return Scaffold(
          backgroundColor: AppColors.surfaceApp,
          body: SafeArea(
            child: Column(
              children: [
                // ==========================================
                // 1. TOP PROGRESSION HEADER
                // ==========================================
                _buildProgressHeader(context, state),

                // ==========================================
                // 2. SCROLLABLE STEP CONTENT
                // ==========================================
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space6,
                      vertical: AppSpacing.space4,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOutCubic,
                      switchOutCurve: Curves.easeInOutCubic,
                      child: state.currentStep == 1
                          ? _buildStep1GradeSelection(context, state)
                          : _buildStep2StreamSelection(context, state),
                    ),
                  ),
                ),

                // ==========================================
                // 3. BOTTOM CTA BUTTON
                // ==========================================
                _buildBottomCta(context, state, isSubmitting),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 1. Top Progress Header ────────────────────────────────────────────────
  Widget _buildProgressHeader(
    BuildContext context,
    AcademicSelectionState state,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space6,
        AppSpacing.space4,
        AppSpacing.space6,
        AppSpacing.space2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Back Button (only shown on Step 2)
              if (state.currentStep == 2) ...[
                GestureDetector(
                  onTap: () => _onBackPressed(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderVariant),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],

              // Numbered Step Badge
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentDark,
                ),
                child: Center(
                  child: Text(
                    '${state.currentStep}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Step text e.g. "STEP 1 OF 2" or "STEP 1 OF 1"
              Text(
                state.stepLabel,
                style: const TextStyle(
                  color: AppColors.accentDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),

              const Spacer(),

              // Right progress percentage e.g. "50% completed" or "100% completed"
              Text(
                state.progressPercentText,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Linear Progress Track
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: state.progressPercentage),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6.0,
                  backgroundColor: AppColors.borderVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.orange500,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Step 1: Grade Selection ────────────────────────────────────────────
  Widget _buildStep1GradeSelection(
    BuildContext context,
    AcademicSelectionState state,
  ) {
    final grades = [
      _GradeOptionData(
        grade: GradeLevel.grade6,
        title: 'Grade 6',
        icon: Icons.menu_book_rounded,
        iconBgColor: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF2563EB),
      ),
      _GradeOptionData(
        grade: GradeLevel.grade8,
        title: 'Grade 8',
        icon: Icons.school_rounded,
        iconBgColor: const Color(0xFFF0FDF4),
        iconColor: const Color(0xFF16A34A),
      ),
      _GradeOptionData(
        grade: GradeLevel.grade12,
        title: 'Grade 12',
        icon: Icons.military_tech_rounded,
        iconBgColor: AppColors.accentLight,
        iconColor: AppColors.accentHover,
      ),
    ];

    return Column(
      key: const ValueKey('step_1'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Title
        Text(
          'Which grade are you in?',
          textAlign: TextAlign.center,
          style: AppTypography.displayLg.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Select your current level to personalize your learning path.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.authBrown.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Grade Option Cards
        ...grades.map((data) {
          final isSelected = state.selectedGrade == data.grade;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: _buildGradeCard(
              context: context,
              data: data,
              isSelected: isSelected,
              onTap: () {
                context.read<AcademicSelectionBloc>().add(
                  SelectGrade(data.grade),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGradeCard({
    required BuildContext context,
    required _GradeOptionData data,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: isSelected ? AppColors.orange500 : AppColors.borderVariant,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.orange500.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : AppElevation.elevation1,
          ),
          child: Row(
            children: [
              // Grade Leading Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.orange500 : data.iconBgColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  data.icon,
                  color: isSelected ? Colors.white : data.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Title
              Text(
                data.title,
                style: AppTypography.headlineLg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),

              const Spacer(),

              // Radio / Check Circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.accentDark : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentDark
                        : const Color(0xFFCBD5E1),
                    width: 2.0,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3. Step 2: Stream Selection (Grade 12) ────────────────────────────────
  Widget _buildStep2StreamSelection(
    BuildContext context,
    AcademicSelectionState state,
  ) {
    return Column(
      key: const ValueKey('step_2'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Title
        Text(
          'Select your stream',
          textAlign: TextAlign.center,
          style: AppTypography.displayLg.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle
        Text(
          'Grade 12 academic track',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLg.copyWith(color: AppColors.textSecondary),
        ),

        const SizedBox(height: 28),

        // Natural Science Card
        _buildStreamCard(
          context: context,
          stream: AcademicStream.natural,
          icon: Icons.science_rounded,
          iconBgColor: const Color(0xFFFFEDD5),
          iconColor: const Color(0xFFC2410C),
          isSelected: state.selectedStream == AcademicStream.natural,
          onTap: () {
            context.read<AcademicSelectionBloc>().add(
              const SelectStream(AcademicStream.natural),
            );
          },
        ),

        const SizedBox(height: 16),

        // Social Science Card
        _buildStreamCard(
          context: context,
          stream: AcademicStream.social,
          icon: Icons.account_balance_rounded,
          iconBgColor: const Color(0xFFE0E7FF),
          iconColor: const Color(0xFF4338CA),
          isSelected: state.selectedStream == AcademicStream.social,
          onTap: () {
            context.read<AcademicSelectionBloc>().add(
              const SelectStream(AcademicStream.social),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStreamCard({
    required BuildContext context,
    required AcademicStream stream,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: isSelected ? AppColors.orange500 : AppColors.borderVariant,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.orange500.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : AppElevation.elevation1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Avatar Icon + Title/Subtitle + Radio
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.orange500 : iconBgColor,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title & Career Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stream.displayName,
                          style: AppTypography.headlineLg.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 17.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          stream.description,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Radio Check Indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.accentDark
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentDark
                            : const Color(0xFFCBD5E1),
                        width: 2.0,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Subject Pills
              Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: stream.subjects.map((subject) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 5.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.containerHigh,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 4. Bottom CTA Button ──────────────────────────────────────────────────
  Widget _buildBottomCta(
    BuildContext context,
    AcademicSelectionState state,
    bool isSubmitting,
  ) {
    final canProceed = state.canProceed && !isSubmitting;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space6,
        AppSpacing.space2,
        AppSpacing.space6,
        AppSpacing.space6,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: canProceed ? AppColors.orange500 : AppColors.borderVariant,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: canProceed
                ? [
                    BoxShadow(
                      color: AppColors.orange500.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: canProceed ? () => _onCtaPressed(context, state) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.ctaLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20.0,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _GradeOptionData {
  final GradeLevel grade;
  final String title;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  _GradeOptionData({
    required this.grade,
    required this.title,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

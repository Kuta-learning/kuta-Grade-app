import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/rive_loading_widget.dart';
import '../bloc/grades_bloc.dart';
import '../models/quiz_models.dart';
import '../services/mock_courses_service.dart';
import '../widgets/grade_screen_shell.dart';

/// Screen displaying the result, score, and detailed question review of a quiz attempt.
/// Connects to GET /quizzes/attempts/:attemptId.
class QuizResultScreen extends StatefulWidget {
  final String attemptId;
  final String? quizId;
  final String quizTitle;

  const QuizResultScreen({
    super.key,
    required this.attemptId,
    this.quizId,
    this.quizTitle = 'Quiz Assessment',
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  QuizAttemptReviewModel? _review;
  QuizAttemptReviewModel? _fallbackReview;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReview();
    });
  }

  void _loadReview() {
    try {
      final bloc = context.read<CoursesBloc>();
      bloc.add(LoadQuizReviewEvent(widget.attemptId));
    } catch (_) {
      MockCoursesService().getQuizAttemptReview(widget.attemptId).then((data) {
        if (mounted) setState(() => _fallbackReview = data);
      });
    }
  }

  void _onRetake() {
    if (widget.quizId != null && widget.quizId!.isNotEmpty) {
      context.pushReplacement(
        '${RouteNames.quiz}'
        '?quizId=${Uri.encodeComponent(widget.quizId!)}'
        '&title=${Uri.encodeComponent(widget.quizTitle)}',
      );
    } else {
      context.pop();
    }
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
              title: 'Quiz Results & Review',
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
                if (state is QuizReviewLoaded) {
                  setState(() => _review = state.review);
                }
              },
              builder: (context, state) {
                final displayReview =
                    (state is QuizReviewLoaded) ? state.review : (_review ?? _fallbackReview);

                if (displayReview != null) {
                  return _buildContent(displayReview);
                }
                if (state is QuizReviewLoading) {
                  return const Center(
                    child: KutaLoadingWidget(
                      size: 130,
                      label: 'Loading Quiz Results...',
                    ),
                  );
                }
                return const Center(
                  child: KutaLoadingWidget(
                    size: 130,
                    label: 'Loading Quiz Results...',
                  ),
                );
              },
            )
          : (_review != null || _fallbackReview != null
              ? _buildContent((_review ?? _fallbackReview)!)
              : const Center(
                  child: KutaLoadingWidget(
                    size: 130,
                    label: 'Loading Quiz Results...',
                  ),
                )),
    );
  }

  Widget _buildContent(QuizAttemptReviewModel review) {
    final passed = review.passed;
    final percentage = review.percentage.round();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: passed
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFFEDD5),
                width: 1.5,
              ),
              boxShadow: AppElevation.cardLow,
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: passed
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFFEDD5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$percentage%',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: passed
                            ? const Color(0xFF065F46)
                            : const Color(0xFF9A3412),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  passed ? 'Quiz Passed!' : 'Needs More Practice',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.headlineDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Score: ${review.score} / ${review.totalScore} correct answers',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _onRetake,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.brandPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Retake Quiz',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(RouteNames.courses);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Question-by-Question Review Header
          Text(
            'Answer Review',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.headlineDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),

          // Question list
          for (int i = 0; i < review.questions.length; i++) ...[
            _buildQuestionReviewCard(i + 1, review.questions[i]),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionReviewCard(
      int index, QuizQuestionReviewItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isCorrect
              ? const Color(0xFFD1FAE5)
              : const Color(0xFFFFECEF),
          width: 1.2,
        ),
        boxShadow: AppElevation.cardLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: item.isCorrect
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFFECEF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isCorrect ? Icons.check : Icons.close,
                  size: 16,
                  color: item.isCorrect
                      ? const Color(0xFF065F46)
                      : const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Question $index',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.headlineDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.questionText,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),

          // Options display
          for (final opt in item.options) ...[
            _buildOptionRow(opt, item),
            const SizedBox(height: 6),
          ],

          if (item.explanation != null && item.explanation!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.explanation!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.4,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionRow(
      QuizQuestionOption option, QuizQuestionReviewItem item) {
    final isSelected = option.id == item.selectedOptionId;
    final isCorrect = option.id == item.correctOptionId;

    Color bg = const Color(0xFFF8FAFC);
    Color border = const Color(0xFFE2E8F0);
    Color textCol = const Color(0xFF475569);

    if (isCorrect) {
      bg = const Color(0xFFECFDF5);
      border = const Color(0xFF10B981);
      textCol = const Color(0xFF065F46);
    } else if (isSelected && !item.isCorrect) {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFEF4444);
      textCol = const Color(0xFF991B1B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          if (option.label != null) ...[
            Text(
              '${option.label}. ',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: textCol,
              ),
            ),
          ],
          Expanded(
            child: Text(
              option.optionText,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight:
                    (isSelected || isCorrect) ? FontWeight.w600 : FontWeight.w400,
                color: textCol,
              ),
            ),
          ),
          if (isCorrect)
            const Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981))
          else if (isSelected && !item.isCorrect)
            const Icon(Icons.cancel, size: 16, color: Color(0xFFEF4444)),
        ],
      ),
    );
  }
}


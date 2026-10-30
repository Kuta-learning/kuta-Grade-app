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
import '../models/quiz_models.dart';
import '../services/mock_courses_service.dart';

/// Assessment and Quiz Screen for Grades 6, 8, and 12.
/// Connects to GET /quizzes/:quizId and POST /quizzes/:quizId/submit.
class QuizScreen extends StatefulWidget {
  final String quizId;
  final String title;

  const QuizScreen({
    super.key,
    this.quizId = 'quiz-1',
    this.title = 'Assessment Quiz',
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  QuizDetailModel? _quiz;
  QuizDetailModel? _fallbackQuiz;
  final Map<String, String> _localAnswers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuiz();
    });
  }

  void _loadQuiz() {
    try {
      final bloc = context.read<CoursesBloc>();
      final cached = bloc.getCachedQuiz(widget.quizId);
      if (cached != null) {
        setState(() => _quiz = cached);
      } else {
        bloc.add(LoadQuizEvent(widget.quizId));
      }
    } catch (_) {
      MockCoursesService().getQuiz(widget.quizId).then((data) {
        if (mounted) setState(() => _fallbackQuiz = data);
      });
    }
  }

  void _onSelectOption(String questionId, String optionId) {
    setState(() {
      _localAnswers[questionId] = optionId;
    });
    try {
      context
          .read<CoursesBloc>()
          .add(SelectQuizOptionEvent(questionId, optionId));
    } catch (_) {}
  }

  void _onSubmitQuiz(QuizDetailModel quiz) {
    if (_localAnswers.isEmpty) {
      AppSnackBar.showError(
        context,
        'Please answer at least one question before submitting.',
      );
      return;
    }

    try {
      context.read<CoursesBloc>().add(SubmitQuizEvent(widget.quizId));
    } catch (_) {
      // Local simulated fallback
      final answers = _localAnswers.entries
          .map((e) => QuizAnswerSubmissionItem(
                questionId: e.key,
                selectedOptionId: e.value,
              ))
          .toList();
      MockCoursesService()
          .submitQuiz(widget.quizId, QuizSubmissionRequest(answers: answers))
          .then((resp) {
        if (mounted) {
          _navigateToResult(resp.attemptId);
        }
      });
    }
  }

  void _navigateToResult(String attemptId) {
    context.pushReplacement(
      '${RouteNames.quizResult}'
      '?attemptId=${Uri.encodeComponent(attemptId)}'
      '&quizId=${Uri.encodeComponent(widget.quizId)}'
      '&title=${Uri.encodeComponent(_quiz?.title ?? widget.title)}',
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
                        _quiz?.title ?? widget.title,
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
                if (state is QuizLoaded && state.quiz.id == widget.quizId) {
                  setState(() {
                    _quiz = state.quiz;
                    _localAnswers.addAll(state.selectedAnswers);
                  });
                } else if (state is QuizSubmitted) {
                  _navigateToResult(state.response.attemptId);
                }
              },
              builder: (context, state) {
                final displayQuiz = (state is QuizLoaded)
                    ? state.quiz
                    : (_quiz ??
                        bloc?.getCachedQuiz(widget.quizId) ??
                        _fallbackQuiz);

                final isSubmitting =
                    (state is QuizLoaded) ? state.isSubmitting : false;

                if (displayQuiz != null) {
                  return _buildQuizContent(displayQuiz, isSubmitting);
                }
                if (state is QuizLoading) {
                  return const Center(
                    child: KutaLoadingWidget(
                      size: 130,
                      label: 'Loading Quiz Questions...',
                    ),
                  );
                }
                return const Center(
                  child: KutaLoadingWidget(
                    size: 130,
                    label: 'Loading Quiz Questions...',
                  ),
                );
              },
            )
          : (_quiz != null || _fallbackQuiz != null
              ? _buildQuizContent((_quiz ?? _fallbackQuiz)!, false)
              : const Center(
                  child: KutaLoadingWidget(
                    size: 130,
                    label: 'Loading Quiz Questions...',
                  ),
                )),
    );
  }

  Widget _buildQuizContent(QuizDetailModel quiz, bool isSubmitting) {
    if (quiz.questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.quiz_outlined,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                'No questions available for this quiz.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headlineDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalQuestions = quiz.questions.length;
    if (_currentQuestionIndex >= totalQuestions) {
      _currentQuestionIndex = totalQuestions - 1;
    }
    final currentQuestion = quiz.questions[_currentQuestionIndex];
    final selectedOptionId = _localAnswers[currentQuestion.id];
    final isLastQuestion = _currentQuestionIndex == totalQuestions - 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info: Progress and Time Limit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandPrimary,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.timeLimitMinutes} mins',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Progress indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / totalQuestions,
              minHeight: 5,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accentHover),
            ),
          ),
          const SizedBox(height: 18),

          // Question Prompt Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
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
              currentQuestion.questionText,
              style: GoogleFonts.inter(
                fontSize: 15.5,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: AppColors.headlineDark,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Options List
          for (final option in currentQuestion.options) ...[
            _buildOptionCard(
              option: option,
              isSelected: option.id == selectedOptionId,
              onTap: () => _onSelectOption(currentQuestion.id, option.id),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 24),

          // Navigation buttons (Previous / Next / Submit)
          Row(
            children: [
              if (_currentQuestionIndex > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          if (isLastQuestion) {
                            _onSubmitQuiz(quiz);
                          } else {
                            setState(() {
                              _currentQuestionIndex++;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastQuestion
                        ? AppColors.orange500
                        : AppColors.brandPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isLastQuestion ? 'Submit Quiz' : 'Next Question',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required QuizQuestionOption option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.brandPrimary
              : AppColors.borderVariant.withValues(alpha: 0.6),
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: AppElevation.cardLow,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Circle indicator
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.brandPrimary
                      : const Color(0xFFF1F5F9),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : (option.label != null
                        ? Center(
                            child: Text(
                              option.label!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          )
                        : null),
              ),
              const SizedBox(width: 14),

              // Option text
              Expanded(
                child: Text(
                  option.optionText,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.brandPrimary
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

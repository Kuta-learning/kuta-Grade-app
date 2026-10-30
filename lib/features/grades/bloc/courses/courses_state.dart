part of 'courses_bloc.dart';

abstract class CoursesState {
  const CoursesState();
}

class CoursesInitial extends CoursesState {
  const CoursesInitial();
}

class CoursesLoading extends CoursesState {
  const CoursesLoading();
}

class CoursesLoaded extends CoursesState {
  final List<CourseModel> courses;
  final int gradeLevel;

  const CoursesLoaded({
    required this.courses,
    required this.gradeLevel,
  });
}

class CourseDetailLoading extends CoursesState {
  const CourseDetailLoading();
}

class CourseDetailLoaded extends CoursesState {
  final CourseModel course;

  const CourseDetailLoaded({required this.course});
}

class CourseLessonDetailLoading extends CoursesState {
  const CourseLessonDetailLoading();
}

class CourseLessonDetailLoaded extends CoursesState {
  final LessonDetailContentModel lesson;
  final bool isCompleting;

  const CourseLessonDetailLoaded({
    required this.lesson,
    this.isCompleting = false,
  });

  CourseLessonDetailLoaded copyWith({
    LessonDetailContentModel? lesson,
    bool? isCompleting,
  }) {
    return CourseLessonDetailLoaded(
      lesson: lesson ?? this.lesson,
      isCompleting: isCompleting ?? this.isCompleting,
    );
  }
}

class QuizLoading extends CoursesState {
  const QuizLoading();
}

class QuizLoaded extends CoursesState {
  final QuizDetailModel quiz;
  final Map<String, String> selectedAnswers;
  final bool isSubmitting;

  const QuizLoaded({
    required this.quiz,
    this.selectedAnswers = const {},
    this.isSubmitting = false,
  });

  QuizLoaded copyWith({
    QuizDetailModel? quiz,
    Map<String, String>? selectedAnswers,
    bool? isSubmitting,
  }) {
    return QuizLoaded(
      quiz: quiz ?? this.quiz,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class QuizSubmitted extends CoursesState {
  final QuizSubmissionResponse response;

  const QuizSubmitted({required this.response});
}

class QuizReviewLoading extends CoursesState {
  const QuizReviewLoading();
}

class QuizReviewLoaded extends CoursesState {
  final QuizAttemptReviewModel review;

  const QuizReviewLoaded({required this.review});
}

class CoursesError extends CoursesState {
  final String message;

  const CoursesError(this.message);
}


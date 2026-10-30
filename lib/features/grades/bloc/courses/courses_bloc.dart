import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/course_models.dart';
import '../../models/quiz_models.dart';
import '../../services/courses_service.dart';

part 'courses_event.dart';
part 'courses_state.dart';

/// State management for Grades Courses, Chapters, Lessons, Quizzes, and Progress.
class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  final CoursesService _coursesService;

  final Map<int, List<CourseModel>> _cachedCourses = {};
  final Map<String, CourseModel> _cachedCourseDetails = {};
  final Map<String, LessonDetailContentModel> _cachedLessons = {};
  final Map<String, QuizDetailModel> _cachedQuizzes = {};
  final Map<String, String> _quizAnswers = {};

  CoursesBloc(this._coursesService) : super(const CoursesInitial()) {
    on<LoadCoursesForGrade>(_onLoadCoursesForGrade);
    on<LoadCourseDetail>(_onLoadCourseDetail);
    on<LoadLessonDetail>(_onLoadLessonDetail);
    on<CompleteLessonEvent>(_onCompleteLesson);
    on<LoadQuizEvent>(_onLoadQuiz);
    on<SelectQuizOptionEvent>(_onSelectQuizOption);
    on<SubmitQuizEvent>(_onSubmitQuiz);
    on<LoadQuizReviewEvent>(_onLoadQuizReview);
  }

  CoursesService get coursesService => _coursesService;
  List<CourseModel>? getCachedCourses(int grade) => _cachedCourses[grade];
  CourseModel? getCachedCourse(String id) => _cachedCourseDetails[id];
  LessonDetailContentModel? getCachedLesson(String id) => _cachedLessons[id];
  QuizDetailModel? getCachedQuiz(String id) => _cachedQuizzes[id];
  Map<String, String> get quizAnswers => _quizAnswers;

  Future<void> _onLoadCoursesForGrade(
    LoadCoursesForGrade event,
    Emitter<CoursesState> emit,
  ) async {
    final cached = _cachedCourses[event.gradeLevel];
    if (cached != null && cached.isNotEmpty) {
      emit(CoursesLoaded(courses: cached, gradeLevel: event.gradeLevel));
      return;
    }

    emit(const CoursesLoading());
    try {
      final courses = await _coursesService.getCoursesForGrade(event.gradeLevel);
      _cachedCourses[event.gradeLevel] = courses;
      emit(CoursesLoaded(courses: courses, gradeLevel: event.gradeLevel));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> _onLoadCourseDetail(
    LoadCourseDetail event,
    Emitter<CoursesState> emit,
  ) async {
    final cached = _cachedCourseDetails[event.courseId];
    if (cached != null) {
      emit(CourseDetailLoaded(course: cached));
      return;
    }

    emit(const CourseDetailLoading());
    try {
      final course = await _coursesService.getCourseDetails(event.courseId);
      _cachedCourseDetails[event.courseId] = course;
      emit(CourseDetailLoaded(course: course));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> _onLoadLessonDetail(
    LoadLessonDetail event,
    Emitter<CoursesState> emit,
  ) async {
    final cached = _cachedLessons[event.lessonId];
    if (cached != null) {
      emit(CourseLessonDetailLoaded(lesson: cached));
      return;
    }

    emit(const CourseLessonDetailLoading());
    try {
      final lesson = await _coursesService.getLessonDetails(event.lessonId);
      _cachedLessons[event.lessonId] = lesson;
      emit(CourseLessonDetailLoaded(lesson: lesson));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> _onCompleteLesson(
    CompleteLessonEvent event,
    Emitter<CoursesState> emit,
  ) async {
    if (state is CourseLessonDetailLoaded) {
      final current = state as CourseLessonDetailLoaded;
      emit(current.copyWith(isCompleting: true));
      try {
        await _coursesService.completeLesson(event.lessonId);
        final updatedLesson = current.lesson.copyWith(isCompleted: true);
        _cachedLessons[event.lessonId] = updatedLesson;
        emit(CourseLessonDetailLoaded(lesson: updatedLesson, isCompleting: false));
      } catch (_) {
        emit(current.copyWith(isCompleting: false));
      }
    } else {
      try {
        await _coursesService.completeLesson(event.lessonId);
      } catch (_) {}
    }
  }

  Future<void> _onLoadQuiz(
    LoadQuizEvent event,
    Emitter<CoursesState> emit,
  ) async {
    _quizAnswers.clear();
    final cached = _cachedQuizzes[event.quizId];
    if (cached != null) {
      emit(QuizLoaded(quiz: cached, selectedAnswers: _quizAnswers));
      return;
    }

    emit(const QuizLoading());
    try {
      final quiz = await _coursesService.getQuiz(event.quizId);
      _cachedQuizzes[event.quizId] = quiz;
      emit(QuizLoaded(quiz: quiz, selectedAnswers: _quizAnswers));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  void _onSelectQuizOption(
    SelectQuizOptionEvent event,
    Emitter<CoursesState> emit,
  ) {
    _quizAnswers[event.questionId] = event.optionId;
    if (state is QuizLoaded) {
      final current = state as QuizLoaded;
      emit(current.copyWith(selectedAnswers: Map.from(_quizAnswers)));
    }
  }

  Future<void> _onSubmitQuiz(
    SubmitQuizEvent event,
    Emitter<CoursesState> emit,
  ) async {
    if (state is QuizLoaded) {
      final current = state as QuizLoaded;
      emit(current.copyWith(isSubmitting: true));

      final answers = _quizAnswers.entries
          .map((e) => QuizAnswerSubmissionItem(
                questionId: e.key,
                selectedOptionId: e.value,
              ))
          .toList();

      try {
        final response = await _coursesService.submitQuiz(
          event.quizId,
          QuizSubmissionRequest(answers: answers),
        );
        emit(QuizSubmitted(response: response));
      } catch (e) {
        emit(CoursesError(e.toString()));
      }
    }
  }

  Future<void> _onLoadQuizReview(
    LoadQuizReviewEvent event,
    Emitter<CoursesState> emit,
  ) async {
    emit(const QuizReviewLoading());
    try {
      final review = await _coursesService.getQuizAttemptReview(event.attemptId);
      emit(QuizReviewLoaded(review: review));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }
}


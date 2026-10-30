import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_grade/features/grades/bloc/grades_bloc.dart';
import 'package:kuta_grade/features/grades/models/quiz_models.dart';
import 'package:kuta_grade/features/grades/services/mock_courses_service.dart';

void main() {
  group('Courses, Lessons & Quizzes End-to-End Service Tests', () {
    late MockCoursesService mockService;

    setUp(() {
      mockService = MockCoursesService();
    });

    test('1. GET /courses?gradeLevel=12 returns Grade 12 courses', () async {
      final courses = await mockService.getCoursesForGrade(12);
      expect(courses, isNotEmpty);
      expect(courses.any((c) => c.subject.contains('Mathematics')), isTrue);
    });

    test('2. GET /courses/:courseId returns course detail with chapters', () async {
      final detail = await mockService.getCourseDetails('course-grade-12-math');
      expect(detail.id, 'course-grade-12-math');
      expect(detail.chapters, isNotEmpty);
      expect(detail.chapters.first.lessons, isNotEmpty);
    });

    test('3. GET /lessons/:lessonId returns lesson content and status', () async {
      final lesson = await mockService.getLessonDetails('lesson-12-func-1');
      expect(lesson.id, 'lesson-12-func-1');
      expect(lesson.title, isNotEmpty);
      expect(lesson.learningObjectives, isNotEmpty);
    });

    test('4. POST /progress/lessons/:lessonId/complete marks lesson as completed', () async {
      final success = await mockService.completeLesson('lesson-12-func-1');
      expect(success, isTrue);
    });

    test('5. GET /quizzes/:quizId returns questions and options', () async {
      final quiz = await mockService.getQuiz('quiz-12-unit-1');
      expect(quiz.id, 'quiz-12-unit-1');
      expect(quiz.questions, isNotEmpty);
      expect(quiz.questions.first.options, isNotEmpty);
    });

    test('6. POST /quizzes/:quizId/submit computes score and returns attemptId', () async {
      final quiz = await mockService.getQuiz('quiz-12-unit-1');
      final answers = quiz.questions
          .map((q) => QuizAnswerSubmissionItem(
                questionId: q.id,
                selectedOptionId: q.options.first.id,
              ))
          .toList();

      final submission = QuizSubmissionRequest(answers: answers);
      final response = await mockService.submitQuiz('quiz-12-unit-1', submission);

      expect(response.attemptId, isNotEmpty);
      expect(response.score, greaterThanOrEqualTo(0));
    });

    test('7. GET /quizzes/attempts/:attemptId returns full review and explanations', () async {
      final review = await mockService.getQuizAttemptReview('attempt-mock-12-unit-1');
      expect(review.id, 'attempt-mock-12-unit-1');
      expect(review.questions, isNotEmpty);
      expect(review.questions.first.explanation, isNotEmpty);
    });
  });

  group('CoursesBloc State Flow Tests', () {
    late MockCoursesService mockService;
    late CoursesBloc coursesBloc;

    setUp(() {
      mockService = MockCoursesService();
      coursesBloc = CoursesBloc(mockService);
    });

    tearDown(() {
      coursesBloc.close();
    });

    test('CoursesBloc loads courses and caches results', () async {
      expect(coursesBloc.state, isA<CoursesInitial>());

      coursesBloc.add(const LoadCoursesForGrade(12));
      await expectLater(
        coursesBloc.stream,
        emitsInOrder([
          isA<CoursesLoading>(),
          isA<CoursesLoaded>(),
        ]),
      );

      final state = coursesBloc.state as CoursesLoaded;
      expect(state.courses, isNotEmpty);
      expect(state.gradeLevel, 12);
      expect(coursesBloc.getCachedCourses(12), isNotNull);
    });

    test('CoursesBloc loads course details and handles quiz loading', () async {
      coursesBloc.add(const LoadCourseDetail('course-grade-12-math'));
      await expectLater(
        coursesBloc.stream,
        emitsInOrder([
          isA<CourseDetailLoading>(),
          isA<CourseDetailLoaded>(),
        ]),
      );

      coursesBloc.add(const LoadQuizEvent('quiz-12-unit-1'));
      await expectLater(
        coursesBloc.stream,
        emitsInOrder([
          isA<QuizLoading>(),
          isA<QuizLoaded>(),
        ]),
      );
    });
  });
}

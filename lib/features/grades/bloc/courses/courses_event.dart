part of 'courses_bloc.dart';

abstract class CoursesEvent {
  const CoursesEvent();
}

/// Loads all courses for the student's grade level.
class LoadCoursesForGrade extends CoursesEvent {
  final int gradeLevel;

  const LoadCoursesForGrade(this.gradeLevel);
}

/// Loads full course structure (chapters, topics, lessons) for a selected course.
class LoadCourseDetail extends CoursesEvent {
  final String courseId;

  const LoadCourseDetail(this.courseId);
}

/// Loads full lesson content, objectives, multimedia, and completion status.
class LoadLessonDetail extends CoursesEvent {
  final String lessonId;

  const LoadLessonDetail(this.lessonId);
}

/// Marks a lesson completed via POST /progress/lessons/:lessonId/complete.
class CompleteLessonEvent extends CoursesEvent {
  final String lessonId;

  const CompleteLessonEvent(this.lessonId);
}

/// Loads quiz questions and options via GET /quizzes/:quizId.
class LoadQuizEvent extends CoursesEvent {
  final String quizId;

  const LoadQuizEvent(this.quizId);
}

/// Records a student's answer selection for a specific question.
class SelectQuizOptionEvent extends CoursesEvent {
  final String questionId;
  final String optionId;

  const SelectQuizOptionEvent(this.questionId, this.optionId);
}

/// Submits all recorded answers via POST /quizzes/:quizId/submit.
class SubmitQuizEvent extends CoursesEvent {
  final String quizId;

  const SubmitQuizEvent(this.quizId);
}

/// Loads quiz attempt result and review via GET /quizzes/attempts/:attemptId.
class LoadQuizReviewEvent extends CoursesEvent {
  final String attemptId;

  const LoadQuizReviewEvent(this.attemptId);
}


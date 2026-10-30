import '../models/course_models.dart';
import '../models/quiz_models.dart';

/// Contract defining all operations for Grades Courses, Lessons, and Quizzes.
abstract class CoursesService {
  /// Fetches available courses for a given grade level (e.g. 12, 8, 6).
  Future<List<CourseModel>> getCoursesForGrade(int gradeLevel);

  /// Fetches course details including its full chapter/topic/lesson structure.
  Future<CourseModel> getCourseDetails(String courseId);

  /// Fetches content, multimedia, and status for an individual lesson.
  Future<LessonDetailContentModel> getLessonDetails(String lessonId);

  /// Marks an individual lesson as completed.
  Future<bool> completeLesson(String lessonId);

  /// Fetches quiz questions and options by quiz ID.
  Future<QuizDetailModel> getQuiz(String quizId);

  /// Submits student answers for a quiz attempt.
  Future<QuizSubmissionResponse> submitQuiz(
    String quizId,
    QuizSubmissionRequest request,
  );

  /// Fetches the attempt results, score, and question review.
  Future<QuizAttemptReviewModel> getQuizAttemptReview(String attemptId);
}


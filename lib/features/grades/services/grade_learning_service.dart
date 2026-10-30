import '../../../core/constants/grade_level.dart';
import '../models/chapter_model.dart';
import '../models/quiz_model.dart';
import '../models/subject_model.dart';
import 'courses_service.dart';
import 'mock_courses_service.dart';

/// Service contract providing subjects, chapters, and quizzes for grades 6, 8, and 12.
abstract class GradeLearningService {
  Future<List<SubjectModel>> getSubjectsForGrade(GradeLevel gradeLevel);
  Future<List<ChapterModel>> getChapters(String subjectId);
  Future<QuizModel?> getQuiz(String chapterId);
}

/// Default implementation adapting to [CoursesService].
class DefaultGradeLearningService implements GradeLearningService {
  final CoursesService _coursesService;

  DefaultGradeLearningService({CoursesService? coursesService})
      : _coursesService = coursesService ?? MockCoursesService();

  @override
  Future<List<SubjectModel>> getSubjectsForGrade(GradeLevel gradeLevel) async {
    final courses = await _coursesService.getCoursesForGrade(gradeLevel.numericValue);
    return courses
        .map(
          (c) => SubjectModel(
            id: c.id,
            name: c.title,
            iconAsset: c.icon ?? 'assets/icons/math.svg',
            gradeLevel: gradeLevel,
            totalChapters: c.totalChapters,
            completedChapters: (c.totalChapters * c.progressPercent).round(),
          ),
        )
        .toList();
  }

  @override
  Future<List<ChapterModel>> getChapters(String subjectId) async {
    final course = await _coursesService.getCourseDetails(subjectId);
    return course.chapters
        .map(
          (ch) => ChapterModel(
            id: ch.id,
            subjectId: subjectId,
            chapterNumber: ch.chapterNumber,
            title: ch.title,
            isCompleted: ch.isCompleted,
          ),
        )
        .toList();
  }

  @override
  Future<QuizModel?> getQuiz(String chapterId) async {
    final quiz = await _coursesService.getQuiz(chapterId);
    return QuizModel(
      id: quiz.id,
      chapterId: chapterId,
      title: quiz.title,
      totalQuestions: quiz.totalQuestions,
      timeLimitMinutes: quiz.timeLimitMinutes,
    );
  }
}

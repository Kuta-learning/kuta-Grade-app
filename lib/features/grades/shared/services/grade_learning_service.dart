import '../../../../core/constants/grade_level.dart';
import '../models/chapter_model.dart';
import '../models/quiz_model.dart';
import '../models/subject_model.dart';

/// Service contract providing subjects, chapters, and quizzes for grades 6, 8, and 12.
abstract class GradeLearningService {
  Future<List<SubjectModel>> getSubjectsForGrade(GradeLevel gradeLevel);
  Future<List<ChapterModel>> getChapters(String subjectId);
  Future<QuizModel?> getQuiz(String chapterId);
}

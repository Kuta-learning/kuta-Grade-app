import '../models/course_models.dart';
import '../models/quiz_models.dart';
import 'courses_service.dart';

/// Offline mock implementation providing reliable fallback data for Courses, Lessons, and Quizzes.
class MockCoursesService implements CoursesService {
  @override
  Future<List<CourseModel>> getCoursesForGrade(int gradeLevel) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return [
      CourseModel(
        id: 'course-math-$gradeLevel',
        title: 'Mathematics Grade $gradeLevel',
        description:
            'Comprehensive curriculum covering algebra, calculus, geometry, and real-world applications.',
        gradeLevel: gradeLevel,
        subject: 'Mathematics',
        icon: 'functions_rounded',
        totalChapters: 6,
        totalLessons: 24,
        completedLessons: 12,
        progressPercent: 0.50,
        chapters: _getMockChaptersForCourse('course-math-$gradeLevel'),
      ),
      CourseModel(
        id: 'course-physics-$gradeLevel',
        title: 'Physics Grade $gradeLevel',
        description:
            'Mechanics, thermodynamics, electrodynamics, and atomic physics with conceptual problem solving.',
        gradeLevel: gradeLevel,
        subject: 'Physics',
        icon: 'offline_bolt_outlined',
        totalChapters: 5,
        totalLessons: 20,
        completedLessons: 6,
        progressPercent: 0.30,
        chapters: _getMockChaptersForCourse('course-physics-$gradeLevel'),
      ),
      CourseModel(
        id: 'course-chemistry-$gradeLevel',
        title: 'Chemistry Grade $gradeLevel',
        description:
            'Atomic structure, chemical bonding, stoichiometry, kinetics, and organic reaction pathways.',
        gradeLevel: gradeLevel,
        subject: 'Chemistry',
        icon: 'science_outlined',
        totalChapters: 5,
        totalLessons: 18,
        completedLessons: 9,
        progressPercent: 0.50,
        chapters: _getMockChaptersForCourse('course-chemistry-$gradeLevel'),
      ),
      CourseModel(
        id: 'course-biology-$gradeLevel',
        title: 'Biology Grade $gradeLevel',
        description:
            'Cellular respiration, molecular genetics, ecology, human physiology, and evolution.',
        gradeLevel: gradeLevel,
        subject: 'Biology',
        icon: 'psychology_outlined',
        totalChapters: 6,
        totalLessons: 22,
        completedLessons: 4,
        progressPercent: 0.18,
        chapters: _getMockChaptersForCourse('course-biology-$gradeLevel'),
      ),
      CourseModel(
        id: 'course-english-$gradeLevel',
        title: 'English Grade $gradeLevel',
        description:
            'Academic reading, argumentative essay writing, advanced vocabulary, and listening comprehension.',
        gradeLevel: gradeLevel,
        subject: 'English',
        icon: 'menu_book_rounded',
        totalChapters: 4,
        totalLessons: 16,
        completedLessons: 16,
        progressPercent: 1.0,
        chapters: _getMockChaptersForCourse('course-english-$gradeLevel'),
      ),
    ];
  }

  static List<CourseChapterModel> _getMockChaptersForCourse(String courseId) {
    return [
      CourseChapterModel(
        id: '$courseId-ch-1',
        courseId: courseId,
        chapterNumber: 1,
        title: 'Unit 1: Foundations and Core Principles',
        description: 'Key definitions, conceptual frameworks, and preliminary problem sets.',
        isCompleted: true,
        lessons: [
          CourseLessonItemModel(
            id: 'lesson-1-1',
            chapterId: '$courseId-ch-1',
            lessonNumber: 1,
            title: '1.1 Introduction and Core Principles',
            duration: '15 mins',
            isLocked: false,
            isCompleted: true,
            quizId: 'quiz-1',
          ),
          CourseLessonItemModel(
            id: 'lesson-1-2',
            chapterId: '$courseId-ch-1',
            lessonNumber: 2,
            title: '1.2 Advanced Theoretical Frameworks',
            duration: '20 mins',
            isLocked: false,
            isCompleted: true,
            quizId: 'quiz-1',
          ),
        ],
      ),
      CourseChapterModel(
        id: '$courseId-ch-2',
        courseId: courseId,
        chapterNumber: 2,
        title: 'Unit 2: Analytical Methods & Applications',
        description: 'Systematic derivations, worked examples, and practical calculations.',
        isCompleted: false,
        lessons: [
          CourseLessonItemModel(
            id: 'lesson-2-1',
            chapterId: '$courseId-ch-2',
            lessonNumber: 1,
            title: '2.1 Fundamental Formulas & Proofs',
            duration: '25 mins',
            isLocked: false,
            isCompleted: false,
            quizId: 'quiz-2',
          ),
          CourseLessonItemModel(
            id: 'lesson-2-2',
            chapterId: '$courseId-ch-2',
            lessonNumber: 2,
            title: '2.2 Real-world Contexts & Problem Solving',
            duration: '30 mins',
            isLocked: true,
            isCompleted: false,
            quizId: 'quiz-2',
          ),
        ],
      ),
      CourseChapterModel(
        id: '$courseId-ch-3',
        courseId: courseId,
        chapterNumber: 3,
        title: 'Unit 3: Integrative Assessment & Practice',
        description: 'Comprehensive review problems and unit exam preparation.',
        isCompleted: false,
        lessons: [
          CourseLessonItemModel(
            id: 'lesson-3-1',
            chapterId: '$courseId-ch-3',
            lessonNumber: 1,
            title: '3.1 Synthesizing Concepts Across Units',
            duration: '35 mins',
            isLocked: true,
            isCompleted: false,
            quizId: 'quiz-3',
          ),
        ],
      ),
    ];
  }

  @override
  Future<CourseModel> getCourseDetails(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final chapters = _getMockChaptersForCourse(courseId);
    return CourseModel(
      id: courseId,
      title: 'Mathematics Grade 12',
      description:
          'In-depth study of advanced functions, calculus, vectors, and discrete probability distributions.',
      gradeLevel: 12,
      subject: 'Mathematics',
      icon: 'functions_rounded',
      totalChapters: chapters.length,
      totalLessons: 5,
      completedLessons: 2,
      progressPercent: 0.40,
      chapters: chapters,
    );
  }

  @override
  Future<LessonDetailContentModel> getLessonDetails(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return LessonDetailContentModel(
      id: lessonId,
      title: '1.1 Introduction and Core Principles',
      courseId: 'course-math-12',
      courseTitle: 'Mathematics Grade 12',
      chapterId: 'ch-1',
      chapterTitle: 'Unit 1: Foundations and Core Principles',
      lessonNumber: 1,
      durationMinutes: 15,
      isLocked: false,
      isCompleted: false,
      quizId: 'quiz-1',
      learningObjectives: const [
        'Understand fundamental mathematical relationships and notation.',
        'Apply algebraic manipulations to simplify multi-variable expressions.',
        'Identify practical conditions under which standard limit theorems apply.',
      ],
      content:
          'In this introductory lesson, we examine the axiomatic foundations of functions and mappings. '
          'A relation between two sets is considered a function if each element in the domain corresponds to exactly one element in the range.\n\n'
          'Key Properties of Functions:\n'
          '1. Domain: The set of all permissible input values for which the expression is real and well-defined.\n'
          '2. Codomain and Range: The range consists of the actual set of outputs produced by applying the function to every domain element.\n'
          '3. Continuity: A function f(x) is continuous at x = a if the limit as x approaches a exists, f(a) is defined, and both values are equal.\n\n'
          'Practice and master these definitions before attempting the chapter quiz.',
      resources: const [
        LessonResourceItemModel(
          id: 'res-1',
          title: 'Functions_Core_Principles_Summary.pdf',
          fileType: 'PDF',
          fileSize: '1.8 MB',
          fileUrl: 'https://kuta-learning.onrender.com/api/resources/principles.pdf',
        ),
        LessonResourceItemModel(
          id: 'res-2',
          title: 'Unit1_Practice_Worksheet.pdf',
          fileType: 'PDF',
          fileSize: '950 KB',
          fileUrl: 'https://kuta-learning.onrender.com/api/resources/worksheet.pdf',
        ),
      ],
    );
  }

  @override
  Future<bool> completeLesson(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Future<QuizDetailModel> getQuiz(String quizId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return QuizDetailModel(
      id: quizId,
      title: 'Unit 1 Assessment Quiz',
      description: 'Test your understanding of core concepts and principles from Unit 1.',
      timeLimitMinutes: 15,
      passingScore: 70,
      totalQuestions: 4,
      questions: const [
        QuizQuestionModel(
          id: 'q-1',
          questionText:
              'Which of the following conditions is required for a relation to be classified as a function?',
          explanation:
              'By definition, a relation is a function if and only if each element of the domain maps to exactly one element in the range.',
          points: 1,
          options: [
            QuizQuestionOption(id: 'opt-1-a', optionText: 'Every input produces exactly one unique output', label: 'A'),
            QuizQuestionOption(id: 'opt-1-b', optionText: 'Inputs can produce multiple outputs simultaneously', label: 'B'),
            QuizQuestionOption(id: 'opt-1-c', optionText: 'The range must equal the codomain', label: 'C'),
            QuizQuestionOption(id: 'opt-1-d', optionText: 'The derivative must exist everywhere', label: 'D'),
          ],
        ),
        QuizQuestionModel(
          id: 'q-2',
          questionText:
              'What is the domain of f(x) = √(x - 4)?',
          explanation:
              'For the square root to yield a real number, the radicand x - 4 must be greater than or equal to 0, hence x ≥ 4.',
          points: 1,
          options: [
            QuizQuestionOption(id: 'opt-2-a', optionText: 'x ≥ 4', label: 'A'),
            QuizQuestionOption(id: 'opt-2-b', optionText: 'x > 4', label: 'B'),
            QuizQuestionOption(id: 'opt-2-c', optionText: 'x ≤ 4', label: 'C'),
            QuizQuestionOption(id: 'opt-2-d', optionText: 'All real numbers', label: 'D'),
          ],
        ),
        QuizQuestionModel(
          id: 'q-3',
          questionText:
              'A function f(x) is continuous at x = c if which of the following holds true?',
          explanation:
              'Continuity at a point requires lim x->c f(x) = f(c), which also implies f(c) is defined and the limit exists.',
          points: 1,
          options: [
            QuizQuestionOption(id: 'opt-3-a', optionText: 'lim x->c f(x) = f(c)', label: 'A'),
            QuizQuestionOption(id: 'opt-3-b', optionText: 'f\'(c) = 0', label: 'B'),
            QuizQuestionOption(id: 'opt-3-c', optionText: 'f(c) > 0', label: 'C'),
            QuizQuestionOption(id: 'opt-3-d', optionText: 'f(x) is linear everywhere', label: 'D'),
          ],
        ),
        QuizQuestionModel(
          id: 'q-4',
          questionText:
              'What is the horizontal asymptote of the rational function g(x) = (3x + 2) / (x - 5)?',
          explanation:
              'As x approaches infinity, the ratio of the leading coefficients is 3/1 = 3, so y = 3.',
          points: 1,
          options: [
            QuizQuestionOption(id: 'opt-4-a', optionText: 'y = 3', label: 'A'),
            QuizQuestionOption(id: 'opt-4-b', optionText: 'y = 2', label: 'B'),
            QuizQuestionOption(id: 'opt-4-c', optionText: 'x = 5', label: 'C'),
            QuizQuestionOption(id: 'opt-4-d', optionText: 'y = 0', label: 'D'),
          ],
        ),
      ],
    );
  }

  @override
  Future<QuizSubmissionResponse> submitQuiz(
    String quizId,
    QuizSubmissionRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final total = request.answers.length;
    // Calculate simulated score
    final score = total > 0 ? (total * 0.75).ceil() : 0;
    final percentage = total > 0 ? (score / total) * 100 : 100.0;
    final passed = percentage >= 70.0;

    return QuizSubmissionResponse(
      attemptId: 'attempt-${DateTime.now().millisecondsSinceEpoch}',
      score: score,
      totalScore: total,
      percentage: percentage,
      passed: passed,
      message: passed
          ? 'Congratulations! You passed the quiz.'
          : 'Keep reviewing and try again!',
    );
  }

  @override
  Future<QuizAttemptReviewModel> getQuizAttemptReview(String attemptId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return QuizAttemptReviewModel(
      id: attemptId,
      quizId: 'quiz-1',
      quizTitle: 'Unit 1 Assessment Quiz',
      score: 3,
      totalScore: 4,
      percentage: 75.0,
      passed: true,
      timeSpentSeconds: 420,
      completedAt: 'Just now',
      questions: [
        QuizQuestionReviewItem(
          questionId: 'q-1',
          questionText:
              'Which of the following conditions is required for a relation to be classified as a function?',
          selectedOptionId: 'opt-1-a',
          correctOptionId: 'opt-1-a',
          isCorrect: true,
          explanation:
              'Every input in the domain corresponds to exactly one output in the range.',
          options: [
            QuizQuestionOption(id: 'opt-1-a', optionText: 'Every input produces exactly one unique output', label: 'A'),
            QuizQuestionOption(id: 'opt-1-b', optionText: 'Inputs can produce multiple outputs simultaneously', label: 'B'),
            QuizQuestionOption(id: 'opt-1-c', optionText: 'The range must equal the codomain', label: 'C'),
            QuizQuestionOption(id: 'opt-1-d', optionText: 'The derivative must exist everywhere', label: 'D'),
          ],
        ),
        QuizQuestionReviewItem(
          questionId: 'q-2',
          questionText: 'What is the domain of f(x) = √(x - 4)?',
          selectedOptionId: 'opt-2-a',
          correctOptionId: 'opt-2-a',
          isCorrect: true,
          explanation: 'x - 4 ≥ 0 entails x ≥ 4 for real values.',
          options: [
            QuizQuestionOption(id: 'opt-2-a', optionText: 'x ≥ 4', label: 'A'),
            QuizQuestionOption(id: 'opt-2-b', optionText: 'x > 4', label: 'B'),
            QuizQuestionOption(id: 'opt-2-c', optionText: 'x ≤ 4', label: 'C'),
            QuizQuestionOption(id: 'opt-2-d', optionText: 'All real numbers', label: 'D'),
          ],
        ),
        QuizQuestionReviewItem(
          questionId: 'q-3',
          questionText:
              'A function f(x) is continuous at x = c if which of the following holds true?',
          selectedOptionId: 'opt-3-a',
          correctOptionId: 'opt-3-a',
          isCorrect: true,
          explanation: 'lim x->c f(x) must equal the evaluated value f(c).',
          options: [
            QuizQuestionOption(id: 'opt-3-a', optionText: 'lim x->c f(x) = f(c)', label: 'A'),
            QuizQuestionOption(id: 'opt-3-b', optionText: 'f\'(c) = 0', label: 'B'),
            QuizQuestionOption(id: 'opt-3-c', optionText: 'f(c) > 0', label: 'C'),
            QuizQuestionOption(id: 'opt-3-d', optionText: 'f(x) is linear everywhere', label: 'D'),
          ],
        ),
        QuizQuestionReviewItem(
          questionId: 'q-4',
          questionText:
              'What is the horizontal asymptote of the rational function g(x) = (3x + 2) / (x - 5)?',
          selectedOptionId: 'opt-4-c',
          correctOptionId: 'opt-4-a',
          isCorrect: false,
          explanation:
              'The horizontal asymptote is found from leading coefficients 3/1 = 3 (y = 3). x = 5 is the vertical asymptote.',
          options: [
            QuizQuestionOption(id: 'opt-4-a', optionText: 'y = 3', label: 'A'),
            QuizQuestionOption(id: 'opt-4-b', optionText: 'y = 2', label: 'B'),
            QuizQuestionOption(id: 'opt-4-c', optionText: 'x = 5', label: 'C'),
            QuizQuestionOption(id: 'opt-4-d', optionText: 'y = 0', label: 'D'),
          ],
        ),
      ],
    );
  }
}


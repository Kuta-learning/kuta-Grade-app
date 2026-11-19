import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/course_models.dart';
import '../models/quiz_models.dart';
import 'courses_service.dart';

/// Real REST API client for Grades Courses, Lessons, and Quizzes.
/// All data comes exclusively from the backend. No mock fallback.
///
/// Endpoints:
/// 1. GET  /courses?gradeLevel=:gradeLevel
/// 2. GET  /courses/:courseId
/// 3. GET  /lessons/:lessonId
/// 4. POST /progress/lessons/:lessonId/complete
/// 5. GET  /quizzes/:quizId
/// 6. POST /quizzes/:quizId/submit
/// 7. GET  /quizzes/attempts/:attemptId
class ApiCoursesService implements CoursesService {
  final ApiClient _apiClient;

  ApiCoursesService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<CourseModel>> getCoursesForGrade(int gradeLevel) async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.coursesByGrade(gradeLevel),
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data;
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic>) {
          if (data['courses'] is List) {
            list = data['courses'] as List<dynamic>;
          } else if (data['data'] is List) {
            list = data['data'] as List<dynamic>;
          }
        }
        return list
            .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
            .where((c) => c.gradeLevel == gradeLevel)
            .toList();
      }
      throw Exception('Failed to load courses: unexpected response format');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to load courses');
    }
  }

  @override
  Future<CourseModel> getCourseDetails(String courseId) async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.courseDetail(courseId),
      );

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic>? courseMap;
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          if (map['course'] is Map<String, dynamic>) {
            courseMap = map['course'] as Map<String, dynamic>;
          } else if (map['data'] is Map<String, dynamic>) {
            courseMap = map['data'] as Map<String, dynamic>;
          } else {
            courseMap = map;
          }
        }
        if (courseMap != null) return CourseModel.fromJson(courseMap);
      }
      throw Exception('Failed to load course details');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to load course details');
    }
  }

  @override
  Future<LessonDetailContentModel> getLessonDetails(String lessonId) async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.lessonView(lessonId),
      );

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic>? lessonMap;
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          if (map['lesson'] is Map<String, dynamic>) {
            lessonMap = map['lesson'] as Map<String, dynamic>;
          } else if (map['data'] is Map<String, dynamic>) {
            lessonMap = map['data'] as Map<String, dynamic>;
          } else {
            lessonMap = map;
          }
        }
        if (lessonMap != null) return LessonDetailContentModel.fromJson(lessonMap);
      }
      throw Exception('Failed to load lesson');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to load lesson');
    }
  }

  @override
  Future<bool> completeLesson(String lessonId) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.completeLesson(lessonId),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to mark lesson complete');
    }
  }

  @override
  Future<QuizDetailModel> getQuiz(String quizId) async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.quizDetail(quizId),
      );

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic>? quizMap;
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          if (map['quiz'] is Map<String, dynamic>) {
            quizMap = map['quiz'] as Map<String, dynamic>;
          } else if (map['data'] is Map<String, dynamic>) {
            quizMap = map['data'] as Map<String, dynamic>;
          } else {
            quizMap = map;
          }
        }
        if (quizMap != null) return QuizDetailModel.fromJson(quizMap);
      }
      throw Exception('Failed to load quiz');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to load quiz');
    }
  }

  @override
  Future<QuizSubmissionResponse> submitQuiz(
    String quizId,
    QuizSubmissionRequest request,
  ) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.submitQuiz(quizId),
        data: request.toJson(),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        Map<String, dynamic>? resultMap;
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          if (map['attempt'] is Map<String, dynamic>) {
            resultMap = map['attempt'] as Map<String, dynamic>;
          } else if (map['data'] is Map<String, dynamic>) {
            resultMap = map['data'] as Map<String, dynamic>;
          } else {
            resultMap = map;
          }
        }
        if (resultMap != null) return QuizSubmissionResponse.fromJson(resultMap);
      }
      throw Exception('Failed to submit quiz');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to submit quiz');
    }
  }

  @override
  Future<QuizAttemptReviewModel> getQuizAttemptReview(String attemptId) async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.quizAttemptReview(attemptId),
      );

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic>? reviewMap;
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          if (map['attempt'] is Map<String, dynamic>) {
            reviewMap = map['attempt'] as Map<String, dynamic>;
          } else if (map['data'] is Map<String, dynamic>) {
            reviewMap = map['data'] as Map<String, dynamic>;
          } else {
            reviewMap = map;
          }
        }
        if (reviewMap != null) return QuizAttemptReviewModel.fromJson(reviewMap);
      }
      throw Exception('Failed to load quiz review');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to load quiz review');
    }
  }
}

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/course_models.dart';
import '../models/quiz_models.dart';
import 'courses_service.dart';
import 'mock_courses_service.dart';

/// Real REST API client implementation for Grades Courses, Lessons, and Quizzes.
/// Implements all 7 backend endpoints with resilient fallback to [MockCoursesService]:
/// 1. GET  /courses?gradeLevel=:gradeLevel
/// 2. GET  /courses/:courseId
/// 3. GET  /lessons/:lessonId
/// 4. POST /progress/lessons/:lessonId/complete
/// 5. GET  /quizzes/:quizId
/// 6. POST /quizzes/:quizId/submit
/// 7. GET  /quizzes/attempts/:attemptId
class ApiCoursesService implements CoursesService {
  final ApiClient _apiClient;
  final MockCoursesService _mockFallback;

  ApiCoursesService({
    ApiClient? apiClient,
    MockCoursesService? mockFallback,
  })  : _apiClient = apiClient ?? ApiClient(),
        _mockFallback = mockFallback ?? MockCoursesService();

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

        if (list.isNotEmpty) {
          return list
              .map((item) => CourseModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return _mockFallback.getCoursesForGrade(gradeLevel);
    } on DioException catch (_) {
      return _mockFallback.getCoursesForGrade(gradeLevel);
    } catch (_) {
      return _mockFallback.getCoursesForGrade(gradeLevel);
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

        if (courseMap != null) {
          return CourseModel.fromJson(courseMap);
        }
      }
      return _mockFallback.getCourseDetails(courseId);
    } on DioException catch (_) {
      return _mockFallback.getCourseDetails(courseId);
    } catch (_) {
      return _mockFallback.getCourseDetails(courseId);
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

        if (lessonMap != null) {
          return LessonDetailContentModel.fromJson(lessonMap);
        }
      }
      return _mockFallback.getLessonDetails(lessonId);
    } on DioException catch (_) {
      return _mockFallback.getLessonDetails(lessonId);
    } catch (_) {
      return _mockFallback.getLessonDetails(lessonId);
    }
  }

  @override
  Future<bool> completeLesson(String lessonId) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.completeLesson(lessonId),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return _mockFallback.completeLesson(lessonId);
    } on DioException catch (_) {
      return _mockFallback.completeLesson(lessonId);
    } catch (_) {
      return _mockFallback.completeLesson(lessonId);
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

        if (quizMap != null) {
          return QuizDetailModel.fromJson(quizMap);
        }
      }
      return _mockFallback.getQuiz(quizId);
    } on DioException catch (_) {
      return _mockFallback.getQuiz(quizId);
    } catch (_) {
      return _mockFallback.getQuiz(quizId);
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

        if (resultMap != null) {
          return QuizSubmissionResponse.fromJson(resultMap);
        }
      }
      return _mockFallback.submitQuiz(quizId, request);
    } on DioException catch (_) {
      return _mockFallback.submitQuiz(quizId, request);
    } catch (_) {
      return _mockFallback.submitQuiz(quizId, request);
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

        if (reviewMap != null) {
          return QuizAttemptReviewModel.fromJson(reviewMap);
        }
      }
      return _mockFallback.getQuizAttemptReview(attemptId);
    } on DioException catch (_) {
      return _mockFallback.getQuizAttemptReview(attemptId);
    } catch (_) {
      return _mockFallback.getQuizAttemptReview(attemptId);
    }
  }
}


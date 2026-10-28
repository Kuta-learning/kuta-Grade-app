import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/national_exam_dashboard_model.dart';
import '../models/national_exam_models.dart';

/// Central service for all National Exam Simulator backend integrations.
/// Supports Dashboard, Subjects with Progress, Papers, Starting, Autosaving,
/// Submitting, and Attempt Review.
class NationalExamService {
  final ApiClient _apiClient;

  NationalExamService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// 1. GET /national-exams/dashboard
  /// Fetches the banner exam, student grade/stream, and subject cards with completion stats.
  Future<NationalExamDashboardModel> getDashboard() async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.nationalExamsDashboard,
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic>) {
        return NationalExamDashboardModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Unexpected response format from exam dashboard');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to load exam dashboard');
    }
  }

  /// 2. GET /national-exams/subjects
  /// Fetches subjects list with total exams, completed exams, accuracy %, and progress %.
  Future<List<NationalExamSubjectModel>> getSubjects() async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.nationalExamsSubjects,
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) =>
                NationalExamSubjectModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to load exam subjects');
    }
  }

  /// 3. GET /national-exams/subjects/{subjectId}/exams?order=desc
  /// Fetches official papers with status (NOT_STARTED, IN_PROGRESS, SUBMITTED) and latest score.
  Future<List<ExamPaperItem>> getExamsForSubject(
    String subjectId, {
    String order = 'desc',
  }) async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.nationalExamsBySubject(subjectId),
        queryParameters: {'order': order},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];
        if (data is Map<String, dynamic> && data['exams'] is List) {
          list = data['exams'] as List<dynamic>;
        } else if (data is List) {
          list = data;
        }
        return list
            .map((item) => ExamPaperItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to load exams for subject');
    }
  }

  /// 4. POST /national-exams/{examId}/start
  /// Starts exam timer and returns sanitized questions and saved progress.
  Future<ExamAttempt> startExamAttempt(String examId) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.startExam(examId),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        return ExamAttempt.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to start exam attempt');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to start exam');
    }
  }

  /// 5. PUT /national-exams/attempts/{attemptId}/save-progress
  /// Autosaves student choices and countdown timer.
  Future<bool> saveExamProgress(
    String attemptId, {
    required int timeRemainingSeconds,
    required List<ExamAnswerSubmission> answers,
  }) async {
    try {
      final payload = {
        'timeRemainingSeconds': timeRemainingSeconds,
        'answers': answers.map((a) => a.toJson()).toList(),
      };
      final response = await _apiClient.client.put(
        ApiEndpoints.saveExamProgress(attemptId),
        data: payload,
      );
      return response.statusCode == 200;
    } on DioException catch (_) {
      return false;
    }
  }

  /// 6. POST /national-exams/attempts/{attemptId}/submit
  /// Server-side grading, accuracy calculation, and timer validation.
  Future<ExamResultReview> submitExamAttempt(
    String attemptId, {
    required List<ExamAnswerSubmission> answers,
  }) async {
    try {
      final payload = {
        'answers': answers.map((a) => a.toJson()).toList(),
      };
      final response = await _apiClient.client.post(
        ApiEndpoints.submitExam(attemptId),
        data: payload,
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic>) {
        return ExamResultReview.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to submit exam attempt');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to submit exam');
    }
  }

  /// 7. GET /national-exams/attempts/{attemptId}
  /// Returns score, accuracy, and question review with explanations.
  Future<ExamResultReview> getExamAttemptResult(String attemptId) async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.examAttemptResult(attemptId),
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic>) {
        return ExamResultReview.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch exam results');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to load exam result');
    }
  }
}

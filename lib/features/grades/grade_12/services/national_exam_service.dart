import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/national_exam_dashboard_model.dart';

/// Service responsible for fetching live National Exams and Exam Simulator feeds.
class NationalExamService {
  final ApiClient _apiClient;

  NationalExamService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches the live exam dashboard for Grade 12 students.
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
      throw Exception('Unexpected response format from dashboard API');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to load exam dashboard');
    }
  }
}

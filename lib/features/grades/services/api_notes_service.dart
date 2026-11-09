import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/note_models.dart';
import 'notes_service.dart';

/// Live REST API client for Short Notes & Lessons.
/// All data comes exclusively from the backend. No mock fallback.
///
/// Endpoints:
/// 1. GET  /short-notes/subjects
/// 2. GET  /short-notes/subjects/:subjectId
/// 3. GET  /short-notes/chapters/:chapterId
/// 4. POST /short-notes/chapters/:chapterId/progress
/// 5. GET  /short-notes/chapters/:chapterId/download
class ApiNotesService implements NotesService {
  final ApiClient _apiClient;

  ApiNotesService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<NoteSubjectItem>> getShortNotesSubjects() async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.shortNotesSubjects,
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data;
        List<dynamic> list = [];
        int? studentGrade;
        String? curriculumType;
        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic>) {
          studentGrade = (data['studentGrade'] as num?)?.toInt();
          curriculumType = data['curriculumType'] as String?;
          if (data['data'] is List) {
            list = data['data'] as List<dynamic>;
          } else if (data['subjects'] is List) {
            list = data['subjects'] as List<dynamic>;
          }
        }
        return list
            .map((item) => NoteSubjectItem.fromJson(
                  item as Map<String, dynamic>,
                  parentStudentGrade: studentGrade,
                  parentCurriculumType: curriculumType,
                ))
            .toList();
      }
      throw Exception('Failed to load notes subjects');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to load notes subjects');
    }
  }

  @override
  Future<SubjectNotesDetail> getSubjectNotesDetails(String subjectId) async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.shortNotesSubjectDetail(subjectId),
      );

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic>? itemMap;
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          if (map['data'] is Map<String, dynamic>) {
            itemMap = map['data'] as Map<String, dynamic>;
          } else {
            itemMap = map;
          }
        }
        if (itemMap != null) return SubjectNotesDetail.fromJson(itemMap);
      }
      throw Exception('Failed to load subject notes');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to load subject notes');
    }
  }

  @override
  Future<LessonDetail> getChapterNoteDetail(String chapterId) async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.chapterLessonDetail(chapterId),
      );

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic>? itemMap;
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          if (map['data'] is Map<String, dynamic>) {
            itemMap = map['data'] as Map<String, dynamic>;
          } else if (map['chapter'] is Map<String, dynamic>) {
            itemMap = map['chapter'] as Map<String, dynamic>;
          } else {
            itemMap = map;
          }
        }
        if (itemMap != null) return LessonDetail.fromJson(itemMap);
      }
      throw Exception('Failed to load chapter content');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to load chapter content');
    }
  }

  @override
  Future<void> updateChapterReadingProgress(
    String chapterId, {
    required bool isRead,
  }) async {
    try {
      await _apiClient.client.post(
        ApiEndpoints.chapterReadingProgress(chapterId),
        data: {'isRead': isRead},
      );
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to update reading progress');
    }
  }

  @override
  Future<String> downloadChapterPdf(String chapterId) async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.downloadChapterPdf(chapterId),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          if (map['downloadUrl'] is String) return map['downloadUrl'] as String;
          if (map['url'] is String) return map['url'] as String;
          if (map['data'] is Map<String, dynamic>) {
            final dataMap = map['data'] as Map<String, dynamic>;
            if (dataMap['downloadUrl'] is String) return dataMap['downloadUrl'] as String;
            if (dataMap['url'] is String) return dataMap['url'] as String;
          }
        }
      }
      throw Exception('PDF download URL not available');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Failed to download PDF');
    }
  }
}

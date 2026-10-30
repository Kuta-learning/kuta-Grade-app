import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/note_models.dart';
import 'mock_notes_service.dart';
import 'notes_service.dart';

/// Live REST API client for Short Notes & Lessons with resilient mock fallback.
/// Implements all five Short Notes endpoints specified in the API documentation:
/// 1. GET  /short-notes/subjects
/// 2. GET  /short-notes/subjects/:subjectId
/// 3. GET  /short-notes/chapters/:chapterId
/// 4. POST /short-notes/chapters/:chapterId/progress
/// 5. GET  /short-notes/chapters/:chapterId/download
class ApiNotesService implements NotesService {
  final ApiClient _apiClient;
  final MockNotesService _mockFallback;

  ApiNotesService({
    ApiClient? apiClient,
    MockNotesService? mockFallback,
  })  : _apiClient = apiClient ?? ApiClient(),
        _mockFallback = mockFallback ?? MockNotesService();

  @override
  Future<List<NoteSubjectItem>> getShortNotesSubjects() async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.shortNotesSubjects,
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data;
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            list = data['data'] as List<dynamic>;
          } else if (data['subjects'] is List) {
            list = data['subjects'] as List<dynamic>;
          }
        }

        if (list.isNotEmpty) {
          return list
              .map((item) =>
                  NoteSubjectItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return _mockFallback.getShortNotesSubjects();
    } on DioException catch (_) {
      // Offline / not-yet-seeded endpoint fallback
      return _mockFallback.getShortNotesSubjects();
    } catch (_) {
      return _mockFallback.getShortNotesSubjects();
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
          itemMap = map;
          if (map['data'] is Map<String, dynamic>) {
            itemMap = map['data'] as Map<String, dynamic>;
          }
        }

        if (itemMap != null) {
          final detail = SubjectNotesDetail.fromJson(itemMap);
          if (detail.chapters.isNotEmpty) {
            return detail;
          }
        }
      }
      return _mockFallback.getSubjectNotesDetails(subjectId);
    } on DioException catch (_) {
      return _mockFallback.getSubjectNotesDetails(subjectId);
    } catch (_) {
      return _mockFallback.getSubjectNotesDetails(subjectId);
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

        if (itemMap != null) {
          return LessonDetail.fromJson(itemMap);
        }
      }
      return _mockFallback.getChapterNoteDetail(chapterId);
    } on DioException catch (_) {
      return _mockFallback.getChapterNoteDetail(chapterId);
    } catch (_) {
      return _mockFallback.getChapterNoteDetail(chapterId);
    }
  }

  @override
  Future<void> updateChapterReadingProgress(
    String chapterId, {
    required bool isRead,
  }) async {
    try {
      // POST /short-notes/chapters/:chapterId/progress with {"isRead": true}
      await _apiClient.client.post(
        ApiEndpoints.chapterReadingProgress(chapterId),
        data: {'isRead': isRead},
      );
    } catch (_) {
      await _mockFallback.updateChapterReadingProgress(
        chapterId,
        isRead: isRead,
      );
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
            if (dataMap['downloadUrl'] is String) {
              return dataMap['downloadUrl'] as String;
            }
            if (dataMap['url'] is String) return dataMap['url'] as String;
          }
        }
      }
      return _mockFallback.downloadChapterPdf(chapterId);
    } catch (_) {
      return _mockFallback.downloadChapterPdf(chapterId);
    }
  }
}

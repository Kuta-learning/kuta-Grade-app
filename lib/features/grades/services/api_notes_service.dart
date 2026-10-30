import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/note_models.dart';
import 'mock_notes_service.dart';
import 'notes_service.dart';

/// Live REST API client for Short Notes & Lessons with resilient mock fallback.
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
        } else if (data is Map<String, dynamic> && data['subjects'] is List) {
          list = data['subjects'] as List<dynamic>;
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

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic>) {
        return SubjectNotesDetail.fromJson(
          response.data as Map<String, dynamic>,
        );
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

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic>) {
        return LessonDetail.fromJson(
          response.data as Map<String, dynamic>,
        );
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
      await _apiClient.client.put(
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
        if (response.data is Map<String, dynamic> &&
            response.data['downloadUrl'] != null) {
          return response.data['downloadUrl'] as String;
        }
      }
      return _mockFallback.downloadChapterPdf(chapterId);
    } catch (_) {
      return _mockFallback.downloadChapterPdf(chapterId);
    }
  }
}


import 'dart:async';
import 'package:dio/dio.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/cache/cache_response.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/bookmark_model.dart';

/// Service interfacing with the Bookmarks backend endpoints with SWR caching.
///
/// Features:
/// - 1-minute TTL with [CacheManager.watch] (instant offline/memory load + silent revalidation).
/// - Bookmark toggle with cache synchronization.
/// - Single-item bookmark status checker.
class BookmarkService {
  final ApiClient _apiClient;
  final CacheManager _cacheManager;

  BookmarkService({
    ApiClient? apiClient,
    CacheManager? cacheManager,
  })  : _apiClient = apiClient ?? ApiClient(),
        _cacheManager = cacheManager ?? CacheManager.instance;

  /// Fetches bookmarks from the live REST API.
  Future<List<BookmarkItem>> getBookmarks({
    String? type,
    String? subjectId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (subjectId != null && subjectId.isNotEmpty) {
        queryParams['subjectId'] = subjectId;
      }

      final response = await _apiClient.client.get(
        ApiEndpoints.bookmarks,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data;
        List<dynamic> list = [];
        if (data is Map<String, dynamic> && data['bookmarks'] is List) {
          list = data['bookmarks'] as List<dynamic>;
        } else if (data is List) {
          list = data;
        }

        return list
            .map((item) =>
                BookmarkItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (dioErr) {
      final serverMsg = dioErr.response?.data is Map
          ? (dioErr.response!.data as Map)['message']
          : null;
      throw Exception(
          serverMsg ?? dioErr.message ?? 'Failed to fetch bookmarks');
    } catch (e) {
      throw Exception('Failed to fetch bookmarks: $e');
    }
  }

  /// Streams bookmarks using [CacheManager] with 1-minute Stale-While-Revalidate TTL.
  /// Emits cached bookmarks instantly (L1/L2), then silently refreshes in background if older than 1 minute.
  Stream<CacheResponse<List<BookmarkItem>>> streamBookmarks({
    String? type,
    Duration maxStale = const Duration(minutes: 1),
    bool forceRefresh = false,
  }) {
    final cacheKey = type != null && type.isNotEmpty
        ? '${StorageKeys.bookmarksCache}_$type'
        : StorageKeys.bookmarksCache;

    return _cacheManager.watch<List<BookmarkItem>>(
      key: cacheKey,
      ttl: maxStale,
      forceRefresh: forceRefresh,
      networkFetch: () => getBookmarks(type: type),
      fromJson: BookmarkItem.decodeList,
      toJson: BookmarkItem.encodeList,
    );
  }

  /// Toggles bookmark state for an item.
  /// If not bookmarked -> creates it. If already bookmarked -> removes it.
  Future<BookmarkToggleResponse> toggleBookmark({
    required String type,
    required String itemId,
    required String title,
    String? subjectId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final payload = <String, dynamic>{
        'type': type,
        'itemId': itemId,
        'title': title,
        'subjectId': ?subjectId,
        'metadata': ?metadata,
      };

      final response = await _apiClient.client.post(
        ApiEndpoints.bookmarkToggle,
        data: payload,
      );

      if (response.data != null && response.data is Map<String, dynamic>) {
        final toggleResult = BookmarkToggleResponse.fromJson(
            response.data as Map<String, dynamic>);

        // Invalidate bookmark caches so subsequent reads or screens fetch fresh data
        await _cacheManager.invalidate(StorageKeys.bookmarksCache);
        if (type.isNotEmpty) {
          await _cacheManager
              .invalidate('${StorageKeys.bookmarksCache}_$type');
        }

        return toggleResult;
      }
      throw Exception('Unexpected response format when toggling bookmark');
    } on DioException catch (dioErr) {
      final serverMsg = dioErr.response?.data is Map
          ? (dioErr.response!.data as Map)['message']
          : null;
      throw Exception(
          serverMsg ?? dioErr.message ?? 'Failed to toggle bookmark');
    } catch (e) {
      throw Exception('Failed to toggle bookmark: $e');
    }
  }

  /// Checks whether a specific item is bookmarked by the student.
  Future<bool> checkBookmarkStatus({
    required String type,
    required String itemId,
  }) async {
    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.bookmarkCheck,
        queryParameters: {
          'type': type,
          'itemId': itemId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['isBookmarked'] as bool? ?? false;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Deletes a bookmark using its bookmark ID.
  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      await _apiClient.client.delete(ApiEndpoints.bookmarkById(bookmarkId));
      await _cacheManager.invalidate(StorageKeys.bookmarksCache);
    } on DioException catch (dioErr) {
      final serverMsg = dioErr.response?.data is Map
          ? (dioErr.response!.data as Map)['message']
          : null;
      throw Exception(
          serverMsg ?? dioErr.message ?? 'Failed to delete bookmark');
    } catch (e) {
      throw Exception('Failed to delete bookmark: $e');
    }
  }
}

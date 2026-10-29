import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/shared_prefs_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/profile_model.dart';
import 'profile_service.dart';

/// Real HTTP-backed [ProfileService] communicating with the Kuta Learning Render API.
/// Mirrors [ApiAuthService]: live fetch with cached fallback and typed errors.
class ApiProfileService implements ProfileService {
  final ApiClient _apiClient;
  final SharedPrefsStorage _storage;

  ApiProfileService({
    required ApiClient apiClient,
    required SharedPrefsStorage storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  @override
  Future<ProfileModel> getCurrentProfile() async {
    final token = await _storage.getString(StorageKeys.authToken);
    if (token == null || token.isEmpty) {
      return _loadCachedProfile();
    }

    try {
      final response = await _apiClient.client.get(ApiEndpoints.me);
      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final userMap = data['profile'] ?? data['user'] ?? data;
        final profile = ProfileModel.fromJson(userMap as Map<String, dynamic>);

        // Refresh the local cache
        await _cacheProfile(profile);
        return profile;
      }
      return await _loadCachedProfile();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Session expired: drop local profile data; session cleanup is owned
        // by AuthBloc (mirrors ApiAuthService behavior on 401).
        await clearCache();
        throw const ProfileException(
          'Your session has expired. Please log in again.',
          code: 'unauthorized',
        );
      }

      // Network/timeout errors: fall back to the cached profile.
      return _loadCachedProfile();
    } catch (_) {
      return _loadCachedProfile();
    }
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final response = await _apiClient.client.put(
        ApiEndpoints.profile,
        data: {
          'name': profile.fullName.trim(),
          if (profile.avatarUrl != null) 'avatarUrl': profile.avatarUrl,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final profileMap = data['profile'] ?? data['user'] ?? data;
      final updated = ProfileModel.fromJson(profileMap as Map<String, dynamic>);

      await _cacheProfile(updated);
      return updated;
    } on DioException catch (e) {
      final message =
          _extractErrorMessage(e) ?? 'Failed to update your profile.';
      throw ProfileException(message, code: 'profile_update_failed');
    } catch (e) {
      throw ProfileException(
        e is ProfileException ? e.message : 'An unexpected error occurred.',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    await _storage.remove(StorageKeys.profileCache);
  }

  // ── Cache helpers ─────────────────────────────────────────────────────────

  Future<ProfileModel> _loadCachedProfile() async {
    final raw = await _storage.getString(StorageKeys.profileCache);
    final cached = ProfileModel.fromJsonString(raw);
    if (cached != null) return cached;
    throw const ProfileException(
      'Profile unavailable. Please check your connection and try again.',
      code: 'profile_unavailable',
    );
  }

  Future<void> _cacheProfile(ProfileModel profile) async {
    await _storage.setString(StorageKeys.profileCache, profile.toJsonString());
  }

  // ── Error Extraction Helper (mirrors ApiAuthService) ──────────────────────
  String? _extractErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connection timed out. Please check your internet connection.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot reach the server. Please check your internet connection.';
    }

    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message'] ?? data['error'];
      if (msg is String && msg.isNotEmpty) {
        return msg;
      }
      if (msg is List && msg.isNotEmpty) {
        return msg.first.toString();
      }
    }

    return e.response?.statusMessage;
  }
}

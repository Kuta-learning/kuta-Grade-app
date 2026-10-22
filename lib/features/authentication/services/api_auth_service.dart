import 'package:dio/dio.dart';
import '../../../core/constants/academic_stream.dart';
import '../../../core/constants/grade_level.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/shared_prefs_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/auth_response.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

/// Real HTTP-backed [AuthService] communicating with the Kuta Learning Render API.
/// Handles authentication, automatic token storage, and session lifecycle.
class ApiAuthService implements AuthService {
  final ApiClient _apiClient;
  final SharedPrefsStorage _storage;

  ApiAuthService({
    required ApiClient apiClient,
    required SharedPrefsStorage storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = await _storage.getString(StorageKeys.authToken);
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await _apiClient.client.get(ApiEndpoints.me);
      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final userMap = data['profile'] ?? data['user'] ?? data;
        final user = UserModel.fromJson(userMap as Map<String, dynamic>);

        // Update local cache
        await _storage.setString(StorageKeys.authUser, user.toJsonString());
        await _storage.setBool(
          StorageKeys.hasSelectedGrade,
          value: user.onboardingCompleted,
        );
        return user;
      }
    } on DioException catch (e) {
      // If 401 Unauthorized, token has expired and cannot be refreshed -> clear session
      if (e.response?.statusCode == 401) {
        await logout();
        return null;
      }

      // For network connection errors/timeouts, fall back to cached local user if available
      final cachedRaw = await _storage.getString(StorageKeys.authUser);
      if (cachedRaw != null && cachedRaw.isNotEmpty) {
        return UserModel.fromJsonString(cachedRaw);
      }
    } catch (_) {
      // Fallback to local storage on unexpected parsing failure
      final cachedRaw = await _storage.getString(StorageKeys.authUser);
      if (cachedRaw != null && cachedRaw.isNotEmpty) {
        return UserModel.fromJsonString(cachedRaw);
      }
    }

    return null;
  }

  @override
  Future<UserModel> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.register,
        data: {
          'name': request.name.trim(),
          'email': request.email.trim(),
          'password': request.password,
        },
      );

      final authResponse =
          AuthResponse.fromJson(response.data as Map<String, dynamic>);

      // Persist access and refresh tokens
      await _storage.setString(StorageKeys.authToken, authResponse.token);
      if (authResponse.refreshToken != null) {
        await _storage.setString(
          StorageKeys.authRefreshToken,
          authResponse.refreshToken!,
        );
      }

      // Persist user session & mark grade selection as pending
      await _storage.setString(
        StorageKeys.authUser,
        authResponse.user.toJsonString(),
      );
      await _storage.setBool(StorageKeys.hasSelectedGrade, value: false);

      return authResponse.user;
    } on DioException catch (e) {
      final message =
          _extractErrorMessage(e) ?? 'Registration failed. Please try again.';
      throw AuthException(message, code: 'registration_failed');
    } catch (e) {
      throw AuthException(
        e is AuthException ? e.message : 'An unexpected error occurred.',
      );
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.login,
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final authResponse =
          AuthResponse.fromJson(response.data as Map<String, dynamic>);

      // Persist access and refresh tokens
      await _storage.setString(StorageKeys.authToken, authResponse.token);
      if (authResponse.refreshToken != null) {
        await _storage.setString(
          StorageKeys.authRefreshToken,
          authResponse.refreshToken!,
        );
      }

      // Persist user and sync grade onboarding state
      final user = authResponse.user;
      await _storage.setString(StorageKeys.authUser, user.toJsonString());
      await _storage.setBool(
        StorageKeys.hasSelectedGrade,
        value: user.onboardingCompleted,
      );

      return user;
    } on DioException catch (e) {
      final message =
          _extractErrorMessage(e) ?? 'Invalid email or password.';
      throw AuthException(message, code: 'login_failed');
    } catch (e) {
      throw AuthException(
        e is AuthException ? e.message : 'An unexpected error occurred.',
      );
    }
  }

  @override
  Future<UserModel> updateAcademicProfile({
    required GradeLevel gradeLevel,
    AcademicStream? stream,
  }) async {
    try {
      final payload = <String, dynamic>{
        'gradeLevel': gradeLevel.numericValue,
        if (stream != null) 'stream': stream.name.toUpperCase(),
      };

      final response = await _apiClient.client.post(
        ApiEndpoints.onboarding,
        data: payload,
      );

      final data = response.data as Map<String, dynamic>;
      final profile = data['profile'] ?? data['user'] ?? data;
      final updatedUser =
          UserModel.fromJson(profile as Map<String, dynamic>);

      // Cache updated user and mark onboarding as complete
      await _storage.setString(
        StorageKeys.authUser,
        updatedUser.toJsonString(),
      );
      await _storage.setBool(StorageKeys.hasSelectedGrade, value: true);

      return updatedUser;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ??
          'Failed to update academic profile. Please try again.';
      throw AuthException(message, code: 'onboarding_failed');
    } catch (e) {
      throw AuthException(
        e is AuthException ? e.message : 'An unexpected error occurred.',
      );
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiClient.client.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email.trim()},
      );
    } on DioException catch (e) {
      final message =
          _extractErrorMessage(e) ?? 'Failed to send verification code.';
      throw AuthException(message, code: 'forgot_password_failed');
    } catch (e) {
      throw AuthException(
        e is AuthException ? e.message : 'An unexpected error occurred.',
      );
    }
  }

  @override
  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.client.post(
        ApiEndpoints.verifyOtp,
        data: {
          'email': email.trim(),
          'otp': otp.trim(),
          'type': 'FORGOT_PASSWORD',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final resetToken = data['resetToken'] as String?;
      if (resetToken == null || resetToken.isEmpty) {
        throw const AuthException(
          'Verification failed: missing reset token.',
          code: 'invalid_reset_token',
        );
      }
      return resetToken;
    } on DioException catch (e) {
      final message =
          _extractErrorMessage(e) ?? 'Invalid or expired verification code.';
      throw AuthException(message, code: 'verify_otp_failed');
    } catch (e) {
      throw AuthException(
        e is AuthException ? e.message : 'An unexpected error occurred.',
      );
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      await _apiClient.client.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email.trim(),
          'resetToken': resetToken,
          'password': newPassword,
        },
      );
    } on DioException catch (e) {
      final message =
          _extractErrorMessage(e) ?? 'Failed to reset password. Please try again.';
      throw AuthException(message, code: 'reset_password_failed');
    } catch (e) {
      throw AuthException(
        e is AuthException ? e.message : 'An unexpected error occurred.',
      );
    }
  }

  @override
  Future<void> logout() async {
    await _storage.remove(StorageKeys.authToken);
    await _storage.remove(StorageKeys.authRefreshToken);
    await _storage.remove(StorageKeys.authUser);
    await _storage.remove(StorageKeys.hasSelectedGrade);
    await _storage.remove(StorageKeys.hasSeenWelcomeSnackbar);
  }

  // ── Error Extraction Helper ────────────────────────────────────────────────
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

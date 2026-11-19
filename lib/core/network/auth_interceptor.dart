import 'package:dio/dio.dart';
import '../storage/shared_prefs_storage.dart';
import '../storage/storage_keys.dart';
import 'api_endpoints.dart';
import 'app_http_logger.dart';

/// Dio interceptor that:
/// 1. Automatically attaches the JWT Bearer token to authenticated outgoing requests.
/// 2. Intercepts 401 Unauthorized responses, attempts silent token refresh with the 30-day refresh token,
///    and automatically retries the failed request upon successful refresh.
class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final Dio _refreshDio;

  AuthInterceptor({required this.dio})
      : _refreshDio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _refreshDio.interceptors.add(AppHttpLogger());
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip attaching token if already explicitly set (e.g. In custom requests)
    if (!options.headers.containsKey('Authorization')) {
      final storage = SharedPrefsStorage.instanceOrNull;
      final token = await storage?.getString(StorageKeys.authToken);

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final path = err.requestOptions.path;

    // Only handle 401 Unauthorized errors
    final is401 = response?.statusCode == 401;

    // Do NOT attempt token refresh for login, register, or refresh-token calls themselves
    final isAuthEndpoint = path.contains(ApiEndpoints.login) ||
        path.contains(ApiEndpoints.register) ||
        path.contains(ApiEndpoints.refreshToken);

    if (is401 && !isAuthEndpoint) {
      final storage = SharedPrefsStorage.instanceOrNull;
      final refreshToken =
          await storage?.getString(StorageKeys.authRefreshToken);

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Attempt token refresh via separate Dio instance
          final refreshResponse = await _refreshDio.post(
            ApiEndpoints.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          if (refreshResponse.statusCode == 200 &&
              refreshResponse.data is Map<String, dynamic>) {
            final data = refreshResponse.data as Map<String, dynamic>;
            final newToken = data['token'] as String?;
            final newRefreshToken = data['refreshToken'] as String?;

            if (newToken != null && newToken.isNotEmpty) {
              await storage?.setString(StorageKeys.authToken, newToken);
              if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
                await storage?.setString(
                  StorageKeys.authRefreshToken,
                  newRefreshToken,
                );
              }

              // Update the failed request options with the new token and retry
              final originalOptions = err.requestOptions;
              originalOptions.headers['Authorization'] = 'Bearer $newToken';

              final retryResponse = await dio.fetch(originalOptions);
              return handler.resolve(retryResponse);
            }
          }
        } catch (_) {
          // Refresh failed - session has expired. Clear local token cache.
          await storage?.remove(StorageKeys.authToken);
          await storage?.remove(StorageKeys.authRefreshToken);
        }
      }
    }

    handler.next(err);
  }
}

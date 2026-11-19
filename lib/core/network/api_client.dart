import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'app_http_logger.dart';
import 'auth_interceptor.dart';

/// Central HTTP Client wrapper configured with base options, timeouts, and interceptors.
class ApiClient {
  final Dio dio;

  ApiClient({Dio? customDio})
      : dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: ApiEndpoints.baseUrl,
                connectTimeout: const Duration(seconds: 25),
                receiveTimeout: const Duration(seconds: 25),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    dio.interceptors.addAll([
      AuthInterceptor(dio: dio),
      AppHttpLogger(),
    ]);
  }

  /// Helper getter for accessing the underlying [Dio] instance.
  Dio get client => dio;
}

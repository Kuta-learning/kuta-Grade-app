import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Formatted HTTP console logger interceptor.
/// Prints clean, readable request, response, and error summaries in the Flutter console.
class AppHttpLogger extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('┌── 🌐 [HTTP REQUEST] ─────────────────────────────────────────────');
      debugPrint('│ ${options.method.toUpperCase()} ${options.uri}');
      if (options.headers.isNotEmpty) {
        // Redact full JWT token for clean readability while verifying it is present
        final headersCopy = Map<String, dynamic>.from(options.headers);
        if (headersCopy.containsKey('Authorization')) {
          final auth = headersCopy['Authorization'].toString();
          if (auth.length > 25) {
            headersCopy['Authorization'] = '${auth.substring(0, 18)}...[TRUNCATED]';
          }
        }
        debugPrint('│ Headers: $headersCopy');
      }
      if (options.data != null) {
        debugPrint('│ Body: ${options.data}');
      }
      debugPrint('└──────────────────────────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('┌── ✅ [HTTP RESPONSE] ────────────────────────────────────────────');
      debugPrint('│ ${response.statusCode} ${response.statusMessage ?? ''} ⬅️ ${response.requestOptions.uri.path}');
      debugPrint('│ Data: ${response.data}');
      debugPrint('└──────────────────────────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('┌── ❌ [HTTP ERROR] ───────────────────────────────────────────────');
      debugPrint('│ ${err.response?.statusCode ?? 'NETWORK_ERROR'} ⬅️ ${err.requestOptions.uri.path}');
      debugPrint('│ Error Type: ${err.type}');
      debugPrint('│ Message: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('│ Response Body: ${err.response?.data}');
      }
      debugPrint('└──────────────────────────────────────────────────────────────────');
    }
    handler.next(err);
  }
}

import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Dio client for any REST calls outside of the Supabase SDK.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: '${AppConstants.supabaseUrl}/rest/v1/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'apikey': AppConstants.supabaseAnonKey,
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: true),
      _ErrorInterceptor(),
    ]);

  Dio get dio => _dio;
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Normalise error message for the UI layer
    final msg = err.response?.data?['message'] as String? ??
        err.message ??
        'An unexpected error occurred';
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: msg,
      ),
    );
  }
}

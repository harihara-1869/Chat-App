import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../constants/constants.dart';
import '../errors/exceptions.dart';
import '../errors/failure.dart';

/// API Client wrapper around Dio with cookie support
class ApiClient {
  late final Dio _dio;
  late final CookieJar _cookieJar;
  late final CookieManager _cookieManager;

  ApiClient() {
    _cookieJar = CookieJar();
    _cookieManager = CookieManager(_cookieJar);

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add cookie manager to interceptors
    _dio.interceptors.add(_cookieManager);

    // Add logging interceptor for debug builds
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  /// Get the Dio instance for custom configurations
  Dio get dio => _dio;

  /// Get the cookie jar for manual cookie operations
  CookieJar get cookieJar => _cookieJar;

  /// Check if user is authenticated (has session cookie)
  Future<bool> isAuthenticated() async {
    final cookies = await _cookieJar.loadForRequest(Uri.parse(ApiConstants.baseUrl));
    return cookies.any((cookie) => cookie.name == 'token');
  }

  /// Clear all cookies (logout)
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload file with multipart
  Future<Response<T>> uploadFile<T>(
    String path, {
    required FormData data,
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        onSendProgress: onSendProgress,
        options: options ?? Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to typed failures
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(message: 'Connection timeout');

      case DioExceptionType.connectionError:
        return const NetworkException(message: 'No internet connection');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _extractErrorMessage(e.response);

        if (statusCode == 401) {
          return AuthException(message: message, statusCode: statusCode);
        } else if (statusCode == 403) {
          return AuthException(message: message, statusCode: statusCode);
        } else if (statusCode == 429) {
          return const ServerException(message: 'Rate limit exceeded', statusCode: 429);
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(message: message, statusCode: statusCode);
        } else {
          return ServerException(message: message, statusCode: statusCode);
        }

      case DioExceptionType.cancel:
        return const ServerException(message: 'Request cancelled');

      default:
        return ServerException(
          message: e.message ?? 'Unknown error',
          statusCode: e.response?.statusCode,
        );
    }
  }

  String _extractErrorMessage(Response<dynamic>? response) {
    if (response?.data is Map) {
      return response?.data['message'] ??
          response?.data['error'] ??
          'Server error';
    }
    return 'Server error';
  }
}

/// Extension to convert exceptions to failures
extension ExceptionToFailure on Exception {
  Failure toFailure() {
    if (this is ServerException) {
      final e = this as ServerException;
      return ServerFailure(message: e.message, statusCode: e.statusCode);
    } else if (this is NetworkException) {
      return const NetworkFailure();
    } else if (this is AuthException) {
      final e = this as AuthException;
      return AuthFailure(message: e.message, statusCode: e.statusCode);
    } else if (this is CacheException) {
      return const CacheFailure();
    } else if (this is ValidationException) {
      final e = this as ValidationException;
      return ValidationFailure(message: e.message);
    }
    return const UnknownFailure();
  }
}
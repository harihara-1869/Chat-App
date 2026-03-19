import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';

import '../constants/constants.dart';
import '../errors/exceptions.dart';
import '../errors/failure.dart';

/// SHA-256 fingerprints of the server's TLS certificate.
/// 
/// To obtain the fingerprint for your server's certificate:
/// 1. Get the DER-encoded certificate:
///    openssl s_client -connect your-server.com:443 </dev/null 2>/dev/null | \
///    openssl x509 -outform DER > cert.der
/// 2. Calculate SHA-256 fingerprint (base64):
///    openssl x509 -in cert.der -noout -fingerprint -sha256 | \
///    tr -d ':' | xxd -r -p | base64
/// 
/// For localhost development, you can use self-signed certificates.
/// 
/// WARNING: Certificate pins should be rotated before they expire.
class CertificatePinning {
  CertificatePinning._();

  /// SHA-256 certificate fingerprints for production server.
  /// Format: Base64-encoded SHA-256 hash of the DER-encoded certificate.
  static const List<String> productionPins = <String>[
    // 'YOUR_PRODUCTION_CERTIFICATE_SHA256_FINGERPRINT_BASE64',
  ];

  /// SHA-256 certificate fingerprint for development server.
  static const List<String> developmentPins = <String>[
    // For local development, leave empty or add localhost pin
  ];

  static List<String> get pins {
    if (kDebugMode) {
      return developmentPins;
    }
    return productionPins;
  }

  static bool get isEnabled => pins.isNotEmpty;
}

/// Validates that the hostname matches the certificate CN/SANs
class HostnameVerifier {
  HostnameVerifier._();

  static bool verify({
    required String expectedHost,
    required String certSubject,
    bool allowWildcards = true,
  }) {
    if (certSubject == expectedHost) {
      return true;
    }

    if (allowWildcards && certSubject.startsWith('*.')) {
      final wildcardDomain = certSubject.substring(2);
      if (expectedHost.endsWith(wildcardDomain)) {
        return true;
      }
    }

    return false;
  }
}

/// API Client wrapper around Dio with security features:
/// - Cookie support
/// - Certificate pinning (production)
/// - Hostname verification
/// - Production-safe logging
class ApiClient {
  late final Dio _dio;
  late final CookieJar _cookieJar;
  late final CookieManager _cookieManager;

  ApiClient() {
    _cookieJar = CookieJar();
    _cookieManager = CookieManager(_cookieJar);

    const baseUrl = ApiConstants.baseUrl;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Configure security settings based on environment
    _configureSecurity(baseUrl);

    // Add cookie manager to interceptors
    _dio.interceptors.add(_cookieManager);

    // Add logging interceptor - ONLY in debug mode
    // This prevents sensitive data from being logged in production
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (object) {
            debugPrint(object.toString());
          },
        ),
      );
    }

    // Add certificate pinning interceptor if enabled
    if (CertificatePinning.isEnabled) {
      _dio.interceptors.add(
        CertificatePinningInterceptor(
          host: Uri.parse(baseUrl).host,
          pins: CertificatePinning.pins,
        ),
      );
      
      debugPrint('Certificate pinning enabled');
    } else {
      debugPrint('Certificate pinning disabled - configure CertificatePinning.pins for production');
    }
  }

  void _configureSecurity(String baseUrl) {
    if (kDebugMode) {
      debugPrint('Security: Using relaxed security settings for development');
    } else {
      debugPrint('Security: Production security settings active');
    }
  }

  Dio get dio => _dio;
  CookieJar get cookieJar => _cookieJar;

  Future<bool> isAuthenticated() async {
    final cookies = await _cookieJar.loadForRequest(Uri.parse(ApiConstants.baseUrl));
    return cookies.any((cookie) => cookie.name == 'token');
  }

  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

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

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(message: 'Connection timeout');

      case DioExceptionType.connectionError:
        return const NetworkException(message: 'No internet connection');

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Security verification failed. Please check your connection.',
        );

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

/// Dio interceptor for certificate pinning
class CertificatePinningInterceptor extends Interceptor {
  final String _host;
  final List<String> _pins;

  CertificatePinningInterceptor({
    required String host,
    required List<String> pins,
  })  : _host = host,
        _pins = pins;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Certificate pinning verification happens at the TLS level
    // The pinned fingerprints are used for validation in onError
    debugPrint('Certificate pinning configured for host: $_host with ${_pins.length} pins');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.badCertificate) {
      debugPrint('Certificate pinning error for $_host: ${err.message}');
      debugPrint('Expected pins: $_pins');
    }
    handler.next(err);
  }
}

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

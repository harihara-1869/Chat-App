import 'package:equatable/equatable.dart';

/// Base failure class for domain-level errors
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server-side failures (API errors)
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

/// Authentication failures (401, 403)
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

/// Cache/Storage failures
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred'});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Rate limiting failures (429)
class RateLimitFailure extends Failure {
  const RateLimitFailure({
    super.message = 'Too many requests. Please try again later.',
    super.statusCode = 429,
  });
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unknown error occurred'});
}
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/core/errors/exceptions.dart';

void main() {
  group('ServerException', () {
    test('should create with message and status code', () {
      const exception = ServerException(message: 'Server error', statusCode: 500);

      expect(exception.message, 'Server error');
      expect(exception.statusCode, 500);
    });

    test('should have correct toString', () {
      const exception = ServerException(message: 'Error', statusCode: 404);

      expect(exception.toString(), 'ServerException: Error (status: 404)');
    });

    test('should handle null status code', () {
      const exception = ServerException(message: 'Error');

      expect(exception.toString(), 'ServerException: Error (status: null)');
    });
  });

  group('NetworkException', () {
    test('should create with default message', () {
      const exception = NetworkException();

      expect(exception.message, 'No internet connection');
    });

    test('should create with custom message', () {
      const exception = NetworkException(message: 'Custom error');

      expect(exception.message, 'Custom error');
    });

    test('should have correct toString', () {
      const exception = NetworkException(message: 'No connection');

      expect(exception.toString(), 'NetworkException: No connection');
    });
  });

  group('AuthException', () {
    test('should create with message and status code', () {
      const exception = AuthException(message: 'Unauthorized', statusCode: 401);

      expect(exception.message, 'Unauthorized');
      expect(exception.statusCode, 401);
    });

    test('should have correct toString', () {
      const exception = AuthException(message: 'Forbidden', statusCode: 403);

      expect(exception.toString(), 'AuthException: Forbidden');
    });
  });

  group('CacheException', () {
    test('should create with default message', () {
      const exception = CacheException();

      expect(exception.message, 'Cache error');
    });

    test('should create with custom message', () {
      const exception = CacheException(message: 'Cache miss');

      expect(exception.message, 'Cache miss');
    });

    test('should have correct toString', () {
      const exception = CacheException(message: 'Cache failed');

      expect(exception.toString(), 'CacheException: Cache failed');
    });
  });

  group('ValidationException', () {
    test('should create with message', () {
      const exception = ValidationException(message: 'Invalid input');

      expect(exception.message, 'Invalid input');
    });

    test('should have correct toString', () {
      const exception = ValidationException(message: 'Invalid email');

      expect(exception.toString(), 'ValidationException: Invalid email');
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/core/errors/failure.dart';

void main() {
  group('Failure', () {
    test('ServerFailure should have message and status code', () {
      const failure = ServerFailure(message: 'Server error', statusCode: 500);

      expect(failure.message, 'Server error');
      expect(failure.statusCode, 500);
    });

    test('NetworkFailure should have default message', () {
      const failure = NetworkFailure();

      expect(failure.message, 'No internet connection');
    });

    test('AuthFailure should have message and status code', () {
      const failure = AuthFailure(message: 'Unauthorized', statusCode: 401);

      expect(failure.message, 'Unauthorized');
      expect(failure.statusCode, 401);
    });

    test('CacheFailure should have default message', () {
      const failure = CacheFailure();

      expect(failure.message, 'Cache error occurred');
    });

    test('ValidationFailure should have message', () {
      const failure = ValidationFailure(message: 'Invalid input');

      expect(failure.message, 'Invalid input');
    });

    test('UnknownFailure should have default message', () {
      const failure = UnknownFailure();

      expect(failure.message, 'An unknown error occurred');
    });
  });

  group('Failure Equality', () {
    test('ServerFailure with same values should be equal', () {
      const failure1 = ServerFailure(message: 'Error', statusCode: 500);
      const failure2 = ServerFailure(message: 'Error', statusCode: 500);

      expect(failure1, equals(failure2));
    });

    test('NetworkFailure should be equal', () {
      const failure1 = NetworkFailure();
      const failure2 = NetworkFailure();

      expect(failure1, equals(failure2));
    });
  });
}
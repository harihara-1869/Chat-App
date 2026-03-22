import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chat_app/features/auth/repositories/auth_repository.dart';
import 'package:chat_app/core/network/api_client.dart';
import 'package:chat_app/core/errors/exceptions.dart';

class MockApiClient extends Mock implements ApiClient {}

class FakeResponse extends Fake implements Response<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeResponse());
  });
  late MockApiClient mockApiClient;
  late AuthRepository authRepository;

  setUp(() {
    mockApiClient = MockApiClient();
    authRepository = AuthRepository(apiClient: mockApiClient);
  });

  setUpAll(() {
    registerFallbackValue({});
  });

  group('AuthRepository', () {
    group('signup', () {
      test('should return User on successful signup', () async {
        final responseData = {
          '_id': 'user1',
          'fullName': 'testuser',
          'email': 'test@example.com',
          'privacyPolicyAccepted': true,
          'termsAndConditionsAccepted': true,
          'createdAt': '2024-01-01T12:00:00.000',
        };

        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => _MockResponse(data: responseData));

        final user = await authRepository.signup(
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
        );

        expect(user.id, 'user1');
        expect(user.username, 'testuser');
        expect(user.email, 'test@example.com');
      });

      test('should throw ServerException on failure', () async {
        when(() => mockApiClient.post(
                  any(),
                  data: any(named: 'data'),
                ))
            .thenThrow(const ServerException(message: 'Email already exists'));

        expect(
          () => authRepository.signup(
            username: 'testuser',
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('login', () {
      test('should return User on successful login', () async {
        final responseData = {
          '_id': 'user1',
          'fullName': 'testuser',
          'email': 'test@example.com',
          'privacyPolicyAccepted': true,
          'termsAndConditionsAccepted': true,
          'createdAt': '2024-01-01T12:00:00.000',
        };

        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => _MockResponse(data: responseData));

        final user = await authRepository.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(user.id, 'user1');
        expect(user.email, 'test@example.com');
      });

      test('should throw ServerException on failure', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenThrow(const ServerException(message: 'Invalid credentials'));

        expect(
          () => authRepository.login(
            email: 'test@example.com',
            password: 'wrong',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('logout', () {
      test('should call post and clear cookies', () async {
        when(() => mockApiClient.post(any()))
            .thenAnswer((_) async => _MockResponse(data: {}));
        when(() => mockApiClient.clearCookies()).thenAnswer((_) async {});

        await authRepository.logout();

        verify(() => mockApiClient.post('/api/auth/logout')).called(1);
        verify(() => mockApiClient.clearCookies()).called(1);
      });

      test('should clear cookies even if post fails', () async {
        when(() => mockApiClient.post(any()))
            .thenThrow(const ServerException(message: 'Error'));
        when(() => mockApiClient.clearCookies()).thenAnswer((_) async {});

        await authRepository.logout();

        verify(() => mockApiClient.clearCookies()).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return User on success', () async {
        final responseData = {
          '_id': 'user1',
          'username': 'testuser',
          'email': 'test@example.com',
          'createdAt': '2024-01-01T12:00:00.000',
        };

        when(() => mockApiClient.get(any()))
            .thenAnswer((_) async => _MockResponse(data: responseData));

        final user = await authRepository.getCurrentUser();

        expect(user.id, 'user1');
        expect(user.username, 'testuser');
      });

      test('should throw ServerException on failure', () async {
        when(() => mockApiClient.get(any()))
            .thenThrow(const ServerException(message: 'Unauthorized'));

        expect(
          () => authRepository.getCurrentUser(),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('isAuthenticated', () {
      test('should return true when authenticated', () async {
        when(() => mockApiClient.isAuthenticated())
            .thenAnswer((_) async => true);

        final result = await authRepository.isAuthenticated();

        expect(result, true);
      });

      test('should return false when not authenticated', () async {
        when(() => mockApiClient.isAuthenticated())
            .thenAnswer((_) async => false);

        final result = await authRepository.isAuthenticated();

        expect(result, false);
      });
    });

    group('acceptPolicies', () {
      test('should call acceptPrivacyPolicy', () async {
        when(() => mockApiClient.post(any()))
            .thenAnswer((_) async => _MockResponse(data: {}));

        await authRepository.acceptPolicies();

        verify(() => mockApiClient.post('/api/user/accept-policies')).called(1);
      });
    });

    group('needsPolicyAcceptance', () {
      test('should return true when policies not accepted', () async {
        final responseData = {
          '_id': 'user1',
          'username': 'testuser',
          'email': 'test@example.com',
          'acceptedPrivacyPolicy': false,
          'acceptedTermsAndConditions': false,
          'createdAt': '2024-01-01T12:00:00.000',
        };

        when(() => mockApiClient.get(any()))
            .thenAnswer((_) async => _MockResponse(data: responseData));

        final result = await authRepository.needsPolicyAcceptance();

        expect(result, true);
      });

      test('should return false when policies accepted', () async {
        final responseData = {
          '_id': 'user1',
          'username': 'testuser',
          'email': 'test@example.com',
          'acceptedPrivacyPolicy': true,
          'acceptedTermsAndConditions': true,
          'createdAt': '2024-01-01T12:00:00.000',
        };

        when(() => mockApiClient.get(any()))
            .thenAnswer((_) async => _MockResponse(data: responseData));

        final result = await authRepository.needsPolicyAcceptance();

        expect(result, false);
      });

      test('should return false on error', () async {
        when(() => mockApiClient.get(any())).thenThrow(Exception('Error'));

        final result = await authRepository.needsPolicyAcceptance();

        expect(result, false);
      });
    });
  });
}

// Helper class for mock responses
class _MockResponse extends Fake implements Response<dynamic> {
  @override
  final dynamic data;

  _MockResponse({required this.data});

  @override
  Response<T> cast<T>() => throw UnimplementedError();
}

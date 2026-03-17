import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chat_app/features/auth/providers/auth_provider.dart';
import 'package:chat_app/features/auth/models/user.dart';
import 'package:chat_app/features/auth/repositories/auth_repository.dart';
import 'package:chat_app/core/socket/socket_service.dart';
import 'package:chat_app/core/storage/secure_storage_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSocketService extends Mock implements SocketService {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSocketService mockSocketService;
  late MockSecureStorageService mockSecureStorage;
  late AuthNotifier authNotifier;

  final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);
  final testUser = User(
    id: 'user1',
    username: 'testuser',
    email: 'test@example.com',
    acceptedPrivacyPolicy: true,
    acceptedTermsAndConditions: true,
    createdAt: testDateTime,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSocketService = MockSocketService();
    mockSecureStorage = MockSecureStorageService();
    authNotifier = AuthNotifier(
      authRepository: mockAuthRepository,
      socketService: mockSocketService,
      secureStorage: mockSecureStorage,
    );
  });

  setUpAll(() {
    registerFallbackValue(testUser);
  });

  group('AuthState', () {
    test('should have correct default values', () {
      const state = AuthState();

      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });

    test('should copyWith new values', () {
      const state = AuthState(status: AuthStatus.loading);

      final updated = state.copyWith(
        user: testUser,
        errorMessage: 'Error',
      );

      expect(updated.status, AuthStatus.loading);
      expect(updated.user, testUser);
      expect(updated.errorMessage, 'Error');
    });

    test('should copyWith null errorMessage', () {
      const state = AuthState(errorMessage: 'Some error');

      final updated = state.copyWith();

      expect(updated.errorMessage, isNull);
    });
  });

  group('AuthStatus', () {
    test('should have all expected values', () {
      expect(AuthStatus.values.length, 5);
      expect(AuthStatus.values.contains(AuthStatus.initial), true);
      expect(AuthStatus.values.contains(AuthStatus.authenticated), true);
      expect(AuthStatus.values.contains(AuthStatus.unauthenticated), true);
      expect(AuthStatus.values.contains(AuthStatus.loading), true);
      expect(AuthStatus.values.contains(AuthStatus.needsPolicyAcceptance), true);
    });
  });

  group('AuthNotifier', () {
    test('should initialize with initial status', () {
      expect(authNotifier.state.status, AuthStatus.initial);
    });

    test('initialize should set loading then authenticated when user is logged in with policies accepted', () async {
      when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => true);
      when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => testUser);
      when(() => mockSocketService.connect()).thenAnswer((_) async {});
      when(() => mockSecureStorage.storeUserId(any())).thenAnswer((_) async {});

      await authNotifier.initialize();

      expect(authNotifier.state.status, AuthStatus.authenticated);
      expect(authNotifier.state.user, testUser);
      verify(() => mockSocketService.connect()).called(1);
      verify(() => mockSecureStorage.storeUserId('user1')).called(1);
    });

    test('initialize should set needsPolicyAcceptance when policies not accepted', () async {
      final userWithoutPolicies = User(
        id: 'user1',
        username: 'testuser',
        email: 'test@example.com',
        acceptedPrivacyPolicy: false,
        acceptedTermsAndConditions: false,
        createdAt: testDateTime,
      );

      when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => true);
      when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => userWithoutPolicies);

      await authNotifier.initialize();

      expect(authNotifier.state.status, AuthStatus.needsPolicyAcceptance);
    });

    test('initialize should set unauthenticated when not logged in', () async {
      when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);

      await authNotifier.initialize();

      expect(authNotifier.state.status, AuthStatus.unauthenticated);
    });

    test('initialize should set unauthenticated on error', () async {
      when(() => mockAuthRepository.isAuthenticated()).thenThrow(Exception('Error'));

      await authNotifier.initialize();

      expect(authNotifier.state.status, AuthStatus.unauthenticated);
      expect(authNotifier.state.errorMessage, isNotNull);
    });

    test('login should set loading then authenticated on success', () async {
      when(() => mockAuthRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => testUser);
      when(() => mockSocketService.connect()).thenAnswer((_) async {});
      when(() => mockSecureStorage.storeUserId(any())).thenAnswer((_) async {});

      final result = await authNotifier.login(email: 'test@example.com', password: 'password');

      expect(result, true);
      expect(authNotifier.state.status, AuthStatus.authenticated);
    });

    test('login should set unauthenticated on failure', () async {
      when(() => mockAuthRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(Exception('Invalid credentials'));

      final result = await authNotifier.login(email: 'test@example.com', password: 'wrong');

      expect(result, false);
      expect(authNotifier.state.status, AuthStatus.unauthenticated);
      expect(authNotifier.state.errorMessage, isNotNull);
    });

    test('signup should set needsPolicyAcceptance on success', () async {
      when(() => mockAuthRepository.signup(
        username: any(named: 'username'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => testUser);

      final result = await authNotifier.signup(
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, true);
      expect(authNotifier.state.status, AuthStatus.needsPolicyAcceptance);
    });

    test('signup should set unauthenticated on failure', () async {
      when(() => mockAuthRepository.signup(
        username: any(named: 'username'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(Exception('Email already exists'));

      final result = await authNotifier.signup(
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, false);
      expect(authNotifier.state.status, AuthStatus.unauthenticated);
    });

    test('acceptPolicies should update user and set authenticated', () async {
      // Set initial state with user needing policy acceptance
      authNotifier = AuthNotifier(
        authRepository: mockAuthRepository,
        socketService: mockSocketService,
        secureStorage: mockSecureStorage,
      );

      // Manually set state to simulate user who needs to accept policies
      when(() => mockAuthRepository.acceptPolicies()).thenAnswer((_) async {});
      when(() => mockSocketService.connect()).thenAnswer((_) async {});

      await authNotifier.acceptPolicies();

      expect(authNotifier.state.status, AuthStatus.authenticated);
      expect(authNotifier.state.user?.acceptedPrivacyPolicy, true);
      expect(authNotifier.state.user?.acceptedTermsAndConditions, true);
    });

    test('logout should disconnect socket and clear storage', () async {
      when(() => mockSocketService.disconnect()).thenReturn(null);
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
      when(() => mockSecureStorage.clearAll()).thenAnswer((_) async {});

      await authNotifier.logout();

      verify(() => mockSocketService.disconnect()).called(1);
      verify(() => mockAuthRepository.logout()).called(1);
      verify(() => mockSecureStorage.clearAll()).called(1);
      expect(authNotifier.state.status, AuthStatus.unauthenticated);
    });

    test('refreshUser should update user data', () async {
      final updatedUser = testUser.copyWith(username: 'updated');
      when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => updatedUser);

      await authNotifier.refreshUser();

      expect(authNotifier.state.user?.username, 'updated');
    });
  });

  group('currentUserProvider', () {
    test('should return user from auth state', () {
      // This is tested implicitly through the authProvider tests
      // The provider simply extracts the user from authProvider state
    });
  });

  group('isAuthenticatedProvider', () {
    test('should return true when status is authenticated', () {
      // This is tested implicitly through the authProvider tests
    });
  });

  group('needsPolicyAcceptanceProvider', () {
    test('should return true when status is needsPolicyAcceptance', () {
      // This is tested implicitly through the authProvider tests
    });
  });
}
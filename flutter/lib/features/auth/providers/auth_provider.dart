import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

/// Provider for Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient: apiClient);
});

/// Auth state
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  needsPolicyAcceptance,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// Auth notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final SocketService _socketService;
  final SecureStorageService _secureStorage;

  AuthNotifier({
    required AuthRepository authRepository,
    required SocketService socketService,
    required SecureStorageService secureStorage,
  })  : _authRepository = authRepository,
        _socketService = socketService,
        _secureStorage = secureStorage,
        super(const AuthState());

  /// Initialize auth state - check if user is already logged in
  Future<void> initialize() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();

        // Check if policies need acceptance
        if (!user.acceptedPrivacyPolicy || !user.acceptedTermsAndConditions) {
          state = state.copyWith(
            status: AuthStatus.needsPolicyAcceptance,
            user: user,
          );
        } else {
          // Connect socket and store user
          await _socketService.connect();
          await _secureStorage.storeUserId(user.id);
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        }
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );

      // Connect socket for real-time features
      await _socketService.connect();
      await _secureStorage.storeUserId(user.id);

      // Check if policies need acceptance
      if (!user.acceptedPrivacyPolicy || !user.acceptedTermsAndConditions) {
        state = state.copyWith(
          status: AuthStatus.needsPolicyAcceptance,
          user: user,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Sign up
  Future<bool> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final user = await _authRepository.signup(
        username: username,
        email: email,
        password: password,
      );

      state = state.copyWith(
        status: AuthStatus.needsPolicyAcceptance,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Accept policies and continue
  Future<void> acceptPolicies() async {
    try {
      await _authRepository.acceptPolicies();

      // Connect socket after accepting policies
      await _socketService.connect();

      if (state.user != null) {
        final updatedUser = state.user!.copyWith(
          acceptedPrivacyPolicy: true,
          acceptedTermsAndConditions: true,
        );
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: updatedUser,
        );
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Logout
  Future<void> logout() async {
    _socketService.disconnect();
    await _authRepository.logout();
    await _secureStorage.clearAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      // Handle error silently
    }
  }
}

/// Provider for Auth State
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authRepository: ref.watch(authRepositoryProvider),
    socketService: ref.watch(socketServiceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

/// Provider for current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});

/// Provider for checking if policies need acceptance
final needsPolicyAcceptanceProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.needsPolicyAcceptance;
});
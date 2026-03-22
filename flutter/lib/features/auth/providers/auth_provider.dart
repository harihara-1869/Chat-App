import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../core/services/device_registration_service.dart';
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
  final bool preKeyWarning;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.preKeyWarning = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? preKeyWarning,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      preKeyWarning: preKeyWarning ?? this.preKeyWarning,
    );
  }
}

/// Auth notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final SocketService _socketService;
  final SecureStorageService _secureStorage;
  final DeviceRegistrationService? _deviceRegistrationService;

  AuthNotifier({
    required AuthRepository authRepository,
    required SocketService socketService,
    required SecureStorageService secureStorage,
    DeviceRegistrationService? deviceRegistrationService,
  })  : _authRepository = authRepository,
        _socketService = socketService,
        _secureStorage = secureStorage,
        _deviceRegistrationService = deviceRegistrationService,
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
          
          // Check and refill OneTimePreKeys if needed
          await _checkAndRefillPreKeys();
          
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
    print('LOGIN: Starting login process');
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      print('LOGIN: Received API response successfully');

      // Connect socket for real-time features
      await _socketService.connect();
      print('LOGIN: Socket connection initiated');
      
      await _secureStorage.storeUserId(user.id);
      print('LOGIN: Stored user ID securely');

      // Check and refill OneTimePreKeys if needed
      await _checkAndRefillPreKeys();
      print('LOGIN: Checked PRE KEYS');

      // Check if policies need acceptance
      if (!user.acceptedPrivacyPolicy || !user.acceptedTermsAndConditions) {
        print('LOGIN: User needs policy acceptance');
        state = state.copyWith(
          status: AuthStatus.needsPolicyAcceptance,
          user: user,
        );
      } else {
        print('LOGIN: Setting state to authenticated');
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      }
      print('LOGIN: Login completely successful');
      return true;
    } catch (e) {
      print('LOGIN: An error occurred: $e');
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

  /// Check and refill OneTimePreKeys if below threshold
  Future<void> _checkAndRefillPreKeys() async {
    if (_deviceRegistrationService == null) return;
    
    try {
      final isRegistered = await _deviceRegistrationService.isDeviceRegistered();
      if (!isRegistered) {
        return;
      }
      
      final success = await _deviceRegistrationService.checkAndRefillPreKeys();
      if (!success) {
        await Future.delayed(const Duration(seconds: 2));
        final retrySuccess = await _deviceRegistrationService.checkAndRefillPreKeys();
        if (!retrySuccess) {
          state = state.copyWith(preKeyWarning: true);
        }
      }
    } catch (e) {
      try {
        await Future.delayed(const Duration(seconds: 2));
        final retrySuccess = await _deviceRegistrationService.checkAndRefillPreKeys();
        if (!retrySuccess) {
          state = state.copyWith(preKeyWarning: true);
        }
      } catch (retryError) {
        state = state.copyWith(preKeyWarning: true);
      }
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
  final deviceRegistrationServiceAsync = ref.watch(deviceRegistrationServiceProvider);
  final deviceRegistrationService = deviceRegistrationServiceAsync.valueOrNull;
  
  return AuthNotifier(
    authRepository: ref.watch(authRepositoryProvider),
    socketService: ref.watch(socketServiceProvider),
    secureStorage: ref.watch(secureStorageProvider),
    deviceRegistrationService: deviceRegistrationService,
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
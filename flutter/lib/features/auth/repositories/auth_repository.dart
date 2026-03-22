import '../../../core/constants/constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../models/user.dart';

/// Repository for authentication operations
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Sign up with email and password
  Future<User> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.auth}/signup',
        data: {
          'fullName': username,
          'email': email,
          'password': password,
          'privacyPolicy': true, // Mocking acceptance for now, or this should be passed in
          'termsAndConditions': true,
        },
      );
      return User.fromJson(response.data);
    } on ServerException {
      rethrow;
    }
  }

  /// Login with email and password
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.auth}/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return User.fromJson(response.data);
    } on ServerException {
      rethrow;
    }
  }

  /// Logout - clears session cookie
  Future<void> logout() async {
    try {
      await _apiClient.post('${ApiConstants.auth}/logout');
    } catch (_) {
      // Even if server returns error, clear local cookies
    } finally {
      await _apiClient.clearCookies();
    }
  }

  /// Get current authenticated user
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('${ApiConstants.user}/get-user');
      return User.fromJson(response.data);
    } on ServerException {
      rethrow;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }

  /// Verify email with token
  Future<void> verifyEmail(String token) async {
    try {
      await _apiClient.post(
        '${ApiConstants.auth}/verify-email',
        data: {'token': token},
      );
    } on ServerException {
      rethrow;
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiClient.post(
        '${ApiConstants.auth}/reset-password',
        data: {'email': email},
      );
    } on ServerException {
      rethrow;
    }
  }

  /// Reset password with token
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _apiClient.post(
        '${ApiConstants.auth}/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );
    } on ServerException {
      rethrow;
    }
  }

  /// Update password (requires authentication)
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      await _apiClient.post(
        '${ApiConstants.auth}/update-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on ServerException {
      rethrow;
    }
  }

  /// Accept privacy policy
  Future<void> acceptPrivacyPolicy() async {
    try {
      await _apiClient.post('${ApiConstants.user}/accept-policies');
    } on ServerException {
      rethrow;
    }
  }

  /// Accept terms and conditions
  Future<void> acceptTermsAndConditions() async {
    try {
      await _apiClient.post('${ApiConstants.user}/accept-policies');
    } on ServerException {
      rethrow;
    }
  }

  /// Accept both policies
  Future<void> acceptPolicies() async {
    await acceptPrivacyPolicy();
  }

  /// Check if policies need acceptance
  Future<bool> needsPolicyAcceptance() async {
    try {
      final user = await getCurrentUser();
      return !user.acceptedPrivacyPolicy || !user.acceptedTermsAndConditions;
    } catch (_) {
      return false;
    }
  }
}
import 'package:dio/dio.dart';

import '../../../core/constants/constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../repositories/profile_repository.dart';

/// Repository for profile operations
class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get current user profile
  Future<Profile> getProfile() async {
    try {
      final response = await _apiClient.get('${ApiConstants.user}/get-user');
      return Profile.fromJson(response.data);
    } on ServerException {
      rethrow;
    }
  }

  /// Update profile picture
  Future<Profile> updateProfilePicture(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          imagePath,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _apiClient.put(
        '${ApiConstants.user}/update-profile',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return Profile.fromJson(response.data);
    } on ServerException {
      rethrow;
    }
  }

  /// Update username
  Future<Profile> updateUsername(String username) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.user}/update-profile',
        data: {'username': username},
      );
      return Profile.fromJson(response.data);
    } on ServerException {
      rethrow;
    }
  }
}
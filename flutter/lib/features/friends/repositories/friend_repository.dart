import '../../../core/constants/constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../models/friend.dart';

/// Repository for friend operations
class FriendRepository {
  final ApiClient _apiClient;

  FriendRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get list of friends
  Future<List<Friend>> getFriends() async {
    try {
      final response = await _apiClient.get('${ApiConstants.user}/get-friends');
      final List<dynamic> data = response.data;
      return data.map((json) => Friend.fromJson(json)).toList();
    } on ServerException {
      rethrow;
    }
  }

  /// Get pending friend requests
  Future<List<FriendRequest>> getPendingRequests() async {
    try {
      final response = await _apiClient.get('${ApiConstants.friend}/requests/pending');
      final List<dynamic> data = response.data;
      return data.map((json) => FriendRequest.fromJson(json)).toList();
    } on ServerException {
      rethrow;
    }
  }

  /// Send a friend request
  Future<void> sendFriendRequest(String userId) async {
    try {
      await _apiClient.post('${ApiConstants.friend}/request/$userId');
    } on ServerException {
      rethrow;
    }
  }

  /// Accept a friend request
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _apiClient.post('${ApiConstants.friend}/accept/$requestId');
    } on ServerException {
      rethrow;
    }
  }

  /// Reject a friend request
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _apiClient.post('${ApiConstants.friend}/reject/$requestId');
    } on ServerException {
      rethrow;
    }
  }

  /// Search for users by name or email
  Future<List<UserSearchResult>> searchUsers(String query) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.search}',
        queryParameters: {'q': query},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => UserSearchResult.fromJson(json)).toList();
    } on ServerException {
      rethrow;
    }
  }

  /// Remove a friend
  Future<void> removeFriend(String friendId) async {
    try {
      await _apiClient.delete('${ApiConstants.friend}/remove/$friendId');
    } on ServerException {
      rethrow;
    }
  }
}
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/features/friends/models/friend.dart';

void main() {
  group('Friend Model', () {
    final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);

    test('should create Friend with required fields', () {
      final friend = Friend(
        id: 'friend1',
        username: 'frienduser',
        email: 'friend@example.com',
        friendsSince: testDateTime,
      );

      expect(friend.id, 'friend1');
      expect(friend.username, 'frienduser');
      expect(friend.email, 'friend@example.com');
      expect(friend.profilePicture, isNull);
      expect(friend.isOnline, false);
      expect(friend.lastSeen, isNull);
      expect(friend.friendsSince, testDateTime);
    });

    test('should create Friend from JSON', () {
      final json = {
        '_id': 'friend2',
        'username': 'jsonfriend',
        'email': 'json@example.com',
        'profilePicture': 'https://example.com/pic.jpg',
        'isOnline': true,
        'lastSeen': '2024-01-01T10:00:00.000',
        'friendsSince': '2024-01-01T12:00:00.000',
      };

      final friend = Friend.fromJson(json);

      expect(friend.id, 'friend2');
      expect(friend.username, 'jsonfriend');
      expect(friend.profilePicture, 'https://example.com/pic.jpg');
      expect(friend.isOnline, true);
      expect(friend.lastSeen, isNotNull);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        '_id': 'friend3',
        'username': 'minimal',
        'email': 'min@example.com',
        'friendsSince': '2024-01-01T12:00:00.000',
      };

      final friend = Friend.fromJson(json);

      expect(friend.profilePicture, isNull);
      expect(friend.isOnline, false);
      expect(friend.lastSeen, isNull);
    });
  });

  group('FriendRequest Model', () {
    final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);

    test('should create FriendRequest with required fields', () {
      final request = FriendRequest(
        id: 'req1',
        senderId: 'sender1',
        senderUsername: 'sender',
        receiverId: 'receiver1',
        receiverUsername: 'receiver',
        status: FriendRequestStatus.pending,
        createdAt: testDateTime,
      );

      expect(request.id, 'req1');
      expect(request.senderId, 'sender1');
      expect(request.senderUsername, 'sender');
      expect(request.senderProfilePicture, isNull);
      expect(request.receiverId, 'receiver1');
      expect(request.status, FriendRequestStatus.pending);
    });

    test('should create FriendRequest from JSON', () {
      final json = {
        '_id': 'req2',
        'senderId': {
          '_id': 'sender2',
          'fullName': 'jsonSender',
          'profilePic': 'https://example.com/pic.jpg',
        },
        'receiverId': {
          '_id': 'receiver2',
          'fullName': 'jsonReceiver',
        },
        'status': 'accepted',
        'createdAt': '2024-01-01T12:00:00.000',
      };

      final request = FriendRequest.fromJson(json);

      expect(request.id, 'req2');
      expect(request.senderId, 'sender2');
      expect(request.senderUsername, 'jsonSender');
      expect(request.senderProfilePicture, 'https://example.com/pic.jpg');
      expect(request.receiverId, 'receiver2');
      expect(request.receiverUsername, 'jsonReceiver');
      expect(request.status, FriendRequestStatus.accepted);
    });

    test('should handle different status values', () {
      expect(FriendRequestStatus.fromString('pending'),
          FriendRequestStatus.pending);
      expect(FriendRequestStatus.fromString('accepted'),
          FriendRequestStatus.accepted);
      expect(FriendRequestStatus.fromString('rejected'),
          FriendRequestStatus.rejected);
      expect(FriendRequestStatus.fromString('unknown'),
          FriendRequestStatus.pending);
    });
  });

  group('UserSearchResult Model', () {
    test('should create UserSearchResult with required fields', () {
      const result = UserSearchResult(
        id: 'user1',
        username: 'searchuser',
        email: 'search@example.com',
      );

      expect(result.id, 'user1');
      expect(result.username, 'searchuser');
      expect(result.email, 'search@example.com');
      expect(result.profilePicture, isNull);
      expect(result.isFriend, false);
      expect(result.hasPendingRequest, false);
    });

    test('should create UserSearchResult from JSON', () {
      final json = {
        '_id': 'user2',
        'username': 'jsonUser',
        'email': 'json@example.com',
        'profilePicture': 'https://example.com/pic.jpg',
        'isFriend': true,
        'hasPendingRequest': true,
      };

      final result = UserSearchResult.fromJson(json);

      expect(result.id, 'user2');
      expect(result.username, 'jsonUser');
      expect(result.profilePicture, 'https://example.com/pic.jpg');
      expect(result.isFriend, true);
      expect(result.hasPendingRequest, true);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        '_id': 'user3',
        'username': 'minimal',
        'email': 'min@example.com',
      };

      final result = UserSearchResult.fromJson(json);

      expect(result.profilePicture, isNull);
      expect(result.isFriend, false);
      expect(result.hasPendingRequest, false);
    });
  });
}

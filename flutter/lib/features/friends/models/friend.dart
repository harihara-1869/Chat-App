import 'package:equatable/equatable.dart';

/// Friend model representing a friend relationship
class Friend extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? profilePicture;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime friendsSince;

  const Friend({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    this.isOnline = false,
    this.lastSeen,
    required this.friendsSince,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
      friendsSince: DateTime.parse(json['friendsSince'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        profilePicture,
        isOnline,
        lastSeen,
        friendsSince,
      ];
}

/// Friend request model
class FriendRequest extends Equatable {
  final String id;
  final String senderId;
  final String senderUsername;
  final String? senderProfilePicture;
  final String receiverId;
  final String receiverUsername;
  final String? receiverProfilePicture;
  final FriendRequestStatus status;
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    this.senderProfilePicture,
    required this.receiverId,
    required this.receiverUsername,
    this.receiverProfilePicture,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    // Check if senderId is populated (Map) or just an ID (String)
    final senderData = json['senderId'];
    final senderId = senderData is Map ? senderData['_id'] as String : senderData as String;
    final senderUsername = senderData is Map ? (senderData['fullName'] ?? 'Unknown User') as String : 'Unknown User';
    final senderProfilePicture = senderData is Map ? (senderData['profilePic'] ?? senderData['profilePicture']) as String? : null;

    // Check if receiverId is populated (Map) or just an ID (String)
    final receiverData = json['receiverId'];
    final receiverId = receiverData is Map ? receiverData['_id'] as String : receiverData as String;
    final receiverUsername = receiverData is Map ? (receiverData['fullName'] ?? 'Unknown User') as String : 'Unknown User';
    final receiverProfilePicture = receiverData is Map ? (receiverData['profilePic'] ?? receiverData['profilePicture']) as String? : null;

    return FriendRequest(
      id: json['_id'] as String,
      senderId: senderId,
      senderUsername: senderUsername,
      senderProfilePicture: senderProfilePicture,
      receiverId: receiverId,
      receiverUsername: receiverUsername,
      receiverProfilePicture: receiverProfilePicture,
      status: FriendRequestStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderUsername,
        senderProfilePicture,
        receiverId,
        receiverUsername,
        receiverProfilePicture,
        status,
        createdAt,
      ];
}

enum FriendRequestStatus {
  pending,
  accepted,
  rejected;

  static FriendRequestStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      default:
        return FriendRequestStatus.pending;
    }
  }
}

/// Search result model
class UserSearchResult extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? profilePicture;
  final bool isFriend;
  final bool hasPendingRequest;

  const UserSearchResult({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    this.isFriend = false,
    this.hasPendingRequest = false,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['_id'] as String,
      username: json['fullName'] as String? ?? json['username'] as String? ?? 'Unknown User',
      email: json['email'] as String? ?? '',
      profilePicture: json['profilePic'] as String? ?? json['profilePicture'] as String?,
      isFriend: json['isFriend'] as bool? ?? false,
      hasPendingRequest: json['hasPendingRequest'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        profilePicture,
        isFriend,
        hasPendingRequest,
      ];
}
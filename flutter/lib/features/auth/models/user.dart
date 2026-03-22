import 'package:equatable/equatable.dart';

/// User model representing the authenticated user
class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? profilePicture;
  final bool isVerified;
  final bool acceptedPrivacyPolicy;
  final bool acceptedTermsAndConditions;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    this.isVerified = false,
    this.acceptedPrivacyPolicy = false,
    this.acceptedTermsAndConditions = false,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String? ?? '',
      username: (json['fullName'] ?? json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      profilePicture: (json['profilePic'] ?? json['profilePicture']) as String?,
      isVerified: (json['emailVerified'] ?? json['isVerified'] ?? false) as bool,
      acceptedPrivacyPolicy: (json['privacyPolicyAccepted'] ?? json['acceptedPrivacyPolicy'] ?? false) as bool,
      acceptedTermsAndConditions: (json['termsAndConditionsAccepted'] ?? json['acceptedTermsAndConditions'] ?? false) as bool,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'profilePicture': profilePicture,
      'isVerified': isVerified,
      'acceptedPrivacyPolicy': acceptedPrivacyPolicy,
      'acceptedTermsAndConditions': acceptedTermsAndConditions,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? profilePicture,
    bool? isVerified,
    bool? acceptedPrivacyPolicy,
    bool? acceptedTermsAndConditions,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      isVerified: isVerified ?? this.isVerified,
      acceptedPrivacyPolicy: acceptedPrivacyPolicy ?? this.acceptedPrivacyPolicy,
      acceptedTermsAndConditions: acceptedTermsAndConditions ?? this.acceptedTermsAndConditions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        profilePicture,
        isVerified,
        acceptedPrivacyPolicy,
        acceptedTermsAndConditions,
        createdAt,
      ];
}
import 'package:equatable/equatable.dart';

/// Profile model for user profile data
class Profile extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? profilePicture;
  final bool isVerified;
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    this.isVerified = false,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        profilePicture,
        isVerified,
        createdAt,
      ];
}

/// Theme preference
enum AppTheme {
  system,
  light,
  dark;

  static AppTheme fromString(String value) {
    switch (value.toLowerCase()) {
      case 'light':
        return AppTheme.light;
      case 'dark':
        return AppTheme.dark;
      default:
        return AppTheme.system;
    }
  }
}

/// Settings state
class SettingsState extends Equatable {
  final AppTheme theme;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const SettingsState({
    this.theme = AppTheme.system,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  SettingsState copyWith({
    AppTheme? theme,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return SettingsState(
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  List<Object?> get props => [
        theme,
        notificationsEnabled,
        soundEnabled,
        vibrationEnabled,
      ];
}
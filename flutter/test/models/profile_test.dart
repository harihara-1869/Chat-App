import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/features/profile/repositories/profile_repository.dart';

void main() {
  group('Profile Model', () {
    final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);

    test('should create Profile with required fields', () {
      final profile = Profile(
        id: 'profile1',
        username: 'testprofile',
        email: 'profile@example.com',
        createdAt: testDateTime,
      );

      expect(profile.id, 'profile1');
      expect(profile.username, 'testprofile');
      expect(profile.email, 'profile@example.com');
      expect(profile.profilePicture, isNull);
      expect(profile.isVerified, false);
    });

    test('should create Profile from JSON', () {
      final json = {
        '_id': 'profile2',
        'username': 'jsonprofile',
        'email': 'json@example.com',
        'profilePicture': 'https://example.com/pic.jpg',
        'isVerified': true,
        'createdAt': '2024-01-01T12:00:00.000',
      };

      final profile = Profile.fromJson(json);

      expect(profile.id, 'profile2');
      expect(profile.username, 'jsonprofile');
      expect(profile.profilePicture, 'https://example.com/pic.jpg');
      expect(profile.isVerified, true);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        '_id': 'profile3',
        'username': 'minimal',
        'email': 'min@example.com',
        'createdAt': '2024-01-01T12:00:00.000',
      };

      final profile = Profile.fromJson(json);

      expect(profile.profilePicture, isNull);
      expect(profile.isVerified, false);
    });

    test('should have correct props for equality', () {
      final profile1 = Profile(
        id: 'profile1',
        username: 'testprofile',
        email: 'profile@example.com',
        createdAt: testDateTime,
      );

      final profile2 = Profile(
        id: 'profile1',
        username: 'testprofile',
        email: 'profile@example.com',
        createdAt: testDateTime,
      );

      final profile3 = Profile(
        id: 'profile2',
        username: 'different',
        email: 'diff@example.com',
        createdAt: testDateTime,
      );

      expect(profile1, equals(profile2));
      expect(profile1, isNot(equals(profile3)));
    });
  });

  group('AppTheme', () {
    test('should have correct values', () {
      expect(AppTheme.values.length, 3);
      expect(AppTheme.values.contains(AppTheme.system), true);
      expect(AppTheme.values.contains(AppTheme.light), true);
      expect(AppTheme.values.contains(AppTheme.dark), true);
    });

    test('should convert from string correctly', () {
      expect(AppTheme.fromString('light'), AppTheme.light);
      expect(AppTheme.fromString('dark'), AppTheme.dark);
      expect(AppTheme.fromString('system'), AppTheme.system);
      expect(AppTheme.fromString('SYSTEM'), AppTheme.system);
      expect(AppTheme.fromString('unknown'), AppTheme.system);
    });
  });

  group('SettingsState', () {
    test('should have default values', () {
      const settings = SettingsState();

      expect(settings.theme, AppTheme.system);
      expect(settings.notificationsEnabled, true);
      expect(settings.soundEnabled, true);
      expect(settings.vibrationEnabled, true);
    });

    test('should copyWith new values', () {
      const settings = SettingsState();

      final updated = settings.copyWith(
        theme: AppTheme.dark,
        notificationsEnabled: false,
      );

      expect(updated.theme, AppTheme.dark);
      expect(updated.notificationsEnabled, false);
      expect(updated.soundEnabled, true); // unchanged
      expect(updated.vibrationEnabled, true); // unchanged
    });

    test('should have correct props for equality', () {
      const settings1 = SettingsState(theme: AppTheme.light);
      const settings2 = SettingsState(theme: AppTheme.light);
      const settings3 = SettingsState(theme: AppTheme.dark);

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });
  });
}
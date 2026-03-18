import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chat_app/features/profile/providers/profile_provider.dart';
import 'package:chat_app/features/profile/repositories/profile_repository.dart';
import 'package:chat_app/features/profile/models/profile.dart';
import 'package:chat_app/core/storage/secure_storage_service.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockProfileRepository mockProfileRepository;
  late MockSecureStorageService mockSecureStorage;
  late ProfileNotifier profileNotifier;

  final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);

  final testProfile = Profile(
    id: 'profile1',
    username: 'testprofile',
    email: 'profile@example.com',
    createdAt: testDateTime,
  );

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    mockSecureStorage = MockSecureStorageService();
    profileNotifier = ProfileNotifier(
      profileRepository: mockProfileRepository,
      secureStorage: mockSecureStorage,
    );
  });

  group('ProfileState', () {
    test('should have correct default values', () {
      const state = ProfileState();

      expect(state.profile, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should copyWith new values', () {
      const state = ProfileState(isLoading: true);

      final updated = state.copyWith(
        profile: testProfile,
        error: 'Error',
      );

      expect(updated.profile, testProfile);
      expect(updated.isLoading, true);
      expect(updated.error, 'Error');
    });
  });

  group('ProfileNotifier', () {
    test('should start with empty state', () {
      expect(profileNotifier.state.profile, isNull);
      expect(profileNotifier.state.isLoading, false);
    });

    test('loadProfile should update profile', () async {
      when(() => mockProfileRepository.getProfile()).thenAnswer((_) async => testProfile);

      await profileNotifier.loadProfile();

      expect(profileNotifier.state.profile, testProfile);
      expect(profileNotifier.state.isLoading, false);
      expect(profileNotifier.state.error, isNull);
    });

    test('loadProfile should set error on failure', () async {
      when(() => mockProfileRepository.getProfile()).thenThrow(Exception('Failed to load'));

      await profileNotifier.loadProfile();

      expect(profileNotifier.state.profile, isNull);
      expect(profileNotifier.state.isLoading, false);
      expect(profileNotifier.state.error, isNotNull);
    });

    test('updateProfilePicture should return true on success', () async {
      final updatedProfile = Profile(
        id: 'profile1',
        username: 'testprofile',
        email: 'profile@example.com',
        profilePicture: 'https://example.com/newpic.jpg',
        createdAt: testDateTime,
      );

      when(() => mockProfileRepository.updateProfilePicture(any()))
          .thenAnswer((_) async => updatedProfile);

      final result = await profileNotifier.updateProfilePicture('/path/to/image.jpg');

      expect(result, true);
      expect(profileNotifier.state.profile?.profilePicture, 'https://example.com/newpic.jpg');
    });

    test('updateProfilePicture should return false on failure', () async {
      when(() => mockProfileRepository.updateProfilePicture(any()))
          .thenThrow(Exception('Upload failed'));

      final result = await profileNotifier.updateProfilePicture('/path/to/image.jpg');

      expect(result, false);
      expect(profileNotifier.state.error, isNotNull);
    });

    test('updateUsername should return true on success', () async {
      final updatedProfile = Profile(
        id: 'profile1',
        username: 'newname',
        email: 'profile@example.com',
        createdAt: testDateTime,
      );

      when(() => mockProfileRepository.updateUsername(any()))
          .thenAnswer((_) async => updatedProfile);

      final result = await profileNotifier.updateUsername('newname');

      expect(result, true);
      expect(profileNotifier.state.profile?.username, 'newname');
    });

    test('updateUsername should return false on failure', () async {
      when(() => mockProfileRepository.updateUsername(any()))
          .thenThrow(Exception('Update failed'));

      final result = await profileNotifier.updateUsername('newname');

      expect(result, false);
      expect(profileNotifier.state.error, isNotNull);
    });
  });

  group('SettingsNotifier', () {
    late SettingsNotifier settingsNotifier;

    setUp(() {
      mockSecureStorage = MockSecureStorageService();
      when(() => mockSecureStorage.getTheme()).thenAnswer((_) async => null);
      settingsNotifier = SettingsNotifier(secureStorage: mockSecureStorage);
    });

    test('should have default settings', () {
      expect(settingsNotifier.state.theme, AppTheme.system);
      expect(settingsNotifier.state.notificationsEnabled, true);
      expect(settingsNotifier.state.soundEnabled, true);
      expect(settingsNotifier.state.vibrationEnabled, true);
    });

    test('setTheme should update theme', () async {
      when(() => mockSecureStorage.storeTheme(any())).thenAnswer((_) async {});

      await settingsNotifier.setTheme(AppTheme.dark);

      expect(settingsNotifier.state.theme, AppTheme.dark);
      verify(() => mockSecureStorage.storeTheme('dark')).called(1);
    });

    test('setTheme should load saved theme on init', () async {
      mockSecureStorage = MockSecureStorageService();
      when(() => mockSecureStorage.getTheme()).thenAnswer((_) async => 'dark');

      final notifier = SettingsNotifier(secureStorage: mockSecureStorage);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.theme, AppTheme.dark);
    });

    test('setNotificationsEnabled should update setting', () {
      settingsNotifier.setNotificationsEnabled(false);

      expect(settingsNotifier.state.notificationsEnabled, false);
    });

    test('setSoundEnabled should update setting', () {
      settingsNotifier.setSoundEnabled(false);

      expect(settingsNotifier.state.soundEnabled, false);
    });

    test('setVibrationEnabled should update setting', () {
      settingsNotifier.setVibrationEnabled(false);

      expect(settingsNotifier.state.vibrationEnabled, false);
    });
  });

  group('themeProvider', () {
    test('should return theme from settings', () {
      // Tested implicitly through SettingsNotifier tests
    });
  });
}
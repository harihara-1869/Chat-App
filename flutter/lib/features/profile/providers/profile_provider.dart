import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../models/profile.dart';
import '../repositories/profile_repository.dart';

/// Provider for Profile Repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient: apiClient);
});

/// Profile state
class ProfileState {
  final Profile? profile;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    Profile? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for profile management
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _profileRepository;
  final SecureStorageService _secureStorage;

  ProfileNotifier({
    required ProfileRepository profileRepository,
    required SecureStorageService secureStorage,
  })  : _profileRepository = profileRepository,
        _secureStorage = secureStorage,
        super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _profileRepository.getProfile();
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> updateProfilePicture(String imagePath) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _profileRepository.updateProfilePicture(imagePath);
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateUsername(String username) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _profileRepository.updateUsername(username);
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

/// Provider for profile
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    profileRepository: ref.watch(profileRepositoryProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

/// Settings notifier for app settings
class SettingsNotifier extends StateNotifier<SettingsState> {
  final SecureStorageService _secureStorage;

  SettingsNotifier({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage,
        super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeString = await _secureStorage.getTheme();
    if (themeString != null) {
      state = state.copyWith(theme: AppTheme.fromString(themeString));
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    await _secureStorage.storeTheme(theme.name);
    state = state.copyWith(theme: theme);
  }

  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void setSoundEnabled(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
  }

  void setVibrationEnabled(bool enabled) {
    state = state.copyWith(vibrationEnabled: enabled);
  }
}

/// Provider for settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(
    secureStorage: ref.watch(secureStorageProvider),
  );
});

/// Provider for current theme
final themeProvider = Provider<AppTheme>((ref) {
  return ref.watch(settingsProvider).theme;
});
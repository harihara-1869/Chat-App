import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/core/constants/constants.dart';

void main() {
  group('ApiConstants', () {
    test('should have correct base URL', () {
      expect(ApiConstants.baseUrl, 'http://10.0.2.2:5001');
    });

    test('should have all required routes', () {
      expect(ApiConstants.auth, '/api/auth');
      expect(ApiConstants.user, '/api/user');
      expect(ApiConstants.friend, '/api/friend');
      expect(ApiConstants.message, '/api/message');
      expect(ApiConstants.search, '/api/search');
      expect(ApiConstants.device, '/api/device');
      expect(ApiConstants.keys, '/api/keys');
      expect(ApiConstants.privacy, '/api/privacy');
    });

    test('should have correct timeouts', () {
      expect(ApiConstants.connectTimeout, const Duration(seconds: 30));
      expect(ApiConstants.receiveTimeout, const Duration(seconds: 30));
      expect(ApiConstants.sendTimeout, const Duration(seconds: 30));
    });
  });

  group('SocketConstants', () {
    test('should have correct WebSocket URL', () {
      expect(SocketConstants.wsUrl, 'http://10.0.2.2:5001');
    });

    test('should have all socket events', () {
      expect(SocketConstants.connect, 'connect');
      expect(SocketConstants.disconnect, 'disconnect');
      expect(SocketConstants.connected, 'connected');
      expect(SocketConstants.newMessage, 'newMessage');
      expect(SocketConstants.onlineStatus, 'onlineStatus');
      expect(SocketConstants.typing, 'typing');
      expect(SocketConstants.userTyping, 'userTyping');
      expect(SocketConstants.messageRead, 'messageRead');
      expect(SocketConstants.friendRequest, 'friendRequest');
      expect(SocketConstants.friendAccepted, 'friendAccepted');
    });
  });

  group('StorageKeys', () {
    test('should have all identity key storage keys', () {
      expect(StorageKeys.identityPrivateKey, 'identity_private_key');
      expect(StorageKeys.identityPublicKey, 'identity_public_key');
      expect(StorageKeys.registrationId, 'registration_id');
      expect(StorageKeys.deviceId, 'device_id');
    });

    test('should have all pre-key storage keys', () {
      expect(StorageKeys.signedPreKeyPrivate, 'signed_prekey_private');
      expect(StorageKeys.signedPreKeyPublic, 'signed_prekey_public');
      expect(StorageKeys.signedPreKeyId, 'signed_prekey_id');
      expect(StorageKeys.signedPreKeySignature, 'signed_prekey_signature');
      expect(StorageKeys.oneTimePreKeys, 'one_time_prekeys');
    });

    test('should have session and message storage keys', () {
      expect(StorageKeys.sessionStore, 'session_store');
      expect(StorageKeys.messageStore, 'messages');
      expect(StorageKeys.signalSessions, 'signal_sessions');
    });

    test('should have user storage keys', () {
      expect(StorageKeys.userId, 'user_id');
      expect(StorageKeys.theme, 'theme');
    });
  });

  group('RouteNames', () {
    test('should have all route names', () {
      expect(RouteNames.splash, 'splash');
      expect(RouteNames.login, 'login');
      expect(RouteNames.signup, 'signup');
      expect(RouteNames.home, 'home');
      expect(RouteNames.chat, 'chat');
      expect(RouteNames.friends, 'friends');
      expect(RouteNames.settings, 'settings');
      expect(RouteNames.profile, 'profile');
      expect(RouteNames.privacyPolicy, 'privacyPolicy');
      expect(RouteNames.termsConditions, 'termsConditions');
      expect(RouteNames.acceptPolicies, 'acceptPolicies');
    });
  });

  group('RoutePaths', () {
    test('should have all route paths', () {
      expect(RoutePaths.splash, '/');
      expect(RoutePaths.login, '/login');
      expect(RoutePaths.signup, '/signup');
      expect(RoutePaths.home, '/home');
      expect(RoutePaths.chat, '/chat/:userId');
      expect(RoutePaths.friends, '/friends');
      expect(RoutePaths.settings, '/settings');
      expect(RoutePaths.profile, '/profile');
      expect(RoutePaths.privacyPolicy, '/privacy-policy');
      expect(RoutePaths.termsConditions, '/terms-conditions');
      expect(RoutePaths.acceptPolicies, '/accept-policies');
    });
  });
}
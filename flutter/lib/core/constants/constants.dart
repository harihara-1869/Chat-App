/// Application-wide constants

class ApiConstants {
  ApiConstants._();

  /// Base URL for the API - update for production
  static const String baseUrl = 'http://10.0.2.2:5001'; // Android emulator localhost
  // static const String baseUrl = 'http://localhost:5001'; // iOS simulator
  // static const String baseUrl = 'https://your-production-api.com';

  /// API Routes
  static const String auth = '/api/auth';
  static const String user = '/api/user';
  static const String friend = '/api/friend';
  static const String message = '/api/message';
  static const String search = '/api/search';
  static const String device = '/api/device';
  static const String keys = '/api/keys';
  static const String privacy = '/api/privacy';

  /// Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}

class SocketConstants {
  SocketConstants._();

  /// WebSocket URL (same host, no /api prefix)
  static const String wsUrl = 'http://10.0.2.2:5001';
  // static const String wsUrl = 'http://localhost:5001';
  // static const String wsUrl = 'https://your-production-api.com';

  /// Socket Events
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String connected = 'connected';
  static const String newMessage = 'newMessage';
  static const String onlineStatus = 'onlineStatus';
  static const String typing = 'typing';
  static const String userTyping = 'userTyping';
  static const String messageRead = 'messageRead';
  static const String friendRequest = 'friendRequest';
  static const String friendAccepted = 'friendAccepted';
}

class StorageKeys {
  StorageKeys._();

  /// Secure Storage Keys for E2EE
  static const String identityPrivateKey = 'identity_private_key';
  static const String identityPublicKey = 'identity_public_key';
  static const String registrationId = 'registration_id';
  static const String deviceId = 'device_id';
  static const String signedPreKeyPrivate = 'signed_prekey_private';
  static const String signedPreKeyPublic = 'signed_prekey_public';
  static const String signedPreKeyId = 'signed_prekey_id';
  static const String signedPreKeySignature = 'signed_prekey_signature';
  static const String oneTimePreKeys = 'one_time_prekeys';
  static const String sessionStore = 'session_store';
  static const String messageStore = 'messages';
  static const String signalSessions = 'signal_sessions';

  /// Regular storage (non-sensitive)
  static const String userId = 'user_id';
  static const String theme = 'theme';
}

class RouteNames {
  RouteNames._();

  static const String splash = 'splash';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String home = 'home';
  static const String chat = 'chat';
  static const String friends = 'friends';
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String privacyPolicy = 'privacyPolicy';
  static const String termsConditions = 'termsConditions';
  static const String acceptPolicies = 'acceptPolicies';
}

class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String chat = '/chat/:userId';
  static const String friends = '/friends';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsConditions = '/terms-conditions';
  static const String acceptPolicies = '/accept-policies';
}
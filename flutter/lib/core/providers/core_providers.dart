import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../signal/signal_service.dart';
import '../socket/socket_service.dart';
import '../storage/secure_storage_service.dart';
import '../storage/database/database_provider.dart';
import '../storage/message_store.dart';

/// Provider for the API Client
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(() {
    // Cleanup if needed
  });
  return client;
});

/// Provider for the Cookie Jar (shared between API and Socket)
final cookieJarProvider = Provider((ref) {
  return ref.watch(apiClientProvider).cookieJar;
});

/// Provider for Secure Storage Service
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  final storage = SecureStorageService();
  ref.onDispose(() {
    // Cleanup if needed
  });
  return storage;
});

/// Provider for Message Store (local plain-text messages - encrypted SQLite)
final messageStoreProvider = FutureProvider<MessageStore>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return MessageStore(db);
});

/// Provider for Socket Service
final socketServiceProvider = Provider<SocketService>((ref) {
  final cookieJar = ref.watch(cookieJarProvider);
  final socketService = SocketService(cookieJar: cookieJar);

  ref.onDispose(() {
    socketService.dispose();
  });

  return socketService;
});

/// Provider for checking authentication status
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return await apiClient.isAuthenticated();
});

/// Provider for Signal Protocol Service (E2EE)
final signalServiceProvider = Provider<SignalService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final signalService = SignalService(secureStorage: secureStorage);

  ref.onDispose(() {
    signalService.dispose();
  });

  return signalService;
});
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../storage/database/database_provider.dart';
import '../storage/session_store.dart';
import '../storage/message_store.dart';
import '../storage/secure_storage_service.dart';
import '../signal/signal_service.dart';
import '../../features/messaging/repositories/key_repository.dart';
import '../../features/messaging/models/message.dart';

class EncryptedMessagingService {
  final SignalService _signalService;
  final KeyRepository _keyRepository;
  final MessageStore _messageStore;
  final SessionStore _sessionStore;
  final ApiClient _apiClient;

  EncryptedMessagingService({
    required SignalService signalService,
    required KeyRepository keyRepository,
    required MessageStore messageStore,
    required SessionStore sessionStore,
    required ApiClient apiClient,
  })  : _signalService = signalService,
        _keyRepository = keyRepository,
        _messageStore = messageStore,
        _sessionStore = sessionStore,
        _apiClient = apiClient;

  Future<void> initialize() async {
    await _signalService.initialize();
  }

  Future<void> generateAndUploadKeys() async {
    await _signalService.initialize();
    
    final identity = await _signalService.generateIdentityKeyPair();
    final signedPreKey = await _signalService.generateSignedPreKey(1);
    final oneTimePreKeys = await _signalService.generateOneTimePreKeys(100, 100);
    
    await _keyRepository.uploadSignedPreKey(
      keyId: signedPreKey['keyId'],
      publicKey: signedPreKey['publicKey'],
      signature: signedPreKey['signature'],
    );
    
    await _keyRepository.uploadOneTimePreKeys(
      preKeys: oneTimePreKeys,
    );
  }

  Future<Map<String, dynamic>?> getPreKeyBundle() async {
    return await _signalService.getPreKeyBundle();
  }

  Future<void> createSession(String recipientId) async {
    final hasSession = await _signalService.hasSession(recipientId);
    if (hasSession) return;

    final bundle = await _keyRepository.getPreKeyBundle(recipientId);
    
    await _signalService.createSession(recipientId, {
      'registrationId': bundle['registrationId'],
      'deviceId': bundle['deviceId'],
      'preKeyId': bundle['oneTimePreKey']?['keyId'],
      'preKeyPublicKey': bundle['oneTimePreKey']?['publicKey'],
      'signedPreKeyId': bundle['signedPreKey']['keyId'],
      'signedPreKeyPublic': bundle['signedPreKey']['publicKey'],
      'signedPreKeySignature': bundle['signedPreKey']['signature'],
      'identityKey': bundle['identityKey'],
    });
  }

  Future<Map<String, dynamic>> sendMessage({
    required String recipientId,
    required String plaintext,
    List<Attachment>? attachments,
  }) async {
    await createSession(recipientId);

    final encrypted = await _signalService.encryptMessage(recipientId, plaintext);

    final response = await _apiClient.post(
      '/api/message/send/$recipientId',
      data: {
        'type': encrypted['type'] == 1 ? 'prekey' : 'message',
        'ciphertext': encrypted['ciphertext'],
        if (attachments != null && attachments.isNotEmpty)
          'attachments': attachments.map((e) => e.toJson()).toList(),
      },
    );

    final serverMessage = response.data;

    await _messageStore.storeMessage(
      messageId: serverMessage['_id'],
      conversationId: serverMessage['conversationId'] ?? '',
      senderId: serverMessage['senderId'],
      receiverId: serverMessage['receiverId'],
      plaintext: plaintext,
      ciphertext: serverMessage['ciphertext'],
      type: serverMessage['type'],
      otherUserId: recipientId,
    );

    return serverMessage;
  }

  Future<String> decryptMessage(String senderId, Map<String, dynamic> message) async {
    return await _signalService.decryptMessage(senderId, {
      'ciphertext': message['ciphertext'],
      'type': message['type'],
    });
  }

  Future<void> storeIncomingMessage(
    String senderId,
    String plaintext,
    Map<String, dynamic> serverMessage,
  ) async {
    await _messageStore.storeMessage(
      messageId: serverMessage['_id'],
      conversationId: serverMessage['conversationId'] ?? '',
      senderId: serverMessage['senderId'],
      receiverId: serverMessage['receiverId'],
      plaintext: plaintext,
      ciphertext: serverMessage['ciphertext'],
      type: serverMessage['type'],
      otherUserId: senderId,
    );
  }

  Future<List<Map<String, dynamic>>> getLocalMessages(String otherUserId) async {
    return await _messageStore.getMessages(otherUserId);
  }

  Future<bool> hasSession(String recipientId) async {
    return await _signalService.hasSession(recipientId);
  }
}

final keyRepositoryProvider = Provider<KeyRepository>((ref) {
  return KeyRepository(apiClient: ApiClient());
});

// Provider that returns the service synchronously (waits for DB internally)
final encryptedMessagingServiceProvider = Provider<EncryptedMessagingService>((ref) {
  // This will throw if DB isn't ready - UI should handle loading state
  final signalService = ref.watch(signalServiceProvider);
  final keyRepository = ref.watch(keyRepositoryProvider);
  
  // These are async but we'll handle them differently
  final messageStoreAsync = ref.watch(messageStoreProvider);
  final sessionStoreAsync = ref.watch(sessionStoreProvider);
  
  final messageStore = messageStoreAsync.when(
    data: (store) => store,
    loading: () => throw StateError('Database not initialized'),
    error: (e, _) => throw e,
  );
  
  final sessionStore = sessionStoreAsync.when(
    data: (store) => store,
    loading: () => throw StateError('Database not initialized'),
    error: (e, _) => throw e,
  );

  return EncryptedMessagingService(
    signalService: signalService,
    keyRepository: keyRepository,
    messageStore: messageStore,
    sessionStore: sessionStore,
    apiClient: ApiClient(),
  );
});

// FutureProvider version for when you need to await initialization
final encryptedMessagingServiceAsyncProvider = FutureProvider<EncryptedMessagingService>((ref) async {
  final signalService = ref.watch(signalServiceProvider);
  final keyRepository = ref.watch(keyRepositoryProvider);
  final messageStore = await ref.watch(messageStoreProvider.future);
  final sessionStore = await ref.watch(sessionStoreProvider.future);

  return EncryptedMessagingService(
    signalService: signalService,
    keyRepository: keyRepository,
    messageStore: messageStore,
    sessionStore: sessionStore,
    apiClient: ApiClient(),
  );
});

// Signal service provider using secure storage
final signalServiceProvider = Provider<SignalService>((ref) {
  final secureStorage = SecureStorageService();
  return SignalService(secureStorage: secureStorage);
});
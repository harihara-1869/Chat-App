import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../storage/database/app_database.dart';
import '../storage/database/database_provider.dart';
import '../storage/signal_store_bundle.dart';
import '../storage/message_store.dart';
import '../signal/signal_service.dart';
import '../../features/messaging/repositories/key_repository.dart';
import '../../features/messaging/models/message.dart';

class EncryptedMessagingService {
  final SignalService _signalService;
  final KeyRepository _keyRepository;
  final MessageStore _messageStore;
  final ApiClient _apiClient;
  final AppDatabase _db;

  EncryptedMessagingService({
    required SignalService signalService,
    required KeyRepository keyRepository,
    required MessageStore messageStore,
    required ApiClient apiClient,
    required AppDatabase db,
  })  : _signalService = signalService,
        _keyRepository = keyRepository,
        _messageStore = messageStore,
        _apiClient = apiClient,
        _db = db;

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
    required String conversationId,
    required String plaintext,
    List<Attachment>? attachments,
  }) async {
    Map<String, dynamic>? bundle;
    final hasSession = await _signalService.hasSession(recipientId);
    if (!hasSession) {
      bundle = await _keyRepository.getPreKeyBundle(recipientId);
    }

    final encrypted = await _signalService.encryptMessage(
      recipientId: recipientId,
      plaintext: plaintext,
      preKeyBundle: bundle,
    );

    final response = await _apiClient.post(
      '/api/message/send',
      data: {
        'recipientId': recipientId,
        'type': encrypted['type'],
        'ciphertext': encrypted['ciphertext'],
        if (encrypted['type'] == 'prekey' && bundle != null)
          'preKeyBundle': {
            'identityKey': bundle['identityKey'],
            'signedPreKeyId': bundle['signedPreKey']['keyId'],
            'signedPreKeyPublic': bundle['signedPreKey']['publicKey'],
            'signedPreKeySignature': bundle['signedPreKey']['signature'],
            if (bundle['oneTimePreKey'] != null) ...{
              'oneTimePreKeyId': bundle['oneTimePreKey']['keyId'],
              'oneTimePreKeyPublic': bundle['oneTimePreKey']['publicKey'],
            },
          },
        'attachments': attachments?.map((e) => e.toJson()).toList() ?? [],
      },
    );

    final serverMessage = response.data;

    await _messageStore.storeMessage(
      messageId: serverMessage['_id'],
      conversationId: conversationId,
      senderId: serverMessage['senderId'],
      receiverId: serverMessage['receiverId'],
      plaintext: plaintext,
      ciphertext: serverMessage['ciphertext'],
      type: serverMessage['type'],
      otherUserId: recipientId,
    );

    return serverMessage;
  }

  Future<String> decryptAndStoreMessage({
    required String senderId,
    required String conversationId,
    required Map<String, dynamic> message,
    required String serverMessageId,
    DateTime? createdAt,
  }) async {
    return await _db.runInTransaction((db) async {
      final plaintext = await _signalService.decryptMessage(
        senderId: senderId,
        payload: {
          'ciphertext': message['ciphertext'],
          'type': message['type'],
        },
      );

      await _messageStore.storeMessage(
        messageId: serverMessageId,
        conversationId: conversationId,
        senderId: message['senderId'] ?? senderId,
        receiverId: message['receiverId'] ?? '',
        plaintext: plaintext,
        ciphertext: message['ciphertext'],
        type: message['type'],
        otherUserId: senderId,
      );

      return plaintext;
    });
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

final encryptedMessagingServiceProvider = Provider<EncryptedMessagingService>((ref) {
  final signalService = ref.watch(signalServiceProvider);
  final keyRepository = ref.watch(keyRepositoryProvider);
  final messageStore = ref.watch(messageStoreProvider).value;
  final db = ref.watch(appDatabaseProvider).value;
  
  if (messageStore == null || db == null) {
    throw StateError('Database not initialized');
  }

  return EncryptedMessagingService(
    signalService: signalService,
    keyRepository: keyRepository,
    messageStore: messageStore,
    apiClient: ApiClient(),
    db: db,
  );
});

final encryptedMessagingServiceAsyncProvider = FutureProvider<EncryptedMessagingService>((ref) async {
  final signalService = ref.watch(signalServiceProvider);
  final keyRepository = ref.watch(keyRepositoryProvider);
  final messageStore = await ref.watch(messageStoreProvider.future);
  final db = await ref.watch(appDatabaseProvider.future);

  return EncryptedMessagingService(
    signalService: signalService,
    keyRepository: keyRepository,
    messageStore: messageStore,
    apiClient: ApiClient(),
    db: db,
  );
});

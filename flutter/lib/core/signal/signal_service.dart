import 'dart:convert';
import 'dart:typed_data';

import 'package:libsignal/libsignal.dart';

import '../storage/secure_storage_service.dart';
import 'persistent_session_store.dart';

class SignalService {
  final SecureStorageService _secureStorage;
  late PersistentSessionStore _sessionStore;
  late PreKeyStore _preKeyStore;
  late SignedPreKeyStore _signedPreKeyStore;
  late KyberPreKeyStore _kyberPreKeyStore;
  late IdentityKeyStore _identityKeyStore;
  late PrivateKey _identityPrivateKey;
  late PublicKey _identityPublicKey;
  int _registrationId = 1;

  SignalService({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage {
    _initializeStores();
  }

  void _initializeStores() {
    _sessionStore = PersistentSessionStore();
    _preKeyStore = InMemoryPreKeyStore();
    _signedPreKeyStore = InMemorySignedPreKeyStore();
    _kyberPreKeyStore = InMemoryKyberPreKeyStore();
    
    final identity = IdentityKeyPair.generate();
    _identityPrivateKey = PrivateKey.deserialize(bytes: identity.privateKey.toList());
    _identityPublicKey = PublicKey.deserialize(bytes: identity.publicKey.toList());
    _identityKeyStore = InMemoryIdentityKeyStore(identity, _registrationId);
  }

  Future<void> initialize() async {
    await LibSignal.init();
    await _loadKeysFromStorage();
  }

  Future<void> _loadKeysFromStorage() async {
    final privateKeyBase64 = await _secureStorage.getIdentityPrivateKey();
    final publicKeyBase64 = await _secureStorage.getIdentityPublicKey();
    final registrationId = await _secureStorage.getRegistrationId();

    if (privateKeyBase64 != null && publicKeyBase64 != null && registrationId != null) {
      _identityPrivateKey = PrivateKey.deserialize(
        bytes: base64Decode(privateKeyBase64),
      );
      _identityPublicKey = PublicKey.deserialize(
        bytes: base64Decode(publicKeyBase64),
      );
      _registrationId = registrationId;
      
      final identity = IdentityKeyPair.fromKeys(
        privateKey: _identityPrivateKey,
        publicKey: _identityPublicKey,
      );
      _identityKeyStore = InMemoryIdentityKeyStore(identity, _registrationId);
    }

    final signedPreKeyPrivate = await _secureStorage.getSignedPreKeyPrivate();
    final signedPreKeyId = await _secureStorage.getSignedPreKeyId();

    if (signedPreKeyPrivate != null && signedPreKeyId != null) {
      final signedPreKey = SignedPreKeyRecord.deserialize(
        bytes: base64Decode(signedPreKeyPrivate),
      );
      await _signedPreKeyStore.storeSignedPreKey(signedPreKeyId, signedPreKey);
    }

    final oneTimePreKeys = await _secureStorage.getOneTimePreKeys();
    if (oneTimePreKeys != null) {
      for (final preKey in oneTimePreKeys) {
        final preKeyRecord = PreKeyRecord.deserialize(
          bytes: base64Decode(preKey['privateKey'] as String),
        );
        await _preKeyStore.storePreKey(preKey['keyId'] as int, preKeyRecord);
      }
    }
  }

  Future<Map<String, dynamic>> generateIdentityKeyPair() async {
    _identityPrivateKey = PrivateKey.generate();
    _identityPublicKey = _identityPrivateKey.getPublicKey();
    _registrationId = DateTime.now().millisecondsSinceEpoch % 16380;

    await _secureStorage.storeIdentityPrivateKey(
      base64Encode(_identityPrivateKey.serialize()),
    );
    await _secureStorage.storeIdentityPublicKey(
      base64Encode(_identityPublicKey.serialize()),
    );
    await _secureStorage.storeRegistrationId(_registrationId);

    final identity = IdentityKeyPair.fromKeys(
      privateKey: _identityPrivateKey,
      publicKey: _identityPublicKey,
    );
    _identityKeyStore = InMemoryIdentityKeyStore(identity, _registrationId);

    return {
      'privateKey': base64Encode(_identityPrivateKey.serialize()),
      'publicKey': base64Encode(_identityPublicKey.serialize()),
      'registrationId': _registrationId,
    };
  }

  Future<Map<String, dynamic>> generateSignedPreKey(int keyId) async {
    final signedPreKeyPrivate = PrivateKey.generate();
    final signedPreKeyPublic = signedPreKeyPrivate.getPublicKey();

    final signature = _identityPrivateKey.sign(
      message: signedPreKeyPublic.serialize(),
    );

    final signedPreKey = SignedPreKeyRecord(
      id: keyId,
      timestamp: BigInt.from(DateTime.now().millisecondsSinceEpoch),
      publicKey: signedPreKeyPublic,
      privateKey: signedPreKeyPrivate,
      signature: signature,
    );

    await _signedPreKeyStore.storeSignedPreKey(keyId, signedPreKey);
    await _secureStorage.storeSignedPreKey(
      privateKey: base64Encode(signedPreKeyPrivate.serialize()),
      publicKey: base64Encode(signedPreKeyPublic.serialize()),
      keyId: keyId,
      signature: base64Encode(signature),
    );

    return {
      'keyId': keyId,
      'publicKey': base64Encode(signedPreKeyPublic.serialize()),
      'privateKey': base64Encode(signedPreKeyPrivate.serialize()),
      'signature': base64Encode(signature),
    };
  }

  Future<Map<String, dynamic>> generateKyberPreKey(int keyId) async {
    final kyberKeyPair = KyberKeyPair.generate();
    final kyberPublicKey = kyberKeyPair.getPublicKey();
    final kyberSecretKey = kyberKeyPair.getSecretKey();

    final signature = _identityPrivateKey.sign(
      message: kyberPublicKey.serialize(),
    );

    final kyberPreKey = KyberPreKeyRecord.create(
      id: keyId,
      timestamp: BigInt.from(DateTime.now().millisecondsSinceEpoch),
      keyPair: kyberKeyPair,
      signature: signature,
    );

    await _kyberPreKeyStore.storeKyberPreKey(keyId, kyberPreKey);

    return {
      'keyId': keyId,
      'publicKey': base64Encode(kyberPublicKey.serialize()),
      'privateKey': base64Encode(kyberSecretKey.serialize()),
      'signature': base64Encode(signature),
    };
  }

  Future<List<Map<String, dynamic>>> generateOneTimePreKeys(
    int startId,
    int count,
  ) async {
    final preKeyList = <Map<String, dynamic>>[];

    for (int i = 0; i < count; i++) {
      final preKeyPrivate = PrivateKey.generate();
      final preKeyPublic = preKeyPrivate.getPublicKey();
      final keyId = startId + i;

      final preKeyRecord = PreKeyRecord(
        id: keyId,
        publicKey: preKeyPublic,
        privateKey: preKeyPrivate,
      );

      await _preKeyStore.storePreKey(keyId, preKeyRecord);

      preKeyList.add({
        'keyId': keyId,
        'publicKey': base64Encode(preKeyPublic.serialize()),
        'privateKey': base64Encode(preKeyPrivate.serialize()),
      });
    }

    await _secureStorage.storeOneTimePreKeys(preKeyList);

    return preKeyList;
  }

  Future<Map<String, dynamic>> getPreKeyBundle() async {
    final signedPreKeyId = await _secureStorage.getSignedPreKeyId();
    if (signedPreKeyId == null) {
      throw SignalException('Signed pre-key not generated');
    }

    final signedPreKey = await _signedPreKeyStore.loadSignedPreKey(signedPreKeyId);
    if (signedPreKey == null) {
      throw SignalException('Signed pre-key not found');
    }

    final signedPreKeyPublicKey = signedPreKey.publicKey();
    final signature = _identityPrivateKey.sign(
      message: signedPreKeyPublicKey,
    );

    final kyberPreKeyId = 1;
    final kyberPreKey = await _kyberPreKeyStore.loadKyberPreKey(kyberPreKeyId);
    final kyberPublicKey = kyberPreKey?.getPublicKey();
    final kyberSignature = kyberPreKey != null 
        ? _identityPrivateKey.sign(message: kyberPublicKey!.serialize())
        : null;

    return {
      'registrationId': _registrationId,
      'deviceId': 1,
      'identityKey': base64Encode(_identityPublicKey.serialize()),
      'signedPreKeyId': signedPreKeyId,
      'signedPreKeyPublic': base64Encode(signedPreKeyPublicKey),
      'signedPreKeySignature': base64Encode(signature),
      'kyberPreKeyId': kyberPreKeyId,
      'kyberPreKeyPublic': kyberPublicKey != null ? base64Encode(kyberPublicKey.serialize()) : null,
      'kyberPreKeySignature': kyberSignature != null ? base64Encode(kyberSignature) : null,
    };
  }

  Future<void> createSession(
    String recipientId,
    Map<String, dynamic> preKeyBundle,
  ) async {
    final recipientAddress = ProtocolAddress(
      name: recipientId,
      deviceId: preKeyBundle['deviceId'] as int,
    );

    final bundle = PreKeyBundle(
      registrationId: preKeyBundle['registrationId'] as int,
      deviceId: preKeyBundle['deviceId'] as int,
      preKeyId: preKeyBundle['preKeyId'] as int?,
      preKeyPublic: preKeyBundle['preKeyPublicKey'] != null 
          ? base64Decode(preKeyBundle['preKeyPublicKey'] as String) 
          : null,
      signedPreKeyId: preKeyBundle['signedPreKeyId'] as int,
      signedPreKeyPublic: base64Decode(preKeyBundle['signedPreKeyPublic'] as String),
      signedPreKeySignature: base64Decode(preKeyBundle['signedPreKeySignature'] as String),
      identityKey: base64Decode(preKeyBundle['identityKey'] as String),
      kyberPreKeyId: preKeyBundle['kyberPreKeyId'] as int? ?? 1,
      kyberPreKeyPublic: base64Decode(preKeyBundle['kyberPreKeyPublic'] as String),
      kyberPreKeySignature: base64Decode(preKeyBundle['kyberPreKeySignature'] as String),
    );

    final builder = SessionBuilder(
      sessionStore: _sessionStore,
      identityKeyStore: _identityKeyStore,
    );

    await builder.processPreKeyBundle(recipientAddress, bundle);

    if (preKeyBundle['preKeyId'] != null && preKeyBundle['preKeyId'] != 0) {
      await _preKeyStore.removePreKey(preKeyBundle['preKeyId'] as int);
      await _secureStorage.removeOneTimePreKey(preKeyBundle['preKeyId'] as int);
    }
  }

  Future<Map<String, dynamic>> encryptMessage(
    String recipientId,
    String plaintext,
  ) async {
    final recipientAddress = ProtocolAddress(name: recipientId, deviceId: 1);

    final cipher = SessionCipher(
      sessionStore: _sessionStore,
      identityKeyStore: _identityKeyStore,
      preKeyStore: _preKeyStore,
      signedPreKeyStore: _signedPreKeyStore,
      kyberPreKeyStore: _kyberPreKeyStore,
    );

    final ciphertext = await cipher.encrypt(
      recipientAddress,
      Uint8List.fromList(utf8.encode(plaintext)),
    );

    return {
      'type': ciphertext.isPreKeyMessage ? 1 : 0,
      'ciphertext': base64Encode(ciphertext.ciphertext),
    };
  }

  Future<String> decryptMessage(
    String senderId,
    Map<String, dynamic> message,
  ) async {
    final senderAddress = ProtocolAddress(name: senderId, deviceId: 1);

    final cipher = SessionCipher(
      sessionStore: _sessionStore,
      identityKeyStore: _identityKeyStore,
      preKeyStore: _preKeyStore,
      signedPreKeyStore: _signedPreKeyStore,
      kyberPreKeyStore: _kyberPreKeyStore,
    );

    final ciphertextBytes = base64Decode(message['ciphertext'] as String);

    Uint8List plaintext;
    if (message['type'] == 1) {
      plaintext = await cipher.decryptPreKeyMessage(senderAddress, ciphertextBytes);
    } else {
      plaintext = await cipher.decryptSignalMessage(senderAddress, ciphertextBytes);
    }

    return utf8.decode(plaintext);
  }

  Future<bool> hasSession(String recipientId) async {
    final address = ProtocolAddress(name: recipientId, deviceId: 1);
    return _sessionStore.containsSession(address);
  }

  Future<void> deleteSession(String recipientId) async {
    final address = ProtocolAddress(name: recipientId, deviceId: 1);
    await _sessionStore.deleteSession(address);
    await _secureStorage.deleteSession(recipientId);
  }

  Future<void> deleteAllSessions() async {
    await _sessionStore.clearAll();
    await _secureStorage.clearE2EEKeys();
  }

  void dispose() {
    LibSignal.cleanup();
  }
}

class SignalException implements Exception {
  final String message;

  const SignalException(this.message);

  @override
  String toString() => 'SignalException: $message';
}
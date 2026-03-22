import 'dart:convert';
import 'dart:typed_data';

import 'package:libsignal/libsignal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'registration_id.dart';
import '../storage/signal_store_bundle.dart';
import '../storage/session_store.dart';
import '../storage/identity_key_store.dart';
import '../storage/pre_key_store.dart';
import '../storage/signed_pre_key_store.dart';
import '../storage/kyber_pre_key_store.dart';

class SignalService {
  final SignalStoreBundle _bundle;
  late PrivateKey _identityPrivateKey;
  late PublicKey _identityPublicKey;
  int _registrationId = 1;

  SignalService({
    required SignalStoreBundle bundle,
  }) : _bundle = bundle;

  DriftSignalSessionStore get sessionStore => _bundle.sessionStore;
  DriftIdentityKeyStore get identityKeyStore => _bundle.identityKeyStore;
  DriftPreKeyStore get preKeyStore => _bundle.preKeyStore;
  DriftSignedPreKeyStore get signedPreKeyStore => _bundle.signedPreKeyStore;
  DriftKyberPreKeyStore get kyberPreKeyStore => _bundle.kyberPreKeyStore;

  Future<void> initialize() async {
    await LibSignal.init();
  }

  Future<void> loadIdentityFromBundle() async {
    final identityKeyPair = await identityKeyStore.getIdentityKeyPair();
    _identityPrivateKey =
        PrivateKey.deserialize(bytes: identityKeyPair.privateKey.toList());
    _identityPublicKey =
        PublicKey.deserialize(bytes: identityKeyPair.publicKey.toList());
    _registrationId = await identityKeyStore.getLocalRegistrationId();
  }

  Future<Map<String, dynamic>> generateIdentityKeyPair() async {
    _identityPrivateKey = PrivateKey.generate();
    _identityPublicKey = _identityPrivateKey.getPublicKey();
    _registrationId = generateSecureRegistrationId();

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

    await signedPreKeyStore.storeSignedPreKey(keyId, signedPreKey);

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

    await kyberPreKeyStore.storeKyberPreKey(keyId, kyberPreKey);

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

      await preKeyStore.storePreKey(keyId, preKeyRecord);

      preKeyList.add({
        'keyId': keyId,
        'publicKey': base64Encode(preKeyPublic.serialize()),
        'privateKey': base64Encode(preKeyPrivate.serialize()),
      });
    }

    return preKeyList;
  }

  Future<Map<String, dynamic>> getPreKeyBundle() async {
    final signedPreKeyId = 1;
    final signedPreKey =
        await signedPreKeyStore.loadSignedPreKey(signedPreKeyId);

    final signedPreKeyPublicKey = signedPreKey.publicKey();
    final signature = _identityPrivateKey.sign(
      message: signedPreKeyPublicKey,
    );

    final kyberPreKeyId = 1;
    final kyberPreKey = await kyberPreKeyStore.loadKyberPreKey(kyberPreKeyId);
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
      'kyberPreKeyPublic': kyberPublicKey != null
          ? base64Encode(kyberPublicKey.serialize())
          : null,
      'kyberPreKeySignature':
          kyberSignature != null ? base64Encode(kyberSignature) : null,
    };
  }

  Future<void> createSession(
    String recipientId,
    Map<String, dynamic> preKeyBundle,
  ) async {
    final normalizedBundle = normalizePreKeyBundle(preKeyBundle);
    final isValidSignature = verifySignedPreKeySignature(normalizedBundle);
    if (!isValidSignature) {
      throw const SignalException(
        'Invalid signed pre-key signature for recipient bundle',
      );
    }

    final recipientAddress = ProtocolAddress(
      name: recipientId,
      deviceId: normalizedBundle['deviceId'] as int,
    );

    final bundle = PreKeyBundle(
      registrationId: normalizedBundle['registrationId'] as int,
      deviceId: normalizedBundle['deviceId'] as int,
      preKeyId: normalizedBundle['preKeyId'] as int?,
      preKeyPublic: normalizedBundle['preKeyPublicKey'] != null
          ? base64Decode(normalizedBundle['preKeyPublicKey'] as String)
          : null,
      signedPreKeyId: normalizedBundle['signedPreKeyId'] as int,
      signedPreKeyPublic:
          base64Decode(normalizedBundle['signedPreKeyPublic'] as String),
      signedPreKeySignature:
          base64Decode(normalizedBundle['signedPreKeySignature'] as String),
      identityKey: base64Decode(normalizedBundle['identityKey'] as String),
      kyberPreKeyId: normalizedBundle['kyberPreKeyId'] as int? ?? 1,
      kyberPreKeyPublic:
          base64Decode(normalizedBundle['kyberPreKeyPublic'] as String),
      kyberPreKeySignature:
          base64Decode(normalizedBundle['kyberPreKeySignature'] as String),
    );

    final builder = _bundle.getSessionBuilder(recipientAddress);

    await builder.processPreKeyBundle(recipientAddress, bundle);

    if (normalizedBundle['preKeyId'] != null &&
        normalizedBundle['preKeyId'] != 0) {
      await preKeyStore.removePreKey(normalizedBundle['preKeyId'] as int);
    }
  }

  static Map<String, dynamic> normalizePreKeyBundle(
      Map<String, dynamic> preKeyBundle) {
    if (preKeyBundle['signedPreKey'] is Map<String, dynamic>) {
      final signedPreKey = preKeyBundle['signedPreKey'] as Map<String, dynamic>;
      final oneTimePreKey =
          preKeyBundle['oneTimePreKey'] as Map<String, dynamic>?;
      return {
        'registrationId': preKeyBundle['registrationId'],
        'deviceId': preKeyBundle['deviceId'],
        'preKeyId': oneTimePreKey?['keyId'],
        'preKeyPublicKey': oneTimePreKey?['publicKey'],
        'signedPreKeyId': signedPreKey['keyId'],
        'signedPreKeyPublic': signedPreKey['publicKey'],
        'signedPreKeySignature': signedPreKey['signature'],
        'identityKey': preKeyBundle['identityKey'],
        'kyberPreKeyId': preKeyBundle['kyberPreKeyId'],
        'kyberPreKeyPublic': preKeyBundle['kyberPreKeyPublic'],
        'kyberPreKeySignature': preKeyBundle['kyberPreKeySignature'],
      };
    }

    return Map<String, dynamic>.from(preKeyBundle);
  }

  static bool verifySignedPreKeySignature(Map<String, dynamic> preKeyBundle) {
    final normalizedBundle = normalizePreKeyBundle(preKeyBundle);
    final identityKeyBytes = Uint8List.fromList(
        base64Decode(normalizedBundle['identityKey'] as String));
    final signedPreKeyPublicBytes = Uint8List.fromList(
      base64Decode(normalizedBundle['signedPreKeyPublic'] as String),
    );
    final signatureBytes = Uint8List.fromList(
      base64Decode(normalizedBundle['signedPreKeySignature'] as String),
    );

    final identityKey = PublicKey.deserialize(bytes: identityKeyBytes);
    return identityKey.verify(
      message: signedPreKeyPublicBytes,
      signature: signatureBytes,
    );
  }

  Future<Map<String, dynamic>> encryptMessage({
    required String recipientId,
    required String plaintext,
    Map<String, dynamic>? preKeyBundle,
  }) async {
    final recipientAddress = ProtocolAddress(name: recipientId, deviceId: 1);

    final hasSession = await sessionStore.containsSession(recipientAddress);

    if (!hasSession && preKeyBundle != null) {
      await createSession(recipientId, preKeyBundle);
    }

    final cipher = _bundle.getSessionCipher(recipientAddress);

    final ciphertext = await cipher.encrypt(
      recipientAddress,
      Uint8List.fromList(utf8.encode(plaintext)),
    );

    return {
      'type': ciphertext.isPreKeyMessage ? 'prekey' : 'message',
      'ciphertext': base64Encode(ciphertext.ciphertext),
    };
  }

  Future<String> decryptMessage({
    required String senderId,
    required Map<String, dynamic> payload,
  }) async {
    final senderAddress = ProtocolAddress(name: senderId, deviceId: 1);

    final cipher = _bundle.getSessionCipher(senderAddress);

    final ciphertextBytes = base64Decode(payload['ciphertext'] as String);

    Uint8List plaintext;
    if (payload['type'] == 'prekey' || payload['type'] == 1) {
      plaintext =
          await cipher.decryptPreKeyMessage(senderAddress, ciphertextBytes);
    } else {
      plaintext =
          await cipher.decryptSignalMessage(senderAddress, ciphertextBytes);
    }

    return utf8.decode(plaintext);
  }

  Future<bool> hasSession(String recipientId) async {
    final address = ProtocolAddress(name: recipientId, deviceId: 1);
    return sessionStore.containsSession(address);
  }

  Future<void> deleteSession(String recipientId) async {
    final address = ProtocolAddress(name: recipientId, deviceId: 1);
    await sessionStore.deleteSession(address);
  }

  Future<void> deleteAllSessions() async {
    await sessionStore.clearAll();
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

final signalServiceProvider = Provider<SignalService>((ref) {
  final bundleAsync = ref.watch(signalStoreBundleProvider);
  final bundle = bundleAsync.valueOrNull;
  if (bundle == null) {
    throw StateError('SignalStoreBundle not initialized');
  }
  return SignalService(bundle: bundle);
});

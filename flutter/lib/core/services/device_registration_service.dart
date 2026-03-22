import 'dart:convert';

import 'package:libsignal/libsignal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../signal/registration_id.dart';
import '../providers/core_providers.dart';
import '../storage/secure_key_store.dart';
import '../storage/signal_store_bundle.dart';
import '../../features/messaging/repositories/key_repository.dart';

class DeviceRegistrationService {
  final SecureKeyStore _secureKeyStore;
  final SignalStoreBundle _bundle;
  final KeyRepository _keyRepository;
  final int _deviceId = 1;
  static const int _oneTimePreKeyCount = 20;
  static const int _minOneTimePreKeys = 5;

  DeviceRegistrationService({
    required SecureKeyStore secureKeyStore,
    required SignalStoreBundle bundle,
    required KeyRepository keyRepository,
  })  : _secureKeyStore = secureKeyStore,
        _bundle = bundle,
        _keyRepository = keyRepository;

  Future<bool> isDeviceRegistered() async {
    return await _secureKeyStore.hasIdentityKey();
  }

  Future<void> register() async {
    await LibSignal.init();

    final identityKeyPair = IdentityKeyPair.generate();
    final identityPrivateKey = PrivateKey.deserialize(
      bytes: identityKeyPair.privateKey.toList(),
    );
    final identityPublicKey = PublicKey.deserialize(
      bytes: identityKeyPair.publicKey.toList(),
    );
    final registrationId = _generateRegistrationId();

    await _secureKeyStore.storeIdentityKeyPair(
      privateKey: identityKeyPair.privateKey,
      publicKey: identityKeyPair.publicKey,
    );
    await _secureKeyStore.storeRegistrationId(registrationId);

    final signedPreKeyResult = await _generateSignedPreKey(
      identityPrivateKey,
      1,
    );
    await _bundle.signedPreKeyStore.storeSignedPreKey(
      1,
      signedPreKeyResult['record'] as SignedPreKeyRecord,
    );

    final oneTimePreKeys = await _generateOneTimePreKeys(
      identityPrivateKey,
      0,
      _oneTimePreKeyCount,
    );
    for (final key in oneTimePreKeys) {
      await _bundle.preKeyStore.storePreKey(
        key['id'] as int,
        key['record'] as PreKeyRecord,
      );
    }

    try {
      final kyberPreKeyResult = await _generateKyberPreKey(
        identityPrivateKey,
        1,
      );
      if (kyberPreKeyResult != null) {
        await _bundle.kyberPreKeyStore.storeKyberPreKey(
          1,
          kyberPreKeyResult['record'] as KyberPreKeyRecord,
        );
      }
    } catch (e) {
      // Kyber may not be supported, continue without it
    }

    await _keyRepository.registerDevice(
      identityPublicKey: base64Encode(identityPublicKey.serialize()),
      registrationId: registrationId,
    );

    await _keyRepository.uploadSignedPreKey(
      keyId: 1,
      publicKey: signedPreKeyResult['publicKey'] as String,
      signature: signedPreKeyResult['signature'] as String,
    );

    await _keyRepository.uploadOneTimePreKeys(
      preKeys: oneTimePreKeys
          .map((k) => {
                'keyId': k['id'],
                'publicKey': k['publicKey'],
              })
          .toList(),
    );
  }

  /// Check prekey count and refill if below threshold
  /// Called after login and after prekey session creation
  Future<bool> checkAndRefillPreKeys() async {
    try {
      final count = await _keyRepository.getPreKeyCount();

      if (count >= 10) {
        return true; // Sufficient keys
      }

      // Need to refill - generate new keys
      await replenishOneTimePreKeys();
      return true;
    } catch (e) {
      // First retry
      try {
        await Future.delayed(const Duration(seconds: 1));
        final count = await _keyRepository.getPreKeyCount();
        if (count >= 10) return true;
        await replenishOneTimePreKeys();
        return true;
      } catch (retryError) {
        // Failed twice - surface non-blocking warning
        return false;
      }
    }
  }

  Future<void> replenishOneTimePreKeys() async {
    final count = await _keyRepository.getPreKeyCount();
    if (count >= _minOneTimePreKeys) {
      return;
    }

    final identityPrivateKey = await _getIdentityPrivateKey();
    final storedNextId = await _getNextOneTimePreKeyId();
    final newKeys = await _generateOneTimePreKeys(
      identityPrivateKey,
      storedNextId,
      _oneTimePreKeyCount,
    );

    for (final key in newKeys) {
      await _bundle.preKeyStore.storePreKey(
        key['id'] as int,
        key['record'] as PreKeyRecord,
      );
    }

    await _keyRepository.uploadOneTimePreKeys(
      preKeys: newKeys
          .map((k) => {
                'keyId': k['id'],
                'publicKey': k['publicKey'],
              })
          .toList(),
    );

    await _secureKeyStore
        .storeNextOneTimePreKeyId(storedNextId + _oneTimePreKeyCount);
  }

  Future<PrivateKey> _getIdentityPrivateKey() async {
    final privateKeyBytes = await _secureKeyStore.getIdentityPrivateKey();
    return PrivateKey.deserialize(bytes: privateKeyBytes);
  }

  int _generateRegistrationId() {
    return generateSecureRegistrationId();
  }

  Future<int> _getNextOneTimePreKeyId() async {
    return await _secureKeyStore.getNextOneTimePreKeyId();
  }

  Future<Map<String, dynamic>> _generateSignedPreKey(
    PrivateKey identityPrivateKey,
    int keyId,
  ) async {
    final signedPreKeyPrivate = PrivateKey.generate();
    final signedPreKeyPublic = signedPreKeyPrivate.getPublicKey();

    final signature = identityPrivateKey.sign(
      message: signedPreKeyPublic.serialize(),
    );

    final signedPreKey = SignedPreKeyRecord(
      id: keyId,
      timestamp: BigInt.from(DateTime.now().millisecondsSinceEpoch),
      publicKey: signedPreKeyPublic,
      privateKey: signedPreKeyPrivate,
      signature: signature,
    );

    return {
      'id': keyId,
      'record': signedPreKey,
      'publicKey': base64Encode(signedPreKeyPublic.serialize()),
      'privateKey': base64Encode(signedPreKeyPrivate.serialize()),
      'signature': base64Encode(signature),
    };
  }

  Future<List<Map<String, dynamic>>> _generateOneTimePreKeys(
    PrivateKey identityPrivateKey,
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

      preKeyList.add({
        'id': keyId,
        'record': preKeyRecord,
        'publicKey': base64Encode(preKeyPublic.serialize()),
      });
    }

    return preKeyList;
  }

  Future<Map<String, dynamic>?> _generateKyberPreKey(
    PrivateKey identityPrivateKey,
    int keyId,
  ) async {
    try {
      final kyberKeyPair = KyberKeyPair.generate();
      final kyberPublicKey = kyberKeyPair.getPublicKey();

      final signature = identityPrivateKey.sign(
        message: kyberPublicKey.serialize(),
      );

      final kyberPreKey = KyberPreKeyRecord.create(
        id: keyId,
        timestamp: BigInt.from(DateTime.now().millisecondsSinceEpoch),
        keyPair: kyberKeyPair,
        signature: signature,
      );

      return {
        'id': keyId,
        'record': kyberPreKey,
        'publicKey': base64Encode(kyberPublicKey.serialize()),
        'signature': base64Encode(signature),
      };
    } catch (e) {
      return null;
    }
  }
}

final deviceRegistrationServiceProvider =
    FutureProvider<DeviceRegistrationService>((ref) async {
  final secureKeyStore = ref.watch(secureKeyStoreProvider);
  final bundle = await ref.watch(signalStoreBundleProvider.future);
  final apiClient = ref.watch(apiClientProvider);
  final keyRepository = KeyRepository(apiClient: apiClient);

  return DeviceRegistrationService(
    secureKeyStore: secureKeyStore,
    bundle: bundle,
    keyRepository: keyRepository,
  );
});

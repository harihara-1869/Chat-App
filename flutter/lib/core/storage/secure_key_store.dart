import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'database/database_provider.dart';

const _identityPrivateKeyStorageKey = 'identity_private_key';
const _identityPublicKeyStorageKey = 'identity_public_key';
const _registrationIdStorageKey = 'registration_id';
const _nextOneTimePreKeyIdStorageKey = 'next_onetime_prekey_id';
const _nextKyberPreKeyIdStorageKey = 'next_kyber_prekey_id';
const _currentKyberPreKeyIdStorageKey = 'current_kyber_prekey_id';
const _kyberPreKeyRotatedAtStorageKey = 'kyber_prekey_rotated_at';
const _remoteIdentityTrustPrefix = 'remote_identity_trust';

class SecureKeyStore {
  final FlutterSecureStorage _storage;

  SecureKeyStore(this._storage);

  Future<bool> hasIdentityKey() async {
    final key = await _storage.read(key: _identityPrivateKeyStorageKey);
    return key != null;
  }

  Future<void> storeIdentityKeyPair({
    required Uint8List privateKey,
    required Uint8List publicKey,
  }) async {
    await _storage.write(
      key: _identityPrivateKeyStorageKey,
      value: base64Encode(privateKey),
    );
    await _storage.write(
      key: _identityPublicKeyStorageKey,
      value: base64Encode(publicKey),
    );
  }

  Future<Uint8List> getIdentityPrivateKey() async {
    final key = await _storage.read(key: _identityPrivateKeyStorageKey);
    if (key == null) {
      throw Exception('Identity private key not found');
    }
    return base64Decode(key);
  }

  Future<Uint8List> getIdentityPublicKey() async {
    final key = await _storage.read(key: _identityPublicKeyStorageKey);
    if (key == null) {
      throw Exception('Identity public key not found');
    }
    return base64Decode(key);
  }

  Future<void> storeRegistrationId(int id) async {
    await _storage.write(
      key: _registrationIdStorageKey,
      value: id.toString(),
    );
  }

  Future<int> getRegistrationId() async {
    final id = await _storage.read(key: _registrationIdStorageKey);
    if (id == null) {
      throw Exception('Registration ID not found');
    }
    return int.parse(id);
  }

  Future<Uint8List> getOrCreateDbEncryptionKey() async {
    final key = await _storage.read(key: 'db_encryption_key');
    if (key != null) {
      return base64Decode(key);
    }

    final newKey = _generateSecureKey();
    await _storage.write(
      key: 'db_encryption_key',
      value: base64Encode(newKey),
    );
    return newKey;
  }

  Future<void> storeNextOneTimePreKeyId(int id) async {
    await _storage.write(
      key: _nextOneTimePreKeyIdStorageKey,
      value: id.toString(),
    );
  }

  Future<int> getNextOneTimePreKeyId() async {
    final id = await _storage.read(key: _nextOneTimePreKeyIdStorageKey);
    if (id == null) {
      return 0;
    }
    return int.parse(id);
  }

  Future<void> storeNextKyberPreKeyId(int id) async {
    await _storage.write(
      key: _nextKyberPreKeyIdStorageKey,
      value: id.toString(),
    );
  }

  Future<int> getNextKyberPreKeyId() async {
    final id = await _storage.read(key: _nextKyberPreKeyIdStorageKey);
    if (id == null) {
      return 1;
    }
    return int.parse(id);
  }

  Future<void> storeCurrentKyberPreKeyId(int id) async {
    await _storage.write(
      key: _currentKyberPreKeyIdStorageKey,
      value: id.toString(),
    );
  }

  Future<int?> getCurrentKyberPreKeyId() async {
    final id = await _storage.read(key: _currentKyberPreKeyIdStorageKey);
    if (id == null) {
      return null;
    }
    return int.parse(id);
  }

  Future<void> storeKyberPreKeyRotatedAt(DateTime rotatedAt) async {
    await _storage.write(
      key: _kyberPreKeyRotatedAtStorageKey,
      value: rotatedAt.toIso8601String(),
    );
  }

  Future<DateTime?> getKyberPreKeyRotatedAt() async {
    final rotatedAt = await _storage.read(key: _kyberPreKeyRotatedAtStorageKey);
    if (rotatedAt == null) {
      return null;
    }
    return DateTime.parse(rotatedAt);
  }

  String _remoteIdentityTrustKey(String addressName, int deviceId) {
    return '$_remoteIdentityTrustPrefix:$addressName:$deviceId';
  }

  Future<Map<String, dynamic>?> getRemoteIdentityTrustState(
    String addressName,
    int deviceId,
  ) async {
    final value = await _storage.read(
      key: _remoteIdentityTrustKey(addressName, deviceId),
    );
    if (value == null) {
      return null;
    }
    return jsonDecode(value) as Map<String, dynamic>;
  }

  Future<void> storeRemoteIdentityTrustState(
    String addressName,
    int deviceId,
    Map<String, dynamic> state,
  ) async {
    await _storage.write(
      key: _remoteIdentityTrustKey(addressName, deviceId),
      value: jsonEncode(state),
    );
  }

  Uint8List _generateSecureKey() {
    final random = Random.secure();
    final key = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      key[i] = random.nextInt(256);
    }
    return key;
  }
}

final secureKeyStoreProvider = Provider<SecureKeyStore>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return SecureKeyStore(storage);
});

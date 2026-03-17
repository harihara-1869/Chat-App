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
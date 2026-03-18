import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libsignal/libsignal.dart';

import 'database/app_database.dart';
import 'database/database_provider.dart';
import 'secure_key_store.dart';

class DriftIdentityKeyStore implements IdentityKeyStore {
  final AppDatabase _db;
  final SecureKeyStore _secureKeyStore;

  DriftIdentityKeyStore(this._db, this._secureKeyStore);

  @override
  Future<IdentityKeyPair> getIdentityKeyPair() async {
    final privateKeyBytes = await _secureKeyStore.getIdentityPrivateKey();
    final publicKeyBytes = await _secureKeyStore.getIdentityPublicKey();

    final privateKey = PrivateKey.deserialize(bytes: privateKeyBytes);
    final publicKey = PublicKey.deserialize(bytes: publicKeyBytes);

    return IdentityKeyPair.fromKeys(
      privateKey: privateKey,
      publicKey: publicKey,
    );
  }

  @override
  Future<int> getLocalRegistrationId() async {
    return await _secureKeyStore.getRegistrationId();
  }

  @override
  Future<bool> saveIdentity(ProtocolAddress address, PublicKey identityKey) async {
    await _db.insertIdentityKey(
      addressName: address.name(),
      deviceId: address.deviceId(),
      identityKeyBytes: identityKey.serialize(),
    );
    return true;
  }

  @override
  Future<bool> isTrustedIdentity(
    ProtocolAddress address,
    PublicKey identityKey,
    Direction direction,
  ) async {
    final existingKey = await _db.getIdentityKey(address.name(), address.deviceId());
    
    if (existingKey == null) {
      return true;
    }

    final existingPublicKey = PublicKey.deserialize(bytes: existingKey);
    return existingPublicKey.serialize().toString() == identityKey.serialize().toString();
  }

  @override
  Future<PublicKey?> getIdentity(ProtocolAddress address) async {
    final keyBytes = await _db.getIdentityKey(address.name(), address.deviceId());
    if (keyBytes == null) return null;
    return PublicKey.deserialize(bytes: keyBytes);
  }
}

final driftIdentityKeyStoreProvider = FutureProvider<DriftIdentityKeyStore>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final secureKeyStore = ref.watch(secureKeyStoreProvider);
  return DriftIdentityKeyStore(db, secureKeyStore);
});

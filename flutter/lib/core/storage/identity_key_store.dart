import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libsignal/libsignal.dart';

import 'database/app_database.dart';
import 'database/database_provider.dart';
import '../signal/identity_trust_service.dart';
import 'secure_key_store.dart';

class DriftIdentityKeyStore implements IdentityKeyStore {
  final AppDatabase _db;
  final SecureKeyStore _secureKeyStore;
  final IdentityTrustService _identityTrustService;

  DriftIdentityKeyStore(
    this._db,
    this._secureKeyStore,
    this._identityTrustService,
  );

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
    final observation = await _identityTrustService.observeIdentity(
      address,
      identityKey,
    );
    await _db.insertIdentityKey(
      addressName: address.name(),
      deviceId: address.deviceId(),
      identityKeyBytes: identityKey.serialize(),
    );
    return observation != IdentityObservationType.unchanged;
  }

  @override
  Future<bool> isTrustedIdentity(
    ProtocolAddress address,
    PublicKey identityKey,
    Direction direction,
  ) async {
    return _identityTrustService.isTrustedIdentity(
      address,
      identityKey,
      direction,
    );
  }

  @override
  Future<PublicKey?> getIdentity(ProtocolAddress address) async {
    final keyBytes = await _db.getIdentityKey(address.name(), address.deviceId());
    if (keyBytes == null) return null;
    return PublicKey.deserialize(bytes: keyBytes);
  }

  Stream<IdentityChangeEvent> get onIdentityChange => _identityTrustService.events;

  Future<RemoteIdentityTrustState?> getIdentityTrustState(
    ProtocolAddress address,
  ) {
    return _identityTrustService.getState(address);
  }

  Future<void> verifyCurrentIdentity(ProtocolAddress address) {
    return _identityTrustService.verifyCurrentIdentity(address);
  }

  Future<SafetyNumber> generateSafetyNumber(
    ProtocolAddress address, {
    PublicKey? remoteIdentityKey,
  }) {
    return _identityTrustService.generateSafetyNumber(
      address,
      remoteIdentityKey: remoteIdentityKey,
    );
  }
}

final driftIdentityKeyStoreProvider = FutureProvider<DriftIdentityKeyStore>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final secureKeyStore = ref.watch(secureKeyStoreProvider);
  final identityTrustService = ref.watch(identityTrustServiceProvider);
  return DriftIdentityKeyStore(db, secureKeyStore, identityTrustService);
});

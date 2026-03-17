import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libsignal/libsignal.dart';

import 'database/app_database.dart';
import 'database/database_provider.dart';

class DriftSignedPreKeyStore implements SignedPreKeyStore {
  final AppDatabase _db;

  DriftSignedPreKeyStore(this._db);

  @override
  Future<SignedPreKeyRecord> loadSignedPreKey(int signedPreKeyId) async {
    final recordBytes = await _db.getSignedPreKey(signedPreKeyId);
    if (recordBytes == null) {
      throw Exception('SignedPreKey not found: $signedPreKeyId');
    }
    return SignedPreKeyRecord.deserialize(bytes: recordBytes);
  }

  @override
  Future<void> storeSignedPreKey(int signedPreKeyId, SignedPreKeyRecord record) async {
    await _db.insertSignedPreKey(
      signedPreKeyId: signedPreKeyId,
      recordBytes: record.serialize(),
    );
  }

  @override
  Future<bool> containsSignedPreKey(int signedPreKeyId) async {
    final record = await _db.getSignedPreKey(signedPreKeyId);
    return record != null;
  }

  @override
  Future<List<int>> getAllSignedPreKeyIds() async {
    final results = await _db.getAllSignedPreKeyIds();
    return results;
  }

  @override
  Future<void> removeSignedPreKey(int signedPreKeyId) async {
    await _db.deleteSignedPreKey(signedPreKeyId);
  }
}

final driftSignedPreKeyStoreProvider = Provider<DriftSignedPreKeyStore>((ref) {
  final db = ref.watch(appDatabaseProvider).value;
  if (db == null) {
    throw StateError('AppDatabase not initialized');
  }
  return DriftSignedPreKeyStore(db);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libsignal/libsignal.dart';

import 'database/app_database.dart';
import 'database/database_provider.dart';

class DriftKyberPreKeyStore implements KyberPreKeyStore {
  final AppDatabase _db;

  DriftKyberPreKeyStore(this._db);

  @override
  Future<KyberPreKeyRecord?> loadKyberPreKey(int kyberPreKeyId) async {
    final recordBytes = await _db.getKyberPreKey(kyberPreKeyId);
    if (recordBytes == null) return null;
    return KyberPreKeyRecord.deserialize(bytes: recordBytes);
  }

  @override
  Future<void> storeKyberPreKey(int kyberPreKeyId, KyberPreKeyRecord record) async {
    await _db.insertKyberPreKey(
      kyberPreKeyId: kyberPreKeyId,
      recordBytes: record.serialize(),
    );
  }

  @override
  Future<void> markKyberPreKeyUsed(int kyberPreKeyId) async {
    await _db.markKyberPreKeyUsed(kyberPreKeyId);
  }

  @override
  Future<bool> containsKyberPreKey(int kyberPreKeyId) async {
    final record = await _db.getKyberPreKey(kyberPreKeyId);
    return record != null;
  }

  @override
  Future<List<int>> getAllKyberPreKeyIds() async {
    final results = await _db.getAllKyberPreKeyIds();
    return results;
  }

  @override
  Future<void> removeKyberPreKey(int kyberPreKeyId) async {
    await _db.deleteKyberPreKey(kyberPreKeyId);
  }
}

final driftKyberPreKeyStoreProvider = FutureProvider<DriftKyberPreKeyStore>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return DriftKyberPreKeyStore(db);
});

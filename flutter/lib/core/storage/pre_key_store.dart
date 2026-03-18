import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libsignal/libsignal.dart';

import 'database/app_database.dart';
import 'database/database_provider.dart';

class DriftPreKeyStore implements PreKeyStore {
  final AppDatabase _db;

  DriftPreKeyStore(this._db);

  @override
  Future<PreKeyRecord> loadPreKey(int preKeyId) async {
    final recordBytes = await _db.getPreKey(preKeyId);
    if (recordBytes == null) {
      throw Exception('PreKey not found: $preKeyId');
    }
    return PreKeyRecord.deserialize(bytes: recordBytes);
  }

  @override
  Future<void> storePreKey(int preKeyId, PreKeyRecord record) async {
    await _db.insertPreKey(
      preKeyId: preKeyId,
      recordBytes: record.serialize(),
    );
  }

  @override
  Future<void> removePreKey(int preKeyId) async {
    await _db.deletePreKey(preKeyId);
  }

  @override
  Future<bool> containsPreKey(int preKeyId) async {
    final record = await _db.getPreKey(preKeyId);
    return record != null;
  }

  @override
  Future<List<int>> getAllPreKeyIds() async {
    final keys = await _db.getAllPreKeyIds();
    return keys;
  }
}

final driftPreKeyStoreProvider = FutureProvider<DriftPreKeyStore>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return DriftPreKeyStore(db);
});

import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'database/database_provider.dart';

abstract class SkippedKeysStore {
  Future<void> storeSkippedKey({
    required String senderId,
    required Uint8List ratchetKey,
    required int messageIndex,
    required Uint8List messageKey,
  });
  
  Future<Uint8List?> consumeSkippedKey({
    required String senderId,
    required Uint8List ratchetKey,
    required int messageIndex,
  });
  
  Future<void> purgeExpiredKeys({Duration maxAge = const Duration(days: 30)});
}

class DriftSkippedKeysStore implements SkippedKeysStore {
  final AppDatabase _db;

  DriftSkippedKeysStore(this._db);

  @override
  Future<void> storeSkippedKey({
    required String senderId,
    required Uint8List ratchetKey,
    required int messageIndex,
    required Uint8List messageKey,
  }) async {
    final companion = SkippedMessageKeysCompanion(
      senderId: Value(senderId),
      ratchetKey: Value(ratchetKey),
      messageIndex: Value(messageIndex),
      messageKey: Value(messageKey),
      storedAt: Value(DateTime.now().millisecondsSinceEpoch),
    );

    await _db.insertSkippedKey(companion);
  }

  @override
  Future<Uint8List?> consumeSkippedKey({
    required String senderId,
    required Uint8List ratchetKey,
    required int messageIndex,
  }) async {
    final key = await _db.consumeSkippedKey(
      senderId: senderId,
      ratchetKey: ratchetKey,
      messageIndex: messageIndex,
    );

    return key?.messageKey;
  }

  @override
  Future<void> purgeExpiredKeys({Duration maxAge = const Duration(days: 30)}) async {
    final cutoff = DateTime.now().subtract(maxAge);
    await _db.purgeExpiredSkippedKeys(cutoff);
  }
}

final skippedKeysStoreProvider = FutureProvider<SkippedKeysStore>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return DriftSkippedKeysStore(db);
});
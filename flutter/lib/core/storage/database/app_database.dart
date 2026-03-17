import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Session table - stores serialized SessionRecord (Double Ratchet state)
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get addressName => text()();
  IntColumn get deviceId => integer()();
  BlobColumn get record => blob()();
  IntColumn get createdAt => integer()();
  IntColumn get lastUpdated => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {addressName, deviceId}
  ];
}

// Identity keys table - stores remote user's identity keys
class IdentityKeys extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get addressName => text()();
  IntColumn get deviceId => integer()();
  BlobColumn get identityKey => blob()();
  IntColumn get createdAt => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {addressName, deviceId}
  ];
}

// One-time pre-keys table
class PreKeys extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get preKeyId => integer().unique()();
  BlobColumn get record => blob()();
  IntColumn get createdAt => integer()();
}

// Signed pre-keys table
class SignedPreKeys extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get signedPreKeyId => integer().unique()();
  BlobColumn get record => blob()();
  IntColumn get createdAt => integer()();
}

// Kyber pre-keys table (for PQXDH)
class KyberPreKeys extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get kyberPreKeyId => integer().unique()();
  BlobColumn get record => blob()();
  BoolColumn get isUsed => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
}

// Skipped message keys (for out-of-order message decryption)
class SkippedMessageKeys extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get senderId => text()();
  BlobColumn get ratchetKey => blob()();
  IntColumn get messageIndex => integer()();
  BlobColumn get messageKey => blob()();
  IntColumn get storedAt => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {senderId, ratchetKey, messageIndex}
  ];
}

// Chat messages table
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text().unique()();
  TextColumn get conversationId => text()();
  TextColumn get senderId => text()();
  TextColumn get receiverId => text()();
  TextColumn get plaintext => text()();
  TextColumn get ciphertext => text()();
  TextColumn get type => text()();
  TextColumn get otherUserId => text()();
  IntColumn get createdAt => integer()();
}

@DriftDatabase(tables: [
  Sessions,
  IdentityKeys,
  PreKeys,
  SignedPreKeys,
  KyberPreKeys,
  SkippedMessageKeys,
  ChatMessages
])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(super.e);

  @override
  int get schemaVersion => 1;

  static Future<AppDatabase> connectDatabase(Uint8List encryptionKey) async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'chat_app_encrypted.db'));
    
    final keyString = String.fromCharCodes(encryptionKey);
    
    final executor = NativeDatabase(
      dbFile,
      setup: (database) {
        database.execute("PRAGMA key = '$keyString'");
      },
    );
    
    return AppDatabase._internal(executor);
  }

  /// Execute multiple operations in a single transaction
  Future<T> runInTransaction<T>(Future<T> Function(AppDatabase db) action) async {
    return await transaction(() => action(this));
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
    );
  }

  // ==================== Session Operations ====================
  
  Future<Session?> getSession(String addressName, int deviceId) {
    return (select(sessions)
      ..where((s) => s.addressName.equals(addressName) & s.deviceId.equals(deviceId)))
        .getSingleOrNull();
  }

  Future<bool> hasSession(String addressName, int deviceId) async {
    final session = await getSession(addressName, deviceId);
    return session != null;
  }

  Future<int> insertSession({
    required String addressName,
    required int deviceId,
    required Uint8List recordBytes,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(sessions).insert(
      SessionsCompanion(
        addressName: Value(addressName),
        deviceId: Value(deviceId),
        record: Value(recordBytes),
        createdAt: Value(now),
        lastUpdated: Value(now),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<int> deleteSession(String addressName, int deviceId) {
    return (delete(sessions)
      ..where((s) => s.addressName.equals(addressName) & s.deviceId.equals(deviceId)))
        .go();
  }

  Future<int> deleteAllSessionsForName(String addressName) {
    return (delete(sessions)..where((s) => s.addressName.equals(addressName))).go();
  }

  Future<List<int>> getSubDeviceSessions(String addressName) async {
    final results = await (select(sessions)
      ..where((s) => s.addressName.equals(addressName)))
        .get();
    return results.map((row) => row.deviceId).toList();
  }

  // ==================== Identity Key Operations ====================

  Future<int> insertIdentityKey({
    required String addressName,
    required int deviceId,
    required Uint8List identityKeyBytes,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(identityKeys).insert(
      IdentityKeysCompanion(
        addressName: Value(addressName),
        deviceId: Value(deviceId),
        identityKey: Value(identityKeyBytes),
        createdAt: Value(now),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<Uint8List?> getIdentityKey(String addressName, int deviceId) async {
    final result = await (select(identityKeys)
      ..where((k) => k.addressName.equals(addressName) & k.deviceId.equals(deviceId)))
        .getSingleOrNull();
    return result?.identityKey;
  }

  Future<int> deleteIdentityKey(String addressName, int deviceId) {
    return (delete(identityKeys)
      ..where((k) => k.addressName.equals(addressName) & k.deviceId.equals(deviceId)))
        .go();
  }

  // ==================== PreKey Operations ====================

  Future<int> insertPreKey({
    required int preKeyId,
    required Uint8List recordBytes,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(preKeys).insert(
      PreKeysCompanion(
        preKeyId: Value(preKeyId),
        record: Value(recordBytes),
        createdAt: Value(now),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<Uint8List?> getPreKey(int preKeyId) async {
    final result = await (select(preKeys)
      ..where((p) => p.preKeyId.equals(preKeyId)))
        .getSingleOrNull();
    return result?.record;
  }

  Future<int> deletePreKey(int preKeyId) {
    return (delete(preKeys)..where((p) => p.preKeyId.equals(preKeyId))).go();
  }

  Future<List<int>> getAllPreKeyIds() async {
    final results = await select(preKeys).get();
    return results.map((row) => row.preKeyId).toList();
  }

  // ==================== Signed PreKey Operations ====================

  Future<int> insertSignedPreKey({
    required int signedPreKeyId,
    required Uint8List recordBytes,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(signedPreKeys).insert(
      SignedPreKeysCompanion(
        signedPreKeyId: Value(signedPreKeyId),
        record: Value(recordBytes),
        createdAt: Value(now),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<Uint8List?> getSignedPreKey(int signedPreKeyId) async {
    final result = await (select(signedPreKeys)
      ..where((p) => p.signedPreKeyId.equals(signedPreKeyId)))
        .getSingleOrNull();
    return result?.record;
  }

  Future<List<int>> getAllSignedPreKeyIds() async {
    final results = await select(signedPreKeys).get();
    return results.map((row) => row.signedPreKeyId).toList();
  }

  Future<int> deleteSignedPreKey(int signedPreKeyId) {
    return (delete(signedPreKeys)..where((p) => p.signedPreKeyId.equals(signedPreKeyId))).go();
  }

  // ==================== Kyber PreKey Operations ====================

  Future<int> insertKyberPreKey({
    required int kyberPreKeyId,
    required Uint8List recordBytes,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(kyberPreKeys).insert(
      KyberPreKeysCompanion(
        kyberPreKeyId: Value(kyberPreKeyId),
        record: Value(recordBytes),
        isUsed: const Value(false),
        createdAt: Value(now),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<Uint8List?> getKyberPreKey(int kyberPreKeyId) async {
    final result = await (select(kyberPreKeys)
      ..where((k) => k.kyberPreKeyId.equals(kyberPreKeyId) & k.isUsed.equals(false)))
        .getSingleOrNull();
    return result?.record;
  }

  Future<int> markKyberPreKeyUsed(int kyberPreKeyId) {
    return (update(kyberPreKeys)
      ..where((k) => k.kyberPreKeyId.equals(kyberPreKeyId)))
        .write(const KyberPreKeysCompanion(isUsed: Value(true)));
  }

  Future<List<int>> getAllKyberPreKeyIds() async {
    final results = await select(kyberPreKeys).get();
    return results.map((row) => row.kyberPreKeyId).toList();
  }

  Future<int> deleteKyberPreKey(int kyberPreKeyId) {
    return (delete(kyberPreKeys)..where((k) => k.kyberPreKeyId.equals(kyberPreKeyId))).go();
  }

  // ==================== Skipped Keys Operations ====================

  Future<int> insertSkippedKey(SkippedMessageKeysCompanion key) {
    return into(skippedMessageKeys).insert(key, mode: InsertMode.insertOrIgnore);
  }

  Future<SkippedMessageKey?> consumeSkippedKey({
    required String senderId,
    required Uint8List ratchetKey,
    required int messageIndex,
  }) async {
    final query = select(skippedMessageKeys)
      ..where((k) => k.senderId.equals(senderId) & k.ratchetKey.equals(ratchetKey) & k.messageIndex.equals(messageIndex));
    
    final key = await query.getSingleOrNull();
    if (key != null) {
      await (delete(skippedMessageKeys)..where((k) => k.id.equals(key.id))).go();
    }
    return key;
  }

  Future<int> purgeExpiredSkippedKeys(DateTime cutoffTime) {
    return (delete(skippedMessageKeys)..where((k) => k.storedAt.isSmallerThanValue(cutoffTime.millisecondsSinceEpoch))).go();
  }

  // ==================== Message Operations ====================

  Future<int> insertMessage(ChatMessagesCompanion message) {
    return into(chatMessages).insert(message, mode: InsertMode.insertOrReplace);
  }

  Future<List<ChatMessage>> getMessages(String otherUserId) {
    return (select(chatMessages)
      ..where((m) => m.otherUserId.equals(otherUserId))
      ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
  }

  Future<int> deleteMessage(String messageId) {
    return (delete(chatMessages)..where((m) => m.messageId.equals(messageId))).go();
  }

  Future<int> clearMessages(String otherUserId) {
    return (delete(chatMessages)..where((m) => m.otherUserId.equals(otherUserId))).go();
  }

  // ==================== Cleanup ====================

  Future<int> deleteAllData() async {
    await delete(sessions).go();
    await delete(identityKeys).go();
    await delete(preKeys).go();
    await delete(signedPreKeys).go();
    await delete(kyberPreKeys).go();
    await delete(skippedMessageKeys).go();
    await delete(chatMessages).go();
    return 0;
  }
}

Uint8List generateDbEncryptionKey() {
  final random = Random.secure();
  final key = Uint8List(32);
  for (int i = 0; i < 32; i++) {
    key[i] = random.nextInt(256);
  }
  return key;
}
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/app_database.dart';
import '../../errors/storage_failures.dart';

const _dbEncryptionKeyStorageKey = 'db_encryption_key';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
});

final dbEncryptionKeyProvider = FutureProvider<Uint8List>((ref) async {
  final secureStorage = ref.watch(secureStorageProvider);
  
  final storedKey = await secureStorage.read(key: _dbEncryptionKeyStorageKey);
  
  if (storedKey != null) {
    return base64Decode(storedKey);
  }
  
  final newKey = generateDbEncryptionKey();
  final encodedKey = base64Encode(newKey);
  await secureStorage.write(key: _dbEncryptionKeyStorageKey, value: encodedKey);
  
  return newKey;
});

final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final encryptionKey = await ref.watch(dbEncryptionKeyProvider.future);
  
  try {
    final db = await AppDatabase.connectDatabase(encryptionKey);
    return db;
  } catch (e) {
    throw DbOpenFailure(e.toString());
  }
});

final databaseInitializedProvider = FutureProvider<bool>((ref) async {
  try {
    final db = await ref.watch(appDatabaseProvider.future);
    return true;
  } catch (e) {
    return false;
  }
});
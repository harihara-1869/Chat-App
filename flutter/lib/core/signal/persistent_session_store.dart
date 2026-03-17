import 'dart:convert';
import 'dart:typed_data';

import 'package:libsignal/libsignal.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/constants.dart';

class PersistentSessionStore implements SessionStore {
  final FlutterSecureStorage _storage;
  final Map<String, SessionRecord> _cache = {};

  PersistentSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  String _getKey(ProtocolAddress address) {
    return '${StorageKeys.signalSessions}_${address.name}_${address.deviceId}';
  }

  Future<void> _loadAllSessions() async {
    final allData = await _storage.readAll();
    for (final entry in allData.entries) {
      if (entry.key.startsWith(StorageKeys.signalSessions)) {
        try {
          final data = base64Decode(entry.value);
          final record = SessionRecord.deserialize(bytes: data);
          final parts = entry.key.replaceFirst(StorageKeys.signalSessions, '').split('_');
          if (parts.length >= 2) {
            final name = parts[0];
            final deviceId = int.tryParse(parts[1]) ?? 1;
            _cache['$name:$deviceId'] = record;
          }
        } catch (e) {
          // Invalid session data, skip
        }
      }
    }
  }

  @override
  Future<SessionRecord?> loadSession(ProtocolAddress address) async {
    final key = '${address.name}:${address.deviceId}';
    
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      final stored = await _storage.read(key: _getKey(address));
      if (stored != null) {
        final record = SessionRecord.deserialize(bytes: base64Decode(stored));
        _cache[key] = record;
        return record;
      }
    } catch (e) {
      // Session not found or corrupted
    }
    
    return null;
  }

  @override
  Future<void> storeSession(ProtocolAddress address, SessionRecord record) async {
    final key = '${address.name}:${address.deviceId}';
    _cache[key] = record;

    final serialized = record.serialize();
    await _storage.write(
      key: _getKey(address),
      value: base64Encode(serialized),
    );
  }

  @override
  Future<bool> containsSession(ProtocolAddress address) async {
    final key = '${address.name}:${address.deviceId}';
    
    if (_cache.containsKey(key)) {
      return true;
    }

    final stored = await _storage.read(key: _getKey(address));
    return stored != null;
  }

  @override
  Future<void> deleteSession(ProtocolAddress address) async {
    final key = '${address.name}:${address.deviceId}';
    _cache.remove(key);
    await _storage.delete(key: _getKey(address));
  }

  @override
  Future<void> deleteAllSessions(String name) async {
    final keysToDelete = <String>[];
    
    for (final key in _cache.keys.toList()) {
      if (key.startsWith('$name:')) {
        keysToDelete.add(key);
      }
    }
    
    for (final key in keysToDelete) {
      _cache.remove(key);
    }

    // Delete from storage
    final allData = await _storage.readAll();
    for (final entry in allData.entries) {
      if (entry.key.startsWith('${StorageKeys.signalSessions}_$name')) {
        await _storage.delete(key: entry.key);
      }
    }
  }

  @override
  Future<List<int>> getSubDeviceSessions(String name) async {
    final deviceIds = <int>[];
    
    for (final key in _cache.keys) {
      if (key.startsWith('$name:')) {
        final parts = key.split(':');
        if (parts.length >= 2) {
          final deviceId = int.tryParse(parts[1]);
          if (deviceId != null) {
            deviceIds.add(deviceId);
          }
        }
      }
    }

    // Also check storage
    final allData = await _storage.readAll();
    for (final entry in allData.entries) {
      if (entry.key.startsWith('${StorageKeys.signalSessions}_${name}_')) {
        final parts = entry.key.split('_');
        if (parts.length >= 3) {
          final deviceId = int.tryParse(parts[2]);
          if (deviceId != null && !deviceIds.contains(deviceId)) {
            deviceIds.add(deviceId);
          }
        }
      }
    }

    return deviceIds;
  }

  Future<void> clearAll() async {
    _cache.clear();
    final allData = await _storage.readAll();
    for (final entry in allData.entries) {
      if (entry.key.startsWith(StorageKeys.signalSessions)) {
        await _storage.delete(key: entry.key);
      }
    }
  }
}
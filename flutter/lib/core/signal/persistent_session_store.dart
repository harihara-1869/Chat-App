import 'dart:convert';
import 'dart:typed_data';

import 'package:libsignal/libsignal.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/constants.dart';

class _PersistentSessionCacheEntry {
  SessionRecord record;
  DateTime lastAccessedAt;

  _PersistentSessionCacheEntry({
    required this.record,
    required this.lastAccessedAt,
  });
}

class PersistentSessionStore implements SessionStore {
  final FlutterSecureStorage _storage;
  final Map<String, _PersistentSessionCacheEntry> _cache = {};
  final Duration _cacheTtl;
  final int _maxCacheEntries;
  final DateTime Function() _now;

  PersistentSessionStore({
    FlutterSecureStorage? storage,
    Duration cacheTtl = const Duration(minutes: 15),
    int maxCacheEntries = 256,
    DateTime Function()? now,
  })  : _cacheTtl = cacheTtl,
        _maxCacheEntries = maxCacheEntries,
        _now = now ?? DateTime.now,
        _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  void _pruneExpiredEntries() {
    final cutoff = _now().subtract(_cacheTtl);
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.lastAccessedAt.isBefore(cutoff))
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }

  void _cacheSession(String key, SessionRecord record) {
    _pruneExpiredEntries();
    _cache[key] = _PersistentSessionCacheEntry(
      record: record,
      lastAccessedAt: _now(),
    );

    while (_cache.length > _maxCacheEntries) {
      final oldestEntry = _cache.entries.reduce((a, b) {
        return a.value.lastAccessedAt.isBefore(b.value.lastAccessedAt) ? a : b;
      });
      _cache.remove(oldestEntry.key);
    }
  }

  SessionRecord? _getCachedSession(String key) {
    _pruneExpiredEntries();
    final entry = _cache[key];
    if (entry == null) {
      return null;
    }

    entry.lastAccessedAt = _now();
    return entry.record;
  }

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
          final parts = entry.key
              .replaceFirst('${StorageKeys.signalSessions}_', '')
              .split('_');
          if (parts.length >= 2) {
            final name = parts.sublist(0, parts.length - 1).join('_');
            final deviceId = int.tryParse(parts.last) ?? 1;
            _cacheSession('$name:$deviceId', record);
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

    final cached = _getCachedSession(key);
    if (cached != null) {
      return cached;
    }

    try {
      final stored = await _storage.read(key: _getKey(address));
      if (stored != null) {
        final record = SessionRecord.deserialize(bytes: base64Decode(stored));
        _cacheSession(key, record);
        return record;
      }
    } catch (e) {
      // Session not found or corrupted
    }

    return null;
  }

  @override
  Future<void> storeSession(
      ProtocolAddress address, SessionRecord record) async {
    final key = '${address.name}:${address.deviceId}';
    _cacheSession(key, record);

    final serialized = record.serialize();
    await _storage.write(
      key: _getKey(address),
      value: base64Encode(serialized),
    );
  }

  @override
  Future<bool> containsSession(ProtocolAddress address) async {
    final key = '${address.name}:${address.deviceId}';

    if (_getCachedSession(key) != null) {
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
    _pruneExpiredEntries();
    final deviceIds = <int>{};

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
        final deviceId = int.tryParse(entry.key.split('_').last);
        if (deviceId != null) {
          deviceIds.add(deviceId);
        }
      }
    }

    return deviceIds.toList(growable: false);
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libsignal/libsignal.dart';

import 'database/app_database.dart';
import 'database/database_provider.dart';

class _SessionCacheEntry {
  SessionRecord record;
  DateTime lastAccessedAt;

  _SessionCacheEntry({
    required this.record,
    required this.lastAccessedAt,
  });
}

class DriftSignalSessionStore implements SessionStore {
  final AppDatabase _db;
  final Map<String, _SessionCacheEntry> _cache = {};
  final Duration _cacheTtl;
  final int _maxCacheEntries;
  final DateTime Function() _now;

  DriftSignalSessionStore(
    this._db, {
    Duration cacheTtl = const Duration(minutes: 15),
    int maxCacheEntries = 256,
    DateTime Function()? now,
  }) : _cacheTtl = cacheTtl,
       _maxCacheEntries = maxCacheEntries,
       _now = now ?? DateTime.now;

  String _cacheKey(String name, int deviceId) => '$name:$deviceId';

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
    _cache[key] = _SessionCacheEntry(
      record: record,
      lastAccessedAt: _now(),
    );

    while (_cache.length > _maxCacheEntries) {
      final oldestEntry = _cache.entries.reduce(
        (a, b) => a.value.lastAccessedAt.isBefore(b.value.lastAccessedAt) ? a : b,
      );
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

  int get cacheSize => _cache.length;

  @override
  Future<SessionRecord?> loadSession(ProtocolAddress address) async {
    final key = _cacheKey(address.name(), address.deviceId());

    final cached = _getCachedSession(key);
    if (cached != null) {
      return cached;
    }

    final session = await _db.getSession(address.name(), address.deviceId());
    if (session == null) return null;

    final record = SessionRecord.deserialize(bytes: session.record);
    _cacheSession(key, record);
    return record;
  }

  @override
  Future<void> storeSession(ProtocolAddress address, SessionRecord record) async {
    final key = _cacheKey(address.name(), address.deviceId());
    _cacheSession(key, record);

    await _db.insertSession(
      addressName: address.name(),
      deviceId: address.deviceId(),
      recordBytes: record.serialize(),
    );
  }

  @override
  Future<bool> containsSession(ProtocolAddress address) async {
    final key = _cacheKey(address.name(), address.deviceId());

    if (_getCachedSession(key) != null) {
      return true;
    }

    return await _db.hasSession(address.name(), address.deviceId());
  }

  @override
  Future<void> deleteSession(ProtocolAddress address) async {
    final key = _cacheKey(address.name(), address.deviceId());
    _cache.remove(key);

    await _db.deleteSession(address.name(), address.deviceId());
  }

  @override
  Future<void> deleteAllSessions(String name) async {
    final keysToRemove = _cache.keys.where((k) => k.startsWith('$name:')).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }

    await _db.deleteAllSessionsForName(name);
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

    final dbDeviceIds = await _db.getSubDeviceSessions(name);
    deviceIds.addAll(dbDeviceIds);

    return deviceIds.toList();
  }

  Future<void> clearAll() async {
    _cache.clear();
    await _db.deleteAllSessionsForName('');
  }
}

final driftSessionStoreProvider = FutureProvider<DriftSignalSessionStore>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return DriftSignalSessionStore(db);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libsignal/libsignal.dart';

import 'database/app_database.dart';
import 'database/database_provider.dart';

class DriftSignalSessionStore implements SessionStore {
  final AppDatabase _db;
  final Map<String, SessionRecord> _cache = {};

  DriftSignalSessionStore(this._db);

  String _cacheKey(String name, int deviceId) => '$name:$deviceId';

  @override
  Future<SessionRecord?> loadSession(ProtocolAddress address) async {
    final key = _cacheKey(address.name(), address.deviceId());

    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    final session = await _db.getSession(address.name(), address.deviceId());
    if (session == null) return null;

    final record = SessionRecord.deserialize(bytes: session.record);
    _cache[key] = record;
    return record;
  }

  @override
  Future<void> storeSession(ProtocolAddress address, SessionRecord record) async {
    final key = _cacheKey(address.name(), address.deviceId());
    _cache[key] = record;

    await _db.insertSession(
      addressName: address.name(),
      deviceId: address.deviceId(),
      recordBytes: record.serialize(),
    );
  }

  @override
  Future<bool> containsSession(ProtocolAddress address) async {
    final key = _cacheKey(address.name(), address.deviceId());

    if (_cache.containsKey(key)) {
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

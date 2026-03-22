import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libsignal/libsignal.dart';

import '../storage/secure_key_store.dart';

enum IdentityObservationType {
  firstSeen,
  unchanged,
  changed,
}

class RemoteIdentityTrustState {
  final String addressName;
  final int deviceId;
  final String currentKey;
  final String? previousKey;
  final bool isVerified;
  final DateTime firstSeenAt;
  final DateTime lastUpdatedAt;
  final int changeCount;

  const RemoteIdentityTrustState({
    required this.addressName,
    required this.deviceId,
    required this.currentKey,
    this.previousKey,
    required this.isVerified,
    required this.firstSeenAt,
    required this.lastUpdatedAt,
    required this.changeCount,
  });

  RemoteIdentityTrustState copyWith({
    String? currentKey,
    String? previousKey,
    bool? isVerified,
    DateTime? firstSeenAt,
    DateTime? lastUpdatedAt,
    int? changeCount,
  }) {
    return RemoteIdentityTrustState(
      addressName: addressName,
      deviceId: deviceId,
      currentKey: currentKey ?? this.currentKey,
      previousKey: previousKey ?? this.previousKey,
      isVerified: isVerified ?? this.isVerified,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      changeCount: changeCount ?? this.changeCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressName': addressName,
      'deviceId': deviceId,
      'currentKey': currentKey,
      'previousKey': previousKey,
      'isVerified': isVerified,
      'firstSeenAt': firstSeenAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'changeCount': changeCount,
    };
  }

  factory RemoteIdentityTrustState.fromJson(Map<String, dynamic> json) {
    return RemoteIdentityTrustState(
      addressName: json['addressName'] as String,
      deviceId: json['deviceId'] as int,
      currentKey: json['currentKey'] as String,
      previousKey: json['previousKey'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      firstSeenAt: DateTime.parse(json['firstSeenAt'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
      changeCount: json['changeCount'] as int? ?? 0,
    );
  }
}

class IdentityChangeEvent {
  final ProtocolAddress address;
  final IdentityObservationType type;
  final RemoteIdentityTrustState state;

  const IdentityChangeEvent({
    required this.address,
    required this.type,
    required this.state,
  });
}

class SafetyNumber {
  final String displayString;
  final Uint8List scannableEncoding;

  const SafetyNumber({
    required this.displayString,
    required this.scannableEncoding,
  });
}

class IdentityTrustService {
  final SecureKeyStore _secureKeyStore;
  final String Function() _localIdentifierProvider;
  final DateTime Function() _now;
  final _events = StreamController<IdentityChangeEvent>.broadcast();

  IdentityTrustService({
    required SecureKeyStore secureKeyStore,
    String Function()? localIdentifierProvider,
    DateTime Function()? now,
  })  : _secureKeyStore = secureKeyStore,
        _localIdentifierProvider =
            localIdentifierProvider ?? (() => 'local-device'),
        _now = now ?? DateTime.now;

  Stream<IdentityChangeEvent> get events => _events.stream;

  Future<RemoteIdentityTrustState?> getState(ProtocolAddress address) async {
    final json = await _secureKeyStore.getRemoteIdentityTrustState(
      address.name(),
      address.deviceId(),
    );
    if (json == null) {
      return null;
    }
    return RemoteIdentityTrustState.fromJson(json);
  }

  Future<IdentityObservationType> observeIdentity(
    ProtocolAddress address,
    PublicKey identityKey,
  ) async {
    final encodedKey = base64Encode(identityKey.serialize());
    final existing = await getState(address);
    final now = _now();

    if (existing == null) {
      final state = RemoteIdentityTrustState(
        addressName: address.name(),
        deviceId: address.deviceId(),
        currentKey: encodedKey,
        isVerified: false,
        firstSeenAt: now,
        lastUpdatedAt: now,
        changeCount: 0,
      );
      await _persist(address, state);
      _events.add(
        IdentityChangeEvent(
          address: address,
          type: IdentityObservationType.firstSeen,
          state: state,
        ),
      );
      return IdentityObservationType.firstSeen;
    }

    if (existing.currentKey == encodedKey) {
      return IdentityObservationType.unchanged;
    }

    final updated = existing.copyWith(
      previousKey: existing.currentKey,
      currentKey: encodedKey,
      isVerified: false,
      lastUpdatedAt: now,
      changeCount: existing.changeCount + 1,
    );
    await _persist(address, updated);
    _events.add(
      IdentityChangeEvent(
        address: address,
        type: IdentityObservationType.changed,
        state: updated,
      ),
    );
    return IdentityObservationType.changed;
  }

  Future<bool> isTrustedIdentity(
    ProtocolAddress address,
    PublicKey identityKey,
    Direction direction,
  ) async {
    final existing = await getState(address);
    if (existing == null) {
      // Preserve compatibility for first contact while still requiring
      // explicit verification state to be tracked separately.
      return true;
    }

    final encodedKey = base64Encode(identityKey.serialize());
    if (existing.currentKey != encodedKey) {
      return false;
    }

    return true;
  }

  Future<void> verifyCurrentIdentity(ProtocolAddress address) async {
    final state = await getState(address);
    if (state == null) {
      throw StateError('No identity available to verify for ${address.name()}');
    }
    await _persist(
        address, state.copyWith(isVerified: true, lastUpdatedAt: _now()));
  }

  Future<SafetyNumber> generateSafetyNumber(
    ProtocolAddress address, {
    PublicKey? remoteIdentityKey,
  }) async {
    final localPublicKey = await _secureKeyStore.getIdentityPublicKey();
    final remoteKeyBytes = remoteIdentityKey?.serialize() ??
        base64Decode((await getState(address))!.currentKey);

    final fingerprint = Fingerprint(
      iterations: 5200,
      version: 1,
      localIdentifier: utf8.encode(_localIdentifierProvider()),
      localPublicKey: localPublicKey,
      remoteIdentifier: utf8.encode(address.name()),
      remotePublicKey: remoteKeyBytes,
    );

    return SafetyNumber(
      displayString: fingerprint.displayString(),
      scannableEncoding: fingerprint.scannableEncoding(),
    );
  }

  Future<void> _persist(
    ProtocolAddress address,
    RemoteIdentityTrustState state,
  ) async {
    await _secureKeyStore.storeRemoteIdentityTrustState(
      address.name(),
      address.deviceId(),
      state.toJson(),
    );
  }

  void dispose() {
    _events.close();
  }
}

final identityTrustServiceProvider = Provider<IdentityTrustService>((ref) {
  final secureKeyStore = ref.watch(secureKeyStoreProvider);
  final service = IdentityTrustService(secureKeyStore: secureKeyStore);
  ref.onDispose(service.dispose);
  return service;
});

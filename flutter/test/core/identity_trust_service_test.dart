import 'dart:convert';

import 'package:chat_app/core/signal/identity_trust_service.dart';
import 'package:chat_app/core/storage/secure_key_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libsignal/libsignal.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureKeyStore extends Mock implements SecureKeyStore {}

void main() {
  setUpAll(() async {
    await LibSignal.init();
    registerFallbackValue(<String, dynamic>{});
  });

  tearDownAll(() {
    LibSignal.cleanup();
  });

  group('IdentityTrustService', () {
    late _MockSecureKeyStore secureKeyStore;
    late IdentityTrustService service;
    late PublicKey localIdentityKey;
    late ProtocolAddress remoteAddress;
    Map<String, dynamic>? persistedState;

    setUp(() {
      secureKeyStore = _MockSecureKeyStore();
      localIdentityKey = PrivateKey.generate().getPublicKey();
      remoteAddress = ProtocolAddress(name: 'alice', deviceId: 1);
      persistedState = null;

      when(() => secureKeyStore.getIdentityPublicKey()).thenAnswer(
        (_) async => localIdentityKey.serialize(),
      );
      when(
        () => secureKeyStore.getRemoteIdentityTrustState('alice', 1),
      ).thenAnswer((_) async => persistedState);
      when(
        () => secureKeyStore.storeRemoteIdentityTrustState(
          'alice',
          1,
          any(),
        ),
      ).thenAnswer((invocation) async {
        persistedState =
            Map<String, dynamic>.from(invocation.positionalArguments[2] as Map);
      });

      service = IdentityTrustService(
        secureKeyStore: secureKeyStore,
        localIdentifierProvider: () => 'local-user',
        now: () => DateTime.utc(2026, 3, 22),
      );
    });

    test('stores first seen identities and emits an event', () async {
      final remoteIdentity = PrivateKey.generate().getPublicKey();

      final eventFuture = service.events.first;
      final observation = await service.observeIdentity(
        remoteAddress,
        remoteIdentity,
      );
      final event = await eventFuture;

      expect(observation, IdentityObservationType.firstSeen);
      expect(event.type, IdentityObservationType.firstSeen);
      expect(event.state.isVerified, isFalse);
      expect(
        persistedState?['currentKey'],
        base64Encode(remoteIdentity.serialize()),
      );
    });

    test('rejects changed identities until they are explicitly re-verified',
        () async {
      final firstIdentity = PrivateKey.generate().getPublicKey();
      final changedIdentity = PrivateKey.generate().getPublicKey();

      await service.observeIdentity(remoteAddress, firstIdentity);
      expect(
        await service.isTrustedIdentity(
          remoteAddress,
          firstIdentity,
          Direction.sending,
        ),
        isTrue,
      );

      final eventFuture = service.events.first;
      final observation = await service.observeIdentity(
        remoteAddress,
        changedIdentity,
      );
      final event = await eventFuture;

      expect(observation, IdentityObservationType.changed);
      expect(event.type, IdentityObservationType.changed);
      expect(
        await service.isTrustedIdentity(
          remoteAddress,
          firstIdentity,
          Direction.sending,
        ),
        isFalse,
      );
      expect(
        await service.isTrustedIdentity(
          remoteAddress,
          changedIdentity,
          Direction.sending,
        ),
        isTrue,
      );
      expect(event.state.changeCount, 1);
      expect(event.state.isVerified, isFalse);
    });

    test('generates a stable safety number for the current identity state',
        () async {
      final remoteIdentity = PrivateKey.generate().getPublicKey();
      await service.observeIdentity(remoteAddress, remoteIdentity);

      final safetyNumber = await service.generateSafetyNumber(remoteAddress);

      expect(safetyNumber.displayString, isNotEmpty);
      expect(safetyNumber.scannableEncoding, isNotEmpty);
    });
  });
}

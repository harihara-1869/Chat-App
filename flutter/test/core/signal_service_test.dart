import 'dart:convert';

import 'package:chat_app/core/signal/signal_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libsignal/libsignal.dart';

void main() {
  setUpAll(() async {
    await LibSignal.init();
  });

  tearDownAll(() {
    LibSignal.cleanup();
  });

  group('SignalService.verifySignedPreKeySignature', () {
    test('accepts a valid signed pre-key bundle', () {
      final identityPrivateKey = PrivateKey.generate();
      final signedPreKeyPrivate = PrivateKey.generate();
      final signedPreKeyPublic = signedPreKeyPrivate.getPublicKey();
      final signature = identityPrivateKey.sign(
        message: signedPreKeyPublic.serialize(),
      );

      final isValid = SignalService.verifySignedPreKeySignature({
        'identityKey':
            base64Encode(identityPrivateKey.getPublicKey().serialize()),
        'signedPreKeyPublic': base64Encode(signedPreKeyPublic.serialize()),
        'signedPreKeySignature': base64Encode(signature),
      });

      expect(isValid, isTrue);
    });

    test('rejects a forged signed pre-key signature', () {
      final identityPrivateKey = PrivateKey.generate();
      final attackerPrivateKey = PrivateKey.generate();
      final signedPreKeyPrivate = PrivateKey.generate();
      final signedPreKeyPublic = signedPreKeyPrivate.getPublicKey();
      final forgedSignature = attackerPrivateKey.sign(
        message: signedPreKeyPublic.serialize(),
      );

      final isValid = SignalService.verifySignedPreKeySignature({
        'identityKey':
            base64Encode(identityPrivateKey.getPublicKey().serialize()),
        'signedPreKeyPublic': base64Encode(signedPreKeyPublic.serialize()),
        'signedPreKeySignature': base64Encode(forgedSignature),
      });

      expect(isValid, isFalse);
    });

    test('normalizes nested repository pre-key bundle shape', () {
      final normalized = SignalService.normalizePreKeyBundle({
        'registrationId': 7,
        'deviceId': 1,
        'identityKey': 'identity',
        'signedPreKey': {
          'keyId': 4,
          'publicKey': 'signed-public',
          'signature': 'signed-signature',
        },
        'oneTimePreKey': {
          'keyId': 9,
          'publicKey': 'prekey-public',
        },
        'kyberPreKey': {
          'keyId': 10,
          'publicKey': 'kyber-public',
          'signature': 'kyber-signature',
        },
      });

      expect(normalized['registrationId'], 7);
      expect(normalized['deviceId'], 1);
      expect(normalized['identityKey'], 'identity');
      expect(normalized['signedPreKeyId'], 4);
      expect(normalized['signedPreKeyPublic'], 'signed-public');
      expect(normalized['signedPreKeySignature'], 'signed-signature');
      expect(normalized['preKeyId'], 9);
      expect(normalized['preKeyPublicKey'], 'prekey-public');
      expect(normalized['kyberPreKeyId'], 10);
      expect(normalized['kyberPreKeyPublic'], 'kyber-public');
      expect(normalized['kyberPreKeySignature'], 'kyber-signature');
    });

    test('accepts a valid Kyber pre-key signature', () {
      final identityPrivateKey = PrivateKey.generate();
      final kyberPublicKey = KyberKeyPair.generate().getPublicKey();
      final signature = identityPrivateKey.sign(
        message: kyberPublicKey.serialize(),
      );

      final isValid = SignalService.verifyKyberPreKeySignature({
        'identityKey':
            base64Encode(identityPrivateKey.getPublicKey().serialize()),
        'kyberPreKeyPublic': base64Encode(kyberPublicKey.serialize()),
        'kyberPreKeySignature': base64Encode(signature),
      });

      expect(isValid, isTrue);
    });

    test('rejects a forged Kyber pre-key signature', () {
      final identityPrivateKey = PrivateKey.generate();
      final attackerPrivateKey = PrivateKey.generate();
      final kyberPublicKey = KyberKeyPair.generate().getPublicKey();
      final forgedSignature = attackerPrivateKey.sign(
        message: kyberPublicKey.serialize(),
      );

      final isValid = SignalService.verifyKyberPreKeySignature({
        'identityKey':
            base64Encode(identityPrivateKey.getPublicKey().serialize()),
        'kyberPreKeyPublic': base64Encode(kyberPublicKey.serialize()),
        'kyberPreKeySignature': base64Encode(forgedSignature),
      });

      expect(isValid, isFalse);
    });
  });
}

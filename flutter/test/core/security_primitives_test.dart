import 'dart:math';
import 'dart:typed_data';

import 'package:chat_app/core/signal/registration_id.dart';
import 'package:chat_app/core/services/device_registration_service.dart';
import 'package:chat_app/core/storage/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('generateSecureRegistrationId', () {
    test('returns values within the libsignal registration id range', () {
      final random = Random(1234);

      for (var i = 0; i < 100; i++) {
        final registrationId = generateSecureRegistrationId(random: random);
        expect(registrationId, inInclusiveRange(1, kMaxRegistrationId));
      }
    });

    test('does not collapse to a constant value for sequential draws', () {
      final random = Random(42);
      final values = List<int>.generate(
        10,
        (_) => generateSecureRegistrationId(random: random),
      );

      expect(values.toSet().length, greaterThan(1));
    });
  });

  group('AppDatabase.encodeEncryptionKeyForPragma', () {
    test('encodes raw key bytes as a SQLCipher hex literal', () {
      final key = Uint8List.fromList([0x00, 0x01, 0x0f, 0x10, 0xaa, 0xff]);

      final encoded = AppDatabase.encodeEncryptionKeyForPragma(key);

      expect(encoded, "x'00010f10aaff'");
    });

    test('preserves leading zero bytes', () {
      final key = Uint8List.fromList([0x00, 0x00, 0x01]);

      final encoded = AppDatabase.encodeEncryptionKeyForPragma(key);

      expect(encoded, "x'000001'");
    });
  });

  group('DeviceRegistrationService.shouldRotateKyberPreKey', () {
    test('rotates when no prior rotation timestamp exists', () {
      expect(
        DeviceRegistrationService.shouldRotateKyberPreKey(null),
        isTrue,
      );
    });

    test('does not rotate before the configured interval', () {
      final now = DateTime.utc(2026, 3, 22);
      final lastRotatedAt = now.subtract(const Duration(days: 29));

      expect(
        DeviceRegistrationService.shouldRotateKyberPreKey(
          lastRotatedAt,
          now: now,
        ),
        isFalse,
      );
    });

    test('rotates once the configured interval has elapsed', () {
      final now = DateTime.utc(2026, 3, 22);
      final lastRotatedAt = now.subtract(const Duration(days: 30));

      expect(
        DeviceRegistrationService.shouldRotateKyberPreKey(
          lastRotatedAt,
          now: now,
        ),
        isTrue,
      );
    });
  });
}

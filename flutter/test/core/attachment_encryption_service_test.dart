import 'dart:typed_data';

import 'package:chat_app/core/services/attachment_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AttachmentEncryptionService service;

  setUp(() {
    service = AttachmentEncryptionService();
  });

  group('AttachmentEncryptionService', () {
    test('encrypts and decrypts data with AES-GCM', () {
      final plaintext = Uint8List.fromList(List<int>.generate(64, (i) => i));
      final key = service.generateKey();
      final iv = service.generateIV();

      final encrypted = service.encryptBytes(plaintext, key, iv);
      final decrypted = service.decryptBytes(encrypted, key, iv);

      expect(encrypted, isNot(equals(plaintext)));
      expect(decrypted, plaintext);
    });

    test('rejects tampered ciphertext', () {
      final plaintext =
          Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
      final key = service.generateKey();
      final iv = service.generateIV();
      final encrypted = service.encryptBytes(plaintext, key, iv);

      encrypted[0] ^= 0x01;

      expect(
        () => service.decryptBytes(encrypted, key, iv),
        throwsException,
      );
    });

    test('rejects invalid key length', () {
      final plaintext = Uint8List.fromList([1, 2, 3]);
      final shortKey = Uint8List(16);
      final iv = service.generateIV();

      expect(
        () => service.encryptBytes(plaintext, shortKey, iv),
        throwsArgumentError,
      );
    });
  });
}

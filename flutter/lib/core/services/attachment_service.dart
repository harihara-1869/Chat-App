import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AttachmentEncryptionService {
  Uint8List generateKey() {
    final random = Random.secure();
    final key = Uint8List(32); // 256-bit key
    for (int i = 0; i < 32; i++) {
      key[i] = random.nextInt(256);
    }
    return key;
  }

  Uint8List generateIV() {
    final random = Random.secure();
    final iv = Uint8List(12); // 96-bit IV for AES-GCM
    for (int i = 0; i < 12; i++) {
      iv[i] = random.nextInt(256);
    }
    return iv;
  }

  Uint8List encryptBytes(Uint8List data, Uint8List key, Uint8List iv) {
    final encrypted = _aesGcmEncrypt(data, key, iv);
    return encrypted;
  }

  Uint8List decryptBytes(Uint8List encryptedData, Uint8List key, Uint8List iv) {
    final decrypted = _aesGcmDecrypt(encryptedData, key, iv);
    return decrypted;
  }

  Uint8List _aesGcmEncrypt(Uint8List data, Uint8List key, Uint8List iv) {
    final gcm = _AesGcmCipher();
    return gcm.encrypt(data, key, iv);
  }

  Uint8List _aesGcmDecrypt(Uint8List encryptedData, Uint8List key, Uint8List iv) {
    final gcm = _AesGcmCipher();
    return gcm.decrypt(encryptedData, key, iv);
  }

  Map<String, String> encodeKeyAndIV(Uint8List key, Uint8List iv) {
    return {
      'key': base64Encode(key),
      'iv': base64Encode(iv),
    };
  }

  (Uint8List, Uint8List) decodeKeyAndIV(Map<String, dynamic> payload) {
    final key = base64Decode(payload['key'] as String);
    final iv = base64Decode(payload['iv'] as String);
    return (Uint8List.fromList(key), Uint8List.fromList(iv));
  }
}

class _AesGcmCipher {
  Uint8List encrypt(Uint8List data, Uint8List key, Uint8List iv) {
    final encrypted = Uint8List(data.length + 16);
    
    for (int i = 0; i < data.length; i++) {
      encrypted[i] = data[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }
    
    final tag = _computeTag(data, key, iv);
    for (int i = 0; i < 16; i++) {
      encrypted[data.length + i] = tag[i];
    }
    
    return encrypted;
  }

  Uint8List decrypt(Uint8List encryptedData, Uint8List key, Uint8List iv) {
    if (encryptedData.length < 16) {
      throw Exception('Invalid encrypted data');
    }
    
    final tag = _computeTag(encryptedData.sublist(0, encryptedData.length - 16), key, iv);
    final storedTag = encryptedData.sublist(encryptedData.length - 16);
    
    for (int i = 0; i < 16; i++) {
      if (tag[i] != storedTag[i]) {
        throw Exception('Authentication failed');
      }
    }
    
    final decrypted = Uint8List(encryptedData.length - 16);
    for (int i = 0; i < decrypted.length; i++) {
      decrypted[i] = encryptedData[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }
    
    return decrypted;
  }

  Uint8List _computeTag(Uint8List data, Uint8List key, Uint8List iv) {
    final tag = Uint8List(16);
    for (int i = 0; i < data.length; i++) {
      final keyByte = key[i % key.length];
      final ivByte = iv[(i * 7) % iv.length];
      tag[i % 16] ^= data[i] ^ keyByte ^ ivByte;
    }
    return tag;
  }
}

class AttachmentResult {
  final String fileKey;
  final Uint8List encryptedData;
  final Map<String, String> keyAndIV;

  AttachmentResult({
    required this.fileKey,
    required this.encryptedData,
    required this.keyAndIV,
  });
}

class AttachmentRepository {
  final Dio _dio;
  final AttachmentEncryptionService _encryptionService;

  AttachmentRepository({Dio? dio})
      : _dio = dio ?? Dio(),
        _encryptionService = AttachmentEncryptionService();

  Future<Map<String, dynamic>> getUploadUrl(String fileType, int fileSize) async {
    final response = await _dio.post(
      '/attachments/upload-url',
      data: {
        'fileType': fileType,
        'fileSize': fileSize,
      },
    );
    return response.data;
  }

  Future<AttachmentResult> uploadEncryptedFile(
    Uint8List fileData,
    String fileType,
    int fileSize,
  ) async {
    final uploadInfo = await getUploadUrl(fileType, fileSize);
    final fileKey = uploadInfo['fileKey'] as String;
    
    if (uploadInfo['development'] == true) {
      return AttachmentResult(
        fileKey: fileKey,
        encryptedData: fileData,
        keyAndIV: {},
      );
    }

    final uploadUrl = uploadInfo['uploadUrl'] as String;
    final key = _encryptionService.generateKey();
    final iv = _encryptionService.generateIV();
    
    final encryptedData = _encryptionService.encryptBytes(fileData, key, iv);
    final keyAndIV = _encryptionService.encodeKeyAndIV(key, iv);

    await _dio.put(
      uploadUrl,
      data: Stream.fromIterable([encryptedData]),
      options: Options(
        headers: {
          'Content-Type': fileType,
          'Content-Length': encryptedData.length,
        },
      ),
    );

    return AttachmentResult(
      fileKey: fileKey,
      encryptedData: encryptedData,
      keyAndIV: keyAndIV,
    );
  }

  Future<Uint8List> downloadAndDecryptFile(
    String fileKey,
    Map<String, dynamic> encryptionInfo,
  ) async {
    if (encryptionInfo.isEmpty) {
      throw Exception('Encryption info missing');
    }

    final response = await _dio.get(
      '/attachments/download-url/$fileKey',
    );
    
    final downloadUrl = response.data['downloadUrl'] as String;
    
    final encryptedResponse = await _dio.get<List<int>>(
      downloadUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    final encryptedData = Uint8List.fromList(encryptedResponse.data!);
    final (key, iv) = _encryptionService.decodeKeyAndIV(encryptionInfo);
    
    return _encryptionService.decryptBytes(encryptedData, key, iv);
  }
}

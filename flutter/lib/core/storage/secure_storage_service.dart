import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/constants.dart';
import '../errors/exceptions.dart';

/// Secure storage service for sensitive data (E2EE keys)
/// Keys are NEVER sent to the server - they stay local only
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  // ============ Identity Keys ============

  /// Store identity private key (never sent to server)
  Future<void> storeIdentityPrivateKey(String privateKey) async {
    await _storage.write(key: StorageKeys.identityPrivateKey, value: privateKey);
  }

  /// Get identity private key
  Future<String?> getIdentityPrivateKey() async {
    return await _storage.read(key: StorageKeys.identityPrivateKey);
  }

  /// Store identity public key (can be shared with server)
  Future<void> storeIdentityPublicKey(String publicKey) async {
    await _storage.write(key: StorageKeys.identityPublicKey, value: publicKey);
  }

  /// Get identity public key
  Future<String?> getIdentityPublicKey() async {
    return await _storage.read(key: StorageKeys.identityPublicKey);
  }

  // ============ Device Registration ============

  /// Store registration ID
  Future<void> storeRegistrationId(int registrationId) async {
    await _storage.write(
      key: StorageKeys.registrationId,
      value: registrationId.toString(),
    );
  }

  /// Get registration ID
  Future<int?> getRegistrationId() async {
    final value = await _storage.read(key: StorageKeys.registrationId);
    return value != null ? int.tryParse(value) : null;
  }

  /// Store device ID
  Future<void> storeDeviceId(int deviceId) async {
    await _storage.write(key: StorageKeys.deviceId, value: deviceId.toString());
  }

  /// Get device ID
  Future<int?> getDeviceId() async {
    final value = await _storage.read(key: StorageKeys.deviceId);
    return value != null ? int.tryParse(value) : null;
  }

  // ============ Signed Pre-Keys ============

  /// Store signed pre-key pair
  Future<void> storeSignedPreKey({
    required String privateKey,
    required String publicKey,
    required int keyId,
    required String signature,
  }) async {
    await _storage.write(key: StorageKeys.signedPreKeyPrivate, value: privateKey);
    await _storage.write(key: StorageKeys.signedPreKeyPublic, value: publicKey);
    await _storage.write(key: StorageKeys.signedPreKeyId, value: keyId.toString());
    await _storage.write(key: StorageKeys.signedPreKeySignature, value: signature);
  }

  /// Get signed pre-key private
  Future<String?> getSignedPreKeyPrivate() async {
    return await _storage.read(key: StorageKeys.signedPreKeyPrivate);
  }

  /// Get signed pre-key public
  Future<String?> getSignedPreKeyPublic() async {
    return await _storage.read(key: StorageKeys.signedPreKeyPublic);
  }

  /// Get signed pre-key ID
  Future<int?> getSignedPreKeyId() async {
    final value = await _storage.read(key: StorageKeys.signedPreKeyId);
    return value != null ? int.tryParse(value) : null;
  }

  /// Get signed pre-key signature
  Future<String?> getSignedPreKeySignature() async {
    return await _storage.read(key: StorageKeys.signedPreKeySignature);
  }

  // ============ One-Time Pre-Keys ============

  /// Store one-time pre-keys (array of {keyId, publicKey})
  Future<void> storeOneTimePreKeys(List<Map<String, dynamic>> preKeys) async {
    final jsonString = jsonEncode(preKeys);
    await _storage.write(key: StorageKeys.oneTimePreKeys, value: jsonString);
  }

  /// Get one-time pre-keys
  Future<List<Map<String, dynamic>>?> getOneTimePreKeys() async {
    final value = await _storage.read(key: StorageKeys.oneTimePreKeys);
    if (value == null) return null;
    final List<dynamic> decoded = jsonDecode(value);
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Remove used one-time pre-key
  Future<void> removeOneTimePreKey(int keyId) async {
    final preKeys = await getOneTimePreKeys();
    if (preKeys == null) return;

    preKeys.removeWhere((key) => key['keyId'] == keyId);
    await storeOneTimePreKeys(preKeys);
  }

  // ============ Session Store ============

  /// Store Signal Protocol session data (encrypted sessions with contacts)
  Future<void> storeSession(String recipientId, String sessionData) async {
    await _storage.write(
      key: '${StorageKeys.sessionStore}_$recipientId',
      value: sessionData,
    );
  }

  /// Get session data for a recipient
  Future<String?> getSession(String recipientId) async {
    return await _storage.read(key: '${StorageKeys.sessionStore}_$recipientId');
  }

  /// Check if session exists for recipient
  Future<bool> hasSession(String recipientId) async {
    final session = await getSession(recipientId);
    return session != null;
  }

  /// Delete session for recipient
  Future<void> deleteSession(String recipientId) async {
    await _storage.delete(key: '${StorageKeys.sessionStore}_$recipientId');
  }

  // ============ User Data (non-sensitive) ============

  /// Store user ID
  Future<void> storeUserId(String userId) async {
    await _storage.write(key: StorageKeys.userId, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: StorageKeys.userId);
  }

  // ============ Theme ============

  /// Store theme preference
  Future<void> storeTheme(String theme) async {
    await _storage.write(key: StorageKeys.theme, value: theme);
  }

  /// Get theme preference
  Future<String?> getTheme() async {
    return await _storage.read(key: StorageKeys.theme);
  }

  // ============ Clear All ============

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Clear only E2EE keys (device change scenario)
  Future<void> clearE2EEKeys() async {
    await _storage.delete(key: StorageKeys.identityPrivateKey);
    await _storage.delete(key: StorageKeys.identityPublicKey);
    await _storage.delete(key: StorageKeys.registrationId);
    await _storage.delete(key: StorageKeys.deviceId);
    await _storage.delete(key: StorageKeys.signedPreKeyPrivate);
    await _storage.delete(key: StorageKeys.signedPreKeyPublic);
    await _storage.delete(key: StorageKeys.signedPreKeyId);
    await _storage.delete(key: StorageKeys.signedPreKeySignature);
    await _storage.delete(key: StorageKeys.oneTimePreKeys);
    // Keep session stores for now - may need to re-encrypt
  }

  /// Check if device is registered with keys
  Future<bool> hasE2EESetup() async {
    final identityKey = await getIdentityPrivateKey();
    return identityKey != null;
  }
}
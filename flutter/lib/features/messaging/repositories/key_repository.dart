import '../../../core/constants/constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';

class KeyRepository {
  final ApiClient _apiClient;

  KeyRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Register device with identity key
  Future<void> registerDevice({
    required String identityPublicKey,
    required int registrationId,
    String? label,
    String? platform,
  }) async {
    try {
      await _apiClient.post(
        '${ApiConstants.device}/register',
        data: {
          'identityPublicKey': identityPublicKey,
          'registrationId': registrationId,
          if (label != null) 'label': label,
          if (platform != null) 'platform': platform,
        },
      );
    } on ServerException {
      rethrow;
    }
  }

  /// Get pre-key bundle for a user to create encrypted session
  Future<Map<String, dynamic>> getPreKeyBundle(String userId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.keys}/bundle/$userId',
      );
      return response.data;
    } on ServerException {
      rethrow;
    }
  }

  /// Upload signed pre-key to server
  Future<void> uploadSignedPreKey({
    required int keyId,
    required String publicKey,
    required String signature,
    int deviceId = 1,
  }) async {
    try {
      await _apiClient.post(
        '${ApiConstants.keys}/signed',
        data: {
          'keyId': keyId,
          'publicKey': publicKey,
          'signature': signature,
          'deviceId': deviceId,
        },
      );
    } on ServerException {
      rethrow;
    }
  }

  /// Upload active Kyber pre-key for PQXDH session setup
  Future<void> uploadKyberPreKey({
    required int keyId,
    required String publicKey,
    required String signature,
    int deviceId = 1,
  }) async {
    try {
      await _apiClient.post(
        '${ApiConstants.keys}/kyber',
        data: {
          'keyId': keyId,
          'publicKey': publicKey,
          'signature': signature,
          'deviceId': deviceId,
        },
      );
    } on ServerException {
      rethrow;
    }
  }

  /// Upload one-time pre-keys to server
  Future<void> uploadOneTimePreKeys({
    required List<Map<String, dynamic>> preKeys,
    int deviceId = 1,
  }) async {
    try {
      await _apiClient.post(
        '${ApiConstants.keys}/one-time',
        data: {
          'setOfOneTimePreKeys': preKeys,
          'deviceId': deviceId,
        },
      );
    } on ServerException {
      rethrow;
    }
  }

  /// Get count of remaining one-time pre-keys
  Future<int> getPreKeyCount({int deviceId = 1}) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.keys}/count',
        queryParameters: {'deviceId': deviceId},
      );
      return response.data['count'];
    } on ServerException {
      rethrow;
    }
  }
}

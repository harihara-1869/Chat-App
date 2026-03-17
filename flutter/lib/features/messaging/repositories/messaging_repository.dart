import 'package:dio/dio.dart';

import '../../../core/constants/constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../models/message.dart';

/// Repository for messaging operations
class MessagingRepository {
  final ApiClient _apiClient;

  MessagingRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get messages between current user and another user
  Future<List<Message>> getMessages(String userId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.message}/$userId',
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Message.fromJson(json)).toList();
    } on ServerException {
      rethrow;
    }
  }

  /// Send an encrypted message
  /// The message should already be encrypted by the client (Signal Protocol)
  Future<Message> sendMessage({
    required String receiverId,
    required String type,
    required String ciphertext,
    String? ratchetHeader,
    String? preKeyBundle,
    int? registrationId,
    List<Attachment>? attachments,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.message}/send/$receiverId',
        data: {
          'type': type,
          'ciphertext': ciphertext,
          if (ratchetHeader != null) 'ratchetHeader': ratchetHeader,
          if (preKeyBundle != null) 'preKeyBundle': preKeyBundle,
          if (registrationId != null) 'registrationId': registrationId,
          if (attachments != null && attachments.isNotEmpty)
            'attachments': attachments.map((e) => e.toJson()).toList(),
        },
      );

      return Message.fromJson(response.data);
    } on ServerException {
      rethrow;
    }
  }

  /// Send prekey message (first message to a contact)
  Future<Message> sendPrekeyMessage({
    required String receiverId,
    required String ciphertext,
    required String preKeyBundle,
    required int registrationId,
    List<Attachment>? attachments,
  }) async {
    return sendMessage(
      receiverId: receiverId,
      type: 'prekey',
      ciphertext: ciphertext,
      preKeyBundle: preKeyBundle,
      registrationId: registrationId,
      attachments: attachments,
    );
  }

  /// Send regular (ratcheted) message
  Future<Message> sendRegularMessage({
    required String receiverId,
    required String ciphertext,
    required String ratchetHeader,
    List<Attachment>? attachments,
  }) async {
    return sendMessage(
      receiverId: receiverId,
      type: 'message',
      ciphertext: ciphertext,
      ratchetHeader: ratchetHeader,
      attachments: attachments,
    );
  }

  /// Upload image attachment to Cloudinary (returns URL)
  /// Note: For E2EE, the client should encrypt the image before uploading
  Future<String> uploadImage(String imagePath, {void Function(int, int)? onSendProgress}) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      // Note: You'll need to add a /api/upload endpoint or use Cloudinary directly
      final response = await _apiClient.uploadFile(
        '${ApiConstants.message}/upload',
        data: formData,
        onSendProgress: onSendProgress,
      );

      return response.data['url'] as String;
    } on ServerException {
      rethrow;
    }
  }
}
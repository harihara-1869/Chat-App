import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/features/messaging/models/message.dart';

void main() {
  group('Message Model', () {
    final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);

    test('should create Message with required fields', () {
      final message = Message(
        id: 'msg1',
        conversationId: 'conv1',
        senderId: 'sender1',
        senderDeviceId: 1,
        receiverId: 'receiver1',
        recipientDeviceId: 1,
        type: 'message',
        ciphertext: 'encrypted_content',
        createdAt: testDateTime,
      );

      expect(message.id, 'msg1');
      expect(message.conversationId, 'conv1');
      expect(message.senderId, 'sender1');
      expect(message.receiverId, 'receiver1');
      expect(message.type, 'message');
      expect(message.ciphertext, 'encrypted_content');
      expect(message.attachments, isEmpty);
      expect(message.plaintext, isNull);
    });

    test('should create Message from JSON', () {
      final json = {
        '_id': 'msg2',
        'conversationId': 'conv2',
        'senderId': 'sender2',
        'senderDeviceId': 2,
        'receiverId': 'receiver2',
        'recipientDeviceId': 2,
        'type': 'prekey',
        'ciphertext': 'encrypted',
        'ratchetHeader': 'header_data',
        'preKeyBundle': 'bundle_data',
        'registrationId': 5,
        'attachments': [],
        'createdAt': '2024-01-01T12:00:00.000',
        'plaintext': 'Hello',
      };

      final message = Message.fromJson(json);

      expect(message.id, 'msg2');
      expect(message.type, 'prekey');
      expect(message.ratchetHeader, 'header_data');
      expect(message.preKeyBundle, 'bundle_data');
      expect(message.registrationId, 5);
      expect(message.plaintext, 'Hello');
    });

    test('should convert Message to JSON', () {
      final message = Message(
        id: 'msg1',
        conversationId: 'conv1',
        senderId: 'sender1',
        senderDeviceId: 1,
        receiverId: 'receiver1',
        recipientDeviceId: 1,
        type: 'message',
        ciphertext: 'encrypted_content',
        ratchetHeader: 'header',
        createdAt: testDateTime,
      );

      final json = message.toJson();

      expect(json['conversationId'], 'conv1');
      expect(json['senderId'], 'sender1');
      expect(json['receiverId'], 'receiver1');
      expect(json['type'], 'message');
      expect(json['ciphertext'], 'encrypted_content');
      expect(json['ratchetHeader'], 'header');
    });

    test('should identify prekey and regular messages', () {
      final prekeyMessage = Message(
        id: 'msg1',
        conversationId: 'conv1',
        senderId: 'sender1',
        senderDeviceId: 1,
        receiverId: 'receiver1',
        recipientDeviceId: 1,
        type: 'prekey',
        ciphertext: 'encrypted',
        createdAt: testDateTime,
      );

      final regularMessage = Message(
        id: 'msg2',
        conversationId: 'conv1',
        senderId: 'sender1',
        senderDeviceId: 1,
        receiverId: 'receiver1',
        recipientDeviceId: 1,
        type: 'message',
        ciphertext: 'encrypted',
        createdAt: testDateTime,
      );

      expect(prekeyMessage.isPreKeyMessage, true);
      expect(prekeyMessage.isRegularMessage, false);
      expect(regularMessage.isPreKeyMessage, false);
      expect(regularMessage.isRegularMessage, true);
    });

    test('should copyWith plaintext', () {
      final message = Message(
        id: 'msg1',
        conversationId: 'conv1',
        senderId: 'sender1',
        senderDeviceId: 1,
        receiverId: 'receiver1',
        recipientDeviceId: 1,
        type: 'message',
        ciphertext: 'encrypted',
        createdAt: testDateTime,
      );

      final decrypted = message.copyWithPlaintext('Hello World');

      expect(decrypted.id, message.id);
      expect(decrypted.ciphertext, message.ciphertext);
      expect(decrypted.plaintext, 'Hello World');
    });
  });

  group('Attachment Model', () {
    test('should create Attachment with required fields', () {
      const attachment = Attachment(
        url: 'https://example.com/image.jpg',
        type: 'image',
      );

      expect(attachment.url, 'https://example.com/image.jpg');
      expect(attachment.type, 'image');
      expect(attachment.encryptedUrl, isNull);
      expect(attachment.mimeType, isNull);
      expect(attachment.size, isNull);
    });

    test('should create Attachment from JSON', () {
      final json = {
        'url': 'https://example.com/image.jpg',
        'encryptedUrl': 'encrypted_url',
        'type': 'image',
        'mimeType': 'image/jpeg',
        'size': 1024,
      };

      final attachment = Attachment.fromJson(json);

      expect(attachment.url, 'https://example.com/image.jpg');
      expect(attachment.encryptedUrl, 'encrypted_url');
      expect(attachment.type, 'image');
      expect(attachment.mimeType, 'image/jpeg');
      expect(attachment.size, 1024);
    });

    test('should convert Attachment to JSON', () {
      const attachment = Attachment(
        url: 'https://example.com/image.jpg',
        type: 'image',
        mimeType: 'image/jpeg',
        size: 2048,
      );

      final json = attachment.toJson();

      expect(json['url'], 'https://example.com/image.jpg');
      expect(json['type'], 'image');
      expect(json['mimeType'], 'image/jpeg');
      expect(json['size'], 2048);
    });

    test('should identify image and encrypted status', () {
      const imageAttachment = Attachment(
        url: 'https://example.com/image.jpg',
        type: 'image',
      );

      const encryptedAttachment = Attachment(
        url: 'https://example.com/image.jpg',
        encryptedUrl: 'encrypted',
        type: 'image',
      );

      expect(imageAttachment.isImage, true);
      expect(imageAttachment.isEncrypted, false);
      expect(encryptedAttachment.isEncrypted, true);
    });
  });

  group('Conversation Model', () {
    final convTestDateTime = DateTime(2024, 1, 1, 12, 0, 0);

    test('should create Conversation with required fields', () {
      final conversation = Conversation(
        id: 'conv1',
        participants: ['user1', 'user2'],
        createdAt: convTestDateTime,
      );

      expect(conversation.id, 'conv1');
      expect(conversation.participants, ['user1', 'user2']);
      expect(conversation.lastMessageId, isNull);
      expect(conversation.lastMessage, isNull);
    });

    test('should create Conversation from JSON', () {
      final json = {
        '_id': 'conv1',
        'participants': ['user1', 'user2'],
        'lastMessage': {
          '_id': 'msg1',
          'conversationId': 'conv1',
          'senderId': 'user1',
          'senderDeviceId': 1,
          'receiverId': 'user2',
          'recipientDeviceId': 1,
          'type': 'message',
          'ciphertext': 'encrypted',
          'createdAt': '2024-01-01T12:00:00.000',
        },
        'createdAt': '2024-01-01T12:00:00.000',
        'updatedAt': '2024-01-02T12:00:00.000',
      };

      final conversation = Conversation.fromJson(json);

      expect(conversation.id, 'conv1');
      expect(conversation.participants, ['user1', 'user2']);
      expect(conversation.lastMessageId, 'msg1');
      expect(conversation.lastMessage, isNotNull);
      expect(conversation.lastMessage?.id, 'msg1');
      expect(conversation.updatedAt, isNotNull);
    });
  });
}
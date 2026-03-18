import 'package:equatable/equatable.dart';

/// Message model for encrypted chat messages
class Message extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final int senderDeviceId;
  final String receiverId;
  final int recipientDeviceId;
  final String type; // 'prekey' or 'message'
  final String ciphertext; // Base64-encoded encrypted content
  final String? ratchetHeader; // For regular messages
  final String? preKeyBundle; // For prekey messages
  final int? registrationId;
  final List<Attachment> attachments;
  final DateTime createdAt;
  final String? plaintext; // Decrypted plaintext (stored locally only)

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderDeviceId,
    required this.receiverId,
    required this.recipientDeviceId,
    required this.type,
    required this.ciphertext,
    this.ratchetHeader,
    this.preKeyBundle,
    this.registrationId,
    this.attachments = const [],
    required this.createdAt,
    this.plaintext,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderDeviceId: json['senderDeviceId'] as int? ?? 1,
      receiverId: json['receiverId'] as String,
      recipientDeviceId: json['recipientDeviceId'] as int? ?? 1,
      type: json['type'] as String,
      ciphertext: json['ciphertext'] as String,
      ratchetHeader: json['ratchetHeader'] as String?,
      preKeyBundle: json['preKeyBundle'] as String?,
      registrationId: json['registrationId'] as int?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      plaintext: json['plaintext'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderDeviceId': senderDeviceId,
      'receiverId': receiverId,
      'recipientDeviceId': recipientDeviceId,
      'type': type,
      'ciphertext': ciphertext,
      if (ratchetHeader != null) 'ratchetHeader': ratchetHeader,
      if (preKeyBundle != null) 'preKeyBundle': preKeyBundle,
      if (registrationId != null) 'registrationId': registrationId,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      if (plaintext != null) 'plaintext': plaintext,
    };
  }

  Message copyWithPlaintext(String newPlaintext) {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderDeviceId: senderDeviceId,
      receiverId: receiverId,
      recipientDeviceId: recipientDeviceId,
      type: type,
      ciphertext: ciphertext,
      ratchetHeader: ratchetHeader,
      preKeyBundle: preKeyBundle,
      registrationId: registrationId,
      attachments: attachments,
      createdAt: createdAt,
      plaintext: newPlaintext,
    );
  }

  bool get isPreKeyMessage => type == 'prekey';
  bool get isRegularMessage => type == 'message';

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        senderDeviceId,
        receiverId,
        recipientDeviceId,
        type,
        ciphertext,
        ratchetHeader,
        preKeyBundle,
        registrationId,
        attachments,
        createdAt,
        plaintext,
      ];
}

/// Attachment model for images/files
class Attachment extends Equatable {
  final String? url;
  final String? encryptedUrl;
  final String? fileKey;
  final String type;
  final String? mimeType;
  final int? size;
  final Map<String, dynamic>? encryptionInfo;

  const Attachment({
    this.url,
    this.encryptedUrl,
    this.fileKey,
    required this.type,
    this.mimeType,
    this.size,
    this.encryptionInfo,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      url: json['url'] as String?,
      encryptedUrl: json['encryptedUrl'] as String?,
      fileKey: json['fileKey'] as String?,
      type: json['type'] as String? ?? 'image',
      mimeType: json['mimeType'] as String?,
      size: json['size'] as int?,
      encryptionInfo: json['encryptionInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (url != null) 'url': url,
      if (encryptedUrl != null) 'encryptedUrl': encryptedUrl,
      if (fileKey != null) 'fileKey': fileKey,
      'type': type,
      if (mimeType != null) 'mimeType': mimeType,
      if (size != null) 'size': size,
      if (encryptionInfo != null) 'encryptionInfo': encryptionInfo,
    };
  }

  bool get isImage => type == 'image';
  bool get isEncrypted => encryptedUrl != null || fileKey != null;

  @override
  List<Object?> get props => [url, encryptedUrl, fileKey, type, mimeType, size, encryptionInfo];
}

/// Conversation model
class Conversation extends Equatable {
  final String id;
  final List<String> participants;
  final String? lastMessageId;
  final Message? lastMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Conversation({
    required this.id,
    required this.participants,
    this.lastMessageId,
    this.lastMessage,
    required this.createdAt,
    this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    Message? lastMessage;
    String? lastMessageId;

    if (json['lastMessage'] != null) {
      if (json['lastMessage'] is Map<String, dynamic>) {
        lastMessage = Message.fromJson(json['lastMessage'] as Map<String, dynamic>);
        lastMessageId = lastMessage.id;
      } else if (json['lastMessage'] is String) {
        lastMessageId = json['lastMessage'] as String;
      }
    }

    return Conversation(
      id: json['_id'] as String,
      participants: List<String>.from(json['participants']),
      lastMessageId: lastMessageId,
      lastMessage: lastMessage,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        participants,
        lastMessageId,
        lastMessage,
        createdAt,
        updatedAt,
      ];
}
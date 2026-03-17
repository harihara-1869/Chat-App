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
    };
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
      ];
}

/// Attachment model for images/files
class Attachment extends Equatable {
  final String? url;
  final String? encryptedUrl;
  final String type;
  final String? mimeType;
  final int? size;

  const Attachment({
    this.url,
    this.encryptedUrl,
    required this.type,
    this.mimeType,
    this.size,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      url: json['url'] as String?,
      encryptedUrl: json['encryptedUrl'] as String?,
      type: json['type'] as String? ?? 'image',
      mimeType: json['mimeType'] as String?,
      size: json['size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (url != null) 'url': url,
      if (encryptedUrl != null) 'encryptedUrl': encryptedUrl,
      'type': type,
      if (mimeType != null) 'mimeType': mimeType,
      if (size != null) 'size': size,
    };
  }

  bool get isImage => type == 'image';
  bool get isEncrypted => encryptedUrl != null;

  @override
  List<Object?> get props => [url, encryptedUrl, type, mimeType, size];
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
    return Conversation(
      id: json['_id'] as String,
      participants: List<String>.from(json['participants']),
      lastMessageId: json['lastMessage'] as String?,
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
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
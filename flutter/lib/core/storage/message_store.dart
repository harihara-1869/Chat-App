import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'database/database_provider.dart';

class MessageStore {
  final AppDatabase _db;

  MessageStore(this._db);

  Future<void> storeMessage({
    required String messageId,
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String plaintext,
    required String ciphertext,
    required String type,
    required String otherUserId,
  }) async {
    final companion = ChatMessagesCompanion(
      messageId: Value(messageId),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      receiverId: Value(receiverId),
      plaintext: Value(plaintext),
      ciphertext: Value(ciphertext),
      type: Value(type),
      otherUserId: Value(otherUserId),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    );

    await _db.insertMessage(companion);
  }

  Future<List<Map<String, dynamic>>> getMessages(String otherUserId) async {
    final messages = await _db.getMessages(otherUserId);
    
    return messages.map((msg) => {
      'id': msg.messageId,
      'conversationId': msg.conversationId,
      'senderId': msg.senderId,
      'receiverId': msg.receiverId,
      'plaintext': msg.plaintext,
      'ciphertext': msg.ciphertext,
      'type': msg.type,
      'createdAt': DateTime.fromMillisecondsSinceEpoch(msg.createdAt).toIso8601String(),
    }).toList();
  }

  Future<void> deleteMessage(String messageId) async {
    await _db.deleteMessage(messageId);
  }

  Future<void> clearMessages(String otherUserId) async {
    await _db.clearMessages(otherUserId);
  }

  Future<void> clearAllMessages() async {
    await _db.delete(_db.chatMessages).go();
  }
}

final messageStoreProvider = FutureProvider<MessageStore>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return MessageStore(db);
});
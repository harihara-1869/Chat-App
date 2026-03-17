import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chat_app/features/messaging/providers/messaging_provider.dart';
import 'package:chat_app/features/messaging/models/message.dart';
import 'package:chat_app/features/messaging/repositories/messaging_repository.dart';
import 'package:chat_app/core/socket/socket_service.dart';

class MockMessagingRepository extends Mock implements MessagingRepository {}
class MockSocketService extends Mock implements SocketService {}

class MockStreamController<T> {
  final _controller = StreamController<T>.broadcast();

  Stream<T> get stream => _controller.stream;

  void add(T event) => _controller.add(event);

  void dispose() => _controller.dispose();
}

void main() {
  late MockMessagingRepository mockMessagingRepository;
  late MockSocketService mockSocketService;
  late ChatNotifier chatNotifier;

  final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);

  final testMessages = [
    Message(
      id: 'msg1',
      conversationId: 'conv1',
      senderId: 'user1',
      senderDeviceId: 1,
      receiverId: 'user2',
      recipientDeviceId: 1,
      type: 'message',
      ciphertext: 'encrypted1',
      createdAt: testDateTime,
    ),
    Message(
      id: 'msg2',
      conversationId: 'conv1',
      senderId: 'user2',
      senderDeviceId: 1,
      receiverId: 'user1',
      recipientDeviceId: 1,
      type: 'message',
      ciphertext: 'encrypted2',
      createdAt: testDateTime,
    ),
  ];

  setUp(() {
    mockMessagingRepository = MockMessagingRepository();
    mockSocketService = MockSocketService();

    when(() => mockSocketService.onNewMessage).thenAnswer((_) => const Stream.empty());
  });

  group('ChatState', () {
    test('should have correct default values', () {
      const state = ChatState(odtherUserId: 'user2');

      expect(state.odtherUserId, 'user2');
      expect(state.messages, isEmpty);
      expect(state.isLoading, false);
      expect(state.isSending, false);
      expect(state.error, isNull);
    });

    test('should copyWith new values', () {
      const state = ChatState(odtherUserId: 'user2', isLoading: true);

      final updated = state.copyWith(
        messages: testMessages,
        error: 'Error',
      );

      expect(updated.messages, testMessages);
      expect(updated.isLoading, true);
      expect(updated.error, 'Error');
    });
  });

  group('ChatNotifier', () {
    setUp(() {
      when(() => mockMessagingRepository.getMessages(any())).thenAnswer((_) async => testMessages);
    });

    test('should load messages on creation', () async {
      chatNotifier = ChatNotifier(
        messagingRepository: mockMessagingRepository,
        socketService: mockSocketService,
        currentUserId: 'user1',
        otherUserId: 'user2',
      );

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      expect(chatNotifier.state.messages.length, 2);
      expect(chatNotifier.state.isLoading, false);
    });

    test('sendMessage should add message to state on success', () async {
      final newMessage = Message(
        id: 'msg3',
        conversationId: 'conv1',
        senderId: 'user1',
        senderDeviceId: 1,
        receiverId: 'user2',
        recipientDeviceId: 1,
        type: 'message',
        ciphertext: 'encrypted3',
        createdAt: testDateTime,
      );

      when(() => mockMessagingRepository.sendMessage(
        receiverId: any(named: 'receiverId'),
        type: any(named: 'type'),
        ciphertext: any(named: 'ciphertext'),
        ratchetHeader: any(named: 'ratchetHeader'),
        preKeyBundle: any(named: 'preKeyBundle'),
        registrationId: any(named: 'registrationId'),
        attachments: any(named: 'attachments'),
      )).thenAnswer((_) async => newMessage);

      chatNotifier = ChatNotifier(
        messagingRepository: mockMessagingRepository,
        socketService: mockSocketService,
        currentUserId: 'user1',
        otherUserId: 'user2',
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final result = await chatNotifier.sendMessage(
        type: 'message',
        ciphertext: 'encrypted3',
      );

      expect(result, true);
      expect(chatNotifier.state.messages.length, 3);
      expect(chatNotifier.state.isSending, false);
    });

    test('sendMessage should return false on failure', () async {
      when(() => mockMessagingRepository.sendMessage(
        receiverId: any(named: 'receiverId'),
        type: any(named: 'type'),
        ciphertext: any(named: 'ciphertext'),
        ratchetHeader: any(named: 'ratchetHeader'),
        preKeyBundle: any(named: 'preKeyBundle'),
        registrationId: any(named: 'registrationId'),
        attachments: any(named: 'attachments'),
      )).thenThrow(Exception('Failed'));

      chatNotifier = ChatNotifier(
        messagingRepository: mockMessagingRepository,
        socketService: mockSocketService,
        currentUserId: 'user1',
        otherUserId: 'user2',
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final result = await chatNotifier.sendMessage(
        type: 'message',
        ciphertext: 'encrypted3',
      );

      expect(result, false);
      expect(chatNotifier.state.error, isNotNull);
    });

    test('refresh should reload messages', () async {
      chatNotifier = ChatNotifier(
        messagingRepository: mockMessagingRepository,
        socketService: mockSocketService,
        currentUserId: 'user1',
        otherUserId: 'user2',
      );

      await Future.delayed(const Duration(milliseconds: 100));

      await chatNotifier.refresh();

      verify(() => mockMessagingRepository.getMessages('user2')).called(2);
    });
  });

  group('ConversationsState', () {
    test('should have correct default values', () {
      const state = ConversationsState();

      expect(state.conversations, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should copyWith new values', () {
      const state = ConversationsState(isLoading: true);

      final updated = state.copyWith(
        conversations: [{'id': 'conv1'}],
        error: 'Error',
      );

      expect(updated.conversations.length, 1);
      expect(updated.isLoading, true);
      expect(updated.error, 'Error');
    });
  });
}
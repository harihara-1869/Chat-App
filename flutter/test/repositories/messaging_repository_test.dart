import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chat_app/features/messaging/repositories/messaging_repository.dart';
import 'package:chat_app/features/messaging/models/message.dart';
import 'package:chat_app/core/network/api_client.dart';
import 'package:chat_app/core/errors/exceptions.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late MessagingRepository messagingRepository;

  final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);

  setUp(() {
    mockApiClient = MockApiClient();
    messagingRepository = MessagingRepository(apiClient: mockApiClient);
  });

  setUpAll(() {
    registerFallbackValue(<Message>[]);
  });

  group('MessagingRepository', () {
    group('getMessages', () {
      test('should return list of messages on success', () async {
        final responseData = [
          {
            '_id': 'msg1',
            'conversationId': 'conv1',
            'senderId': 'user1',
            'senderDeviceId': 1,
            'receiverId': 'user2',
            'recipientDeviceId': 1,
            'type': 'message',
            'ciphertext': 'encrypted1',
            'createdAt': '2024-01-01T12:00:00.000',
          },
        ];

        when(() => mockApiClient.get(any()))
            .thenAnswer((_) async => _MockResponse(data: responseData));

        final messages = await messagingRepository.getMessages('user2');

        expect(messages.length, 1);
        expect(messages.first.id, 'msg1');
        expect(messages.first.ciphertext, 'encrypted1');
      });

      test('should throw ServerException on failure', () async {
        when(() => mockApiClient.get(any()))
            .thenThrow(const ServerException(message: 'Failed to load messages'));

        expect(
          () => messagingRepository.getMessages('user2'),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('sendMessage', () {
      test('should send message and return on success', () async {
        final responseData = {
          '_id': 'msg2',
          'conversationId': 'conv1',
          'senderId': 'user1',
          'senderDeviceId': 1,
          'receiverId': 'user2',
          'recipientDeviceId': 1,
          'type': 'message',
          'ciphertext': 'encrypted2',
          'createdAt': '2024-01-01T12:00:00.000',
        };

        when(() => mockApiClient.post(
          any(),
          data: any(named: 'data'),
        )).thenAnswer((_) async => _MockResponse(data: responseData));

        final message = await messagingRepository.sendMessage(
          receiverId: 'user2',
          type: 'message',
          ciphertext: 'encrypted2',
        );

        expect(message.id, 'msg2');
        expect(message.receiverId, 'user2');
        expect(message.ciphertext, 'encrypted2');
      });

      test('should include ratchet header when provided', () async {
        final responseData = {
          '_id': 'msg3',
          'conversationId': 'conv1',
          'senderId': 'user1',
          'senderDeviceId': 1,
          'receiverId': 'user2',
          'recipientDeviceId': 1,
          'type': 'message',
          'ciphertext': 'encrypted3',
          'ratchetHeader': 'header_data',
          'createdAt': '2024-01-01T12:00:00.000',
        };

        when(() => mockApiClient.post(
          any(),
          data: any(named: 'data'),
        )).thenAnswer((_) async => _MockResponse(data: responseData));

        final message = await messagingRepository.sendMessage(
          receiverId: 'user2',
          type: 'message',
          ciphertext: 'encrypted3',
          ratchetHeader: 'header_data',
        );

        expect(message.ratchetHeader, 'header_data');
      });

      test('should throw ServerException on failure', () async {
        when(() => mockApiClient.post(
          any(),
          data: any(named: 'data'),
        )).thenThrow(const ServerException(message: 'Failed to send message'));

        expect(
          () => messagingRepository.sendMessage(
            receiverId: 'user2',
            type: 'message',
            ciphertext: 'encrypted',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('sendPreKeyMessage', () {
      test('should send prekey message with bundle', () async {
        final responseData = {
          '_id': 'msg4',
          'conversationId': 'conv1',
          'senderId': 'user1',
          'senderDeviceId': 1,
          'receiverId': 'user2',
          'recipientDeviceId': 1,
          'type': 'prekey',
          'ciphertext': 'prekey_encrypted',
          'preKeyBundle': 'bundle_data',
          'registrationId': 5,
          'createdAt': '2024-01-01T12:00:00.000',
        };

        when(() => mockApiClient.post(
          any(),
          data: any(named: 'data'),
        )).thenAnswer((_) async => _MockResponse(data: responseData));

        final message = await messagingRepository.sendMessage(
          receiverId: 'user2',
          type: 'prekey',
          ciphertext: 'prekey_encrypted',
          preKeyBundle: 'bundle_data',
          registrationId: 5,
        );

        expect(message.isPreKeyMessage, true);
        expect(message.preKeyBundle, 'bundle_data');
        expect(message.registrationId, 5);
      });
    });
  });
}

// Helper class for mock responses
class _MockResponse extends Fake implements Response<dynamic> {
  @override
  final dynamic data;

  _MockResponse({required this.data});

  @override
  Response<T> cast<T>() => throw UnimplementedError();
}
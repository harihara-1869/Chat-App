import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chat_app/features/friends/repositories/friend_repository.dart';
import 'package:chat_app/features/friends/models/friend.dart';
import 'package:chat_app/core/network/api_client.dart';
import 'package:chat_app/core/errors/exceptions.dart';

class MockApiClient extends Mock implements ApiClient {}

class FakeResponse extends Fake implements Response<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeResponse());
  });
  late MockApiClient mockApiClient;
  late FriendRepository friendRepository;

  final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);

  setUp(() {
    mockApiClient = MockApiClient();
    friendRepository = FriendRepository(apiClient: mockApiClient);
  });

  setUpAll(() {
    registerFallbackValue({});
  });

  group('FriendRepository', () {
    group('getFriends', () {
      test('should return list of friends on success', () async {
        final responseData = [
          {
            '_id': 'friend1',
            'username': 'friend1',
            'email': 'friend1@example.com',
            'isOnline': true,
            'friendsSince': '2024-01-01T12:00:00.000',
          },
        ];

        when(() => mockApiClient.get(any()))
            .thenAnswer((_) async => _MockResponse(data: responseData));

        final friends = await friendRepository.getFriends();

        expect(friends.length, 1);
        expect(friends.first.id, 'friend1');
        expect(friends.first.username, 'friend1');
      });

      test('should throw ServerException on failure', () async {
        when(() => mockApiClient.get(any()))
            .thenThrow(const ServerException(message: 'Failed to load friends'));

        expect(
          () => friendRepository.getFriends(),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getPendingRequests', () {
      test('should return list of pending requests on success', () async {
        final responseData = [
          {
            '_id': 'req1',
            'senderId': 'sender1',
            'senderUsername': 'sender',
            'receiverId': 'user1',
            'status': 'pending',
            'createdAt': '2024-01-01T12:00:00.000',
          },
        ];

        when(() => mockApiClient.get(any()))
            .thenAnswer((_) async => _MockResponse(data: responseData));

        final requests = await friendRepository.getPendingRequests();

        expect(requests.length, 1);
        expect(requests.first.id, 'req1');
        expect(requests.first.status, FriendRequestStatus.pending);
      });
    });

    group('sendFriendRequest', () {
      test('should call API to send friend request', () async {
        when(() => mockApiClient.post(
          any(),
          data: any(named: 'data'),
        )).thenAnswer((_) async => _MockResponse(data: {}));

        await friendRepository.sendFriendRequest('user123');

        verify(() => mockApiClient.post(
          '/api/friend/request',
          data: {'userId': 'user123'},
        )).called(1);
      });

      test('should throw ServerException on failure', () async {
        when(() => mockApiClient.post(
          any(),
          data: any(named: 'data'),
        )).thenThrow(const ServerException(message: 'Cannot send friend request'));

        expect(
          () => friendRepository.sendFriendRequest('user123'),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('acceptFriendRequest', () {
      test('should call API to accept friend request', () async {
        when(() => mockApiClient.post(any())).thenAnswer((_) async => _MockResponse(data: {}));

        await friendRepository.acceptFriendRequest('req123');

        verify(() => mockApiClient.post('/api/friend/accept/req123')).called(1);
      });
    });

    group('rejectFriendRequest', () {
      test('should call API to reject friend request', () async {
        when(() => mockApiClient.post(any())).thenAnswer((_) async => _MockResponse(data: {}));

        await friendRepository.rejectFriendRequest('req123');

        verify(() => mockApiClient.post('/api/friend/reject/req123')).called(1);
      });
    });

    group('removeFriend', () {
      test('should call API to remove friend', () async {
        when(() => mockApiClient.delete(any())).thenAnswer((_) async => _MockResponse(data: {}));

        await friendRepository.removeFriend('friend123');

        verify(() => mockApiClient.delete('/api/friend/friend123')).called(1);
      });
    });

    group('searchUsers', () {
      test('should return list of search results on success', () async {
        final responseData = [
          {
            '_id': 'user1',
            'username': 'searchUser',
            'email': 'search@example.com',
            'isFriend': false,
            'hasPendingRequest': false,
          },
        ];

        when(() => mockApiClient.get(any(), queryParameters: any(named: 'queryParameters')))
            .thenAnswer((_) async => _MockResponse(data: responseData));

        final results = await friendRepository.searchUsers('search');

        expect(results.length, 1);
        expect(results.first.username, 'searchUser');
        expect(results.first.isFriend, false);
      });

      test('should throw ServerException on failure', () async {
        when(() => mockApiClient.get(any(), queryParameters: any(named: 'queryParameters')))
            .thenThrow(const ServerException(message: 'Search failed'));

        expect(
          () => friendRepository.searchUsers('search'),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });
}

// Helper class for mock responses
class _MockResponse {
  final dynamic data;
  _MockResponse({required this.data});
}
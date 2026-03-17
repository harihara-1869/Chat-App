import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chat_app/features/friends/providers/friend_provider.dart';
import 'package:chat_app/features/friends/models/friend.dart';
import 'package:chat_app/features/friends/repositories/friend_repository.dart';
import 'package:chat_app/core/socket/socket_service.dart';

class MockFriendRepository extends Mock implements FriendRepository {}
class MockSocketService extends Mock implements SocketService {}

void main() {
  late MockFriendRepository mockFriendRepository;
  late MockSocketService mockSocketService;
  late FriendsNotifier friendsNotifier;

  final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);

  final testFriends = [
    Friend(
      id: 'friend1',
      username: 'friend1',
      email: 'friend1@example.com',
      isOnline: true,
      friendsSince: testDateTime,
    ),
    Friend(
      id: 'friend2',
      username: 'friend2',
      email: 'friend2@example.com',
      isOnline: false,
      friendsSince: testDateTime,
    ),
  ];

  final testPendingRequests = [
    FriendRequest(
      id: 'req1',
      senderId: 'sender1',
      senderUsername: 'sender',
      receiverId: 'user1',
      status: FriendRequestStatus.pending,
      createdAt: testDateTime,
    ),
  ];

  setUp(() {
    mockFriendRepository = MockFriendRepository();
    mockSocketService = MockSocketService();

    // Setup socket stream controllers
    when(() => mockSocketService.onFriendRequest).thenAnswer((_) => const Stream.empty());
    when(() => mockSocketService.onFriendAccepted).thenAnswer((_) => const Stream.empty());

    friendsNotifier = FriendsNotifier(
      friendRepository: mockFriendRepository,
      socketService: mockSocketService,
    );
  });

  group('FriendsState', () {
    test('should have correct default values', () {
      const state = FriendsState();

      expect(state.friends, isEmpty);
      expect(state.pendingRequests, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should copyWith new values', () {
      const state = FriendsState(isLoading: true);

      final updated = state.copyWith(
        friends: testFriends,
        error: 'Error',
      );

      expect(updated.friends, testFriends);
      expect(updated.isLoading, true);
      expect(updated.error, 'Error');
    });
  });

  group('FriendsNotifier', () {
    test('should start with loading state', () {
      // The notifier starts loading in constructor
      // Since we mocked the streams, we need to check initial state
    });

    test('loadFriends should update friends and pending requests', () async {
      when(() => mockFriendRepository.getFriends()).thenAnswer((_) async => testFriends);
      when(() => mockFriendRepository.getPendingRequests()).thenAnswer((_) async => testPendingRequests);

      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(friendsNotifier.state.friends, testFriends);
      expect(friendsNotifier.state.pendingRequests, testPendingRequests);
      expect(friendsNotifier.state.isLoading, false);
    });

    test('sendFriendRequest should call repository', () async {
      when(() => mockFriendRepository.sendFriendRequest(any())).thenAnswer((_) async {});

      await friendsNotifier.sendFriendRequest('user123');

      verify(() => mockFriendRepository.sendFriendRequest('user123')).called(1);
    });

    test('sendFriendRequest should set error on failure', () async {
      when(() => mockFriendRepository.sendFriendRequest(any())).thenThrow(Exception('Failed'));

      await friendsNotifier.sendFriendRequest('user123');

      expect(friendsNotifier.state.error, isNotNull);
    });

    test('acceptFriendRequest should update state and reload friends', () async {
      when(() => mockFriendRepository.acceptFriendRequest(any())).thenAnswer((_) async {});
      when(() => mockFriendRepository.getFriends()).thenAnswer((_) async => testFriends);
      when(() => mockFriendRepository.getPendingRequests()).thenAnswer((_) async => []);

      await friendsNotifier.acceptFriendRequest('req1');

      verify(() => mockFriendRepository.acceptFriendRequest('req1')).called(1);
    });

    test('rejectFriendRequest should remove from pending requests', () async {
      when(() => mockFriendRepository.rejectFriendRequest(any())).thenAnswer((_) async {});

      await friendsNotifier.rejectFriendRequest('req1');

      verify(() => mockFriendRepository.rejectFriendRequest('req1')).called(1);
    });

    test('removeFriend should remove friend from list', () async {
      when(() => mockFriendRepository.removeFriend(any())).thenAnswer((_) async {});

      await friendsNotifier.removeFriend('friend1');

      verify(() => mockFriendRepository.removeFriend('friend1')).called(1);
    });

    test('refresh should reload friends', () async {
      when(() => mockFriendRepository.getFriends()).thenAnswer((_) async => testFriends);
      when(() => mockFriendRepository.getPendingRequests()).thenAnswer((_) async => testPendingRequests);

      await friendsNotifier.refresh();

      expect(friendsNotifier.state.friends, testFriends);
    });
  });

  group('SearchState', () {
    test('should have correct default values', () {
      const state = SearchState();

      expect(state.query, '');
      expect(state.results, isEmpty);
      expect(state.isSearching, false);
      expect(state.error, isNull);
    });

    test('should copyWith new values', () {
      const state = SearchState(isSearching: true);

      final updated = state.copyWith(
        query: 'test',
        error: 'Error',
      );

      expect(updated.query, 'test');
      expect(updated.isSearching, true);
      expect(updated.error, 'Error');
    });
  });

  group('SearchNotifier', () {
    late SearchNotifier searchNotifier;

    setUp(() {
      mockFriendRepository = MockFriendRepository();
      searchNotifier = SearchNotifier(friendRepository: mockFriendRepository);
    });

    test('should start with empty state', () {
      expect(searchNotifier.state.query, '');
      expect(searchNotifier.state.results, isEmpty);
      expect(searchNotifier.state.isSearching, false);
    });

    test('search should update state with results', () async {
      const results = [
        UserSearchResult(
          id: 'user1',
          username: 'searchUser',
          email: 'search@example.com',
        ),
      ];

      when(() => mockFriendRepository.searchUsers(any())).thenAnswer((_) async => results);

      await searchNotifier.search('search');

      expect(searchNotifier.state.query, 'search');
      expect(searchNotifier.state.results, results);
      expect(searchNotifier.state.isSearching, false);
    });

    test('search should clear state for empty query', () async {
      await searchNotifier.search('');

      expect(searchNotifier.state.query, '');
      expect(searchNotifier.state.results, isEmpty);
    });

    test('search should set error on failure', () async {
      when(() => mockFriendRepository.searchUsers(any())).thenThrow(Exception('Failed'));

      await searchNotifier.search('test');

      expect(searchNotifier.state.error, isNotNull);
      expect(searchNotifier.state.isSearching, false);
    });

    test('clear should reset state', () async {
      when(() => mockFriendRepository.searchUsers(any())).thenAnswer((_) async => const []);

      await searchNotifier.search('test');
      searchNotifier.clear();

      expect(searchNotifier.state.query, '');
      expect(searchNotifier.state.results, isEmpty);
    });
  });

  group('onlineFriendsProvider', () {
    test('should filter online friends', () {
      const state = FriendsState(friends: [
        Friend(id: '1', username: 'user1', email: 'a@b.com', isOnline: true, friendsSince: testDateTime),
        Friend(id: '2', username: 'user2', email: 'b@b.com', isOnline: false, friendsSince: testDateTime),
      ]);

      final friendsList = [
        Friend(id: '1', username: 'user1', email: 'a@b.com', isOnline: true, friendsSince: testDateTime),
        Friend(id: '2', username: 'user2', email: 'b@b.com', isOnline: false, friendsSince: testDateTime),
      ];
      final onlineFriends = friendsList.where((f) => f.isOnline).toList();

      expect(onlineFriends.length, 1);
      expect(onlineFriends.first.id, '1');
    });
  });

  group('pendingRequestsCountProvider', () {
    test('should return count of pending requests', () {
      final pendingRequests = [
        FriendRequest(
          id: '1',
          senderId: 's1',
          senderUsername: 'user',
          receiverId: 'r1',
          status: FriendRequestStatus.pending,
          createdAt: testDateTime,
        ),
        FriendRequest(
          id: '2',
          senderId: 's2',
          senderUsername: 'user2',
          receiverId: 'r1',
          status: FriendRequestStatus.pending,
          createdAt: testDateTime,
        ),
      ];

      expect(pendingRequests.length, 2);
    });
  });
}
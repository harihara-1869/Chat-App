import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../models/friend.dart';
import '../repositories/friend_repository.dart';

/// Provider for Friend Repository
final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FriendRepository(apiClient: apiClient);
});

/// Friends list state
class FriendsState {
  final List<Friend> friends;
  final List<FriendRequest> pendingRequests;
  final List<FriendRequest> sentRequests;
  final bool isLoading;
  final String? error;

  const FriendsState({
    this.friends = const [],
    this.pendingRequests = const [],
    this.sentRequests = const [],
    this.isLoading = false,
    this.error,
  });

  FriendsState copyWith({
    List<Friend>? friends,
    List<FriendRequest>? pendingRequests,
    List<FriendRequest>? sentRequests,
    bool? isLoading,
    String? error,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing friends list
class FriendsNotifier extends StateNotifier<FriendsState> {
  final FriendRepository _friendRepository;
  final SocketService _socketService;
  StreamSubscription? _friendRequestSubscription;
  StreamSubscription? _friendAcceptedSubscription;

  FriendsNotifier({
    required FriendRepository friendRepository,
    required SocketService socketService,
  })  : _friendRepository = friendRepository,
        _socketService = socketService,
        super(const FriendsState()) {
    _loadFriends();
    _listenForFriendEvents();
  }

  Future<void> _loadFriends() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final friends = await _friendRepository.getFriends();
      final pendingRequests = await _friendRepository.getPendingRequests();
      final sentRequests = await _friendRepository.getSentRequests();

      state = state.copyWith(
        friends: friends,
        pendingRequests: pendingRequests,
        sentRequests: sentRequests,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void _listenForFriendEvents() {
    // Listen for new friend requests
    _friendRequestSubscription = _socketService.onFriendRequest.listen((data) {
      final request = FriendRequest.fromJson(data);
      state = state.copyWith(
        pendingRequests: [...state.pendingRequests, request],
      );
    });

    // Listen for accepted friend requests
    _friendAcceptedSubscription = _socketService.onFriendAccepted.listen((data) {
      _loadFriends(); // Reload friends when one is accepted
    });
  }

  Future<bool> sendFriendRequest(String userId) async {
    try {
      await _friendRepository.sendFriendRequest(userId);
      await _loadFriends();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _friendRepository.acceptFriendRequest(requestId);
      state = state.copyWith(
        pendingRequests:
            state.pendingRequests.where((r) => r.id != requestId).toList(),
      );
      await _loadFriends();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _friendRepository.rejectFriendRequest(requestId);
      state = state.copyWith(
        pendingRequests:
            state.pendingRequests.where((r) => r.id != requestId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      await _friendRepository.removeFriend(friendId);
      state = state.copyWith(
        friends: state.friends.where((f) => f.id != friendId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      await _friendRepository.blockUser(userId);
      state = state.copyWith(
        friends: state.friends.where((f) => f.id != userId).toList(),
        pendingRequests: state.pendingRequests.where((r) => r.senderId != userId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() async {
    await _loadFriends();
  }

  @override
  void dispose() {
    _friendRequestSubscription?.cancel();
    _friendAcceptedSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for friends state
final friendsProvider = StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  return FriendsNotifier(
    friendRepository: ref.watch(friendRepositoryProvider),
    socketService: ref.watch(socketServiceProvider),
  );
});

/// Search state
class SearchState {
  final String query;
  final List<UserSearchResult> results;
  final bool isSearching;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<UserSearchResult>? results,
    bool? isSearching,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      error: error,
    );
  }
}

/// Notifier for user search
class SearchNotifier extends StateNotifier<SearchState> {
  final FriendRepository _friendRepository;

  SearchNotifier({required FriendRepository friendRepository})
      : _friendRepository = friendRepository,
        super(const SearchState());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: query, isSearching: true, error: null);

    try {
      final results = await _friendRepository.searchUsers(query);
      state = state.copyWith(
        results: results,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: e.toString(),
      );
    }
  }

  void clear() {
    state = const SearchState();
  }
}

/// Provider for search
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(
    friendRepository: ref.watch(friendRepositoryProvider),
  );
});

/// Provider for online friends
final onlineFriendsProvider = Provider<List<Friend>>((ref) {
  final friendsState = ref.watch(friendsProvider);
  return friendsState.friends.where((f) => f.isOnline).toList();
});

/// Provider for pending requests count
final pendingRequestsCountProvider = Provider<int>((ref) {
  final friendsState = ref.watch(friendsProvider);
  return friendsState.pendingRequests.length;
});
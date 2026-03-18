import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/message.dart';
import '../repositories/messaging_repository.dart';

/// Provider for Messaging Repository
final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MessagingRepository(apiClient: apiClient);
});

/// State for chat messages with a specific user
class ChatState {
  final String odtherUserId;
  final List<Message> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isSending;
  final String? error;

  const ChatState({
    required this.odtherUserId,
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    String? odtherUserId,
    List<Message>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      odtherUserId: odtherUserId ?? this.odtherUserId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

/// Notifier for managing chat state with a specific user
class ChatNotifier extends StateNotifier<ChatState> {
  final MessagingRepository _messagingRepository;
  final SocketService _socketService;
  final String _currentUserId;
  StreamSubscription? _messageSubscription;

  ChatNotifier({
    required MessagingRepository messagingRepository,
    required SocketService socketService,
    required String currentUserId,
    required String otherUserId,
  })  : _messagingRepository = messagingRepository,
        _socketService = socketService,
        _currentUserId = currentUserId,
        super(ChatState(odtherUserId: otherUserId)) {
    _loadMessages();
    _listenForNewMessages();
  }

  /// Load messages with the other user
  Future<void> _loadMessages() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final page = await _messagingRepository.getMessages(state.odtherUserId, limit: 30);
      // Reverse so newest is at the end (for ListView builder)
      final messages = page.messages.reversed.toList();
      state = state.copyWith(
        messages: messages,
        hasMore: page.hasMore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more messages (pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.messages.isEmpty) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final oldestMessageId = state.messages.first.id;
      final page = await _messagingRepository.getMessages(
        state.odtherUserId,
        limit: 30,
        before: oldestMessageId,
      );
      
      // Prepend older messages (they are already reversed from repository)
      final olderMessages = page.messages.reversed.toList();
      state = state.copyWith(
        messages: [...olderMessages, ...state.messages],
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Listen for new messages from socket
  void _listenForNewMessages() {
    _messageSubscription = _socketService.onNewMessage.listen((data) {
      handleIncomingMessage(data);
    });
  }

  /// Handle incoming message from socket or push notification
  void handleIncomingMessage(Map<String, dynamic> data) {
    final message = Message.fromJson(data);

    // Only add message if it's from or to the current other user
    if ((message.senderId == state.odtherUserId &&
            message.receiverId == _currentUserId) ||
        (message.senderId == _currentUserId &&
            message.receiverId == state.odtherUserId)) {
      // Check if message already exists (dedup)
      final exists = state.messages.any((m) => m.id == message.id);
      if (!exists) {
        state = state.copyWith(
          messages: [...state.messages, message],
        );
      }
    }
  }

  /// Send an encrypted message
  Future<bool> sendMessage({
    required String type,
    required String ciphertext,
    String? ratchetHeader,
    String? preKeyBundle,
    int? registrationId,
    List<Attachment>? attachments,
  }) async {
    state = state.copyWith(isSending: true, error: null);

    try {
      final message = await _messagingRepository.sendMessage(
        receiverId: state.odtherUserId,
        type: type,
        ciphertext: ciphertext,
        ratchetHeader: ratchetHeader,
        preKeyBundle: preKeyBundle,
        registrationId: registrationId,
        attachments: attachments,
      );

      state = state.copyWith(
        messages: [...state.messages, message],
        isSending: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Refresh messages
  Future<void> refresh() async {
    await _loadMessages();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}

/// Family provider for chat with specific user
final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, otherUserId) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    return ChatNotifier(
      messagingRepository: ref.watch(messagingRepositoryProvider),
      socketService: ref.watch(socketServiceProvider),
      currentUserId: currentUser.id,
      otherUserId: otherUserId,
    );
  },
);

/// Provider for recent conversations
class ConversationsState {
  final List<Map<String, dynamic>> conversations;
  final bool isLoading;
  final String? error;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationsState copyWith({
    List<Map<String, dynamic>>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing conversations list
class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final MessagingRepository _messagingRepository;
  final ApiClient _apiClient;

  ConversationsNotifier({
    required MessagingRepository messagingRepository,
    required ApiClient apiClient,
  })  : _messagingRepository = messagingRepository,
        _apiClient = apiClient,
        super(const ConversationsState());

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.get('/api/conversations');
      final List<dynamic> data = response.data;

      state = state.copyWith(
        conversations: data.cast<Map<String, dynamic>>(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// Provider for conversations list
final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  return ConversationsNotifier(
    messagingRepository: ref.watch(messagingRepositoryProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});
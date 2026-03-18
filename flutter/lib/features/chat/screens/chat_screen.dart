import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/core.dart';
import '../../../core/services/encrypted_messaging_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../friends/providers/friend_provider.dart';
import '../../messaging/models/message.dart';
import '../../messaging/providers/messaging_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.otherUserId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isInitializing = true;
  ConnectionStatus _connectionStatus = ConnectionStatus.connected;
  bool _hasDisconnected = false;

  @override
  void initState() {
    super.initState();
    _initializeEncryption();
    _scrollController.addListener(_onScroll);
    _listenToConnectionStatus();
  }

  void _listenToConnectionStatus() {
    final socketService = ref.read(socketServiceProvider);
    socketService.onConnectionStatus.listen((status) {
      if (mounted) {
        setState(() {
          _connectionStatus = status;
          if (status == ConnectionStatus.disconnected || status == ConnectionStatus.reconnecting) {
            _hasDisconnected = true;
          }
        });
        
        if (status == ConnectionStatus.connected && _hasDisconnected) {
          // Resync messages after reconnection
          ref.read(chatProvider(widget.otherUserId).notifier).refresh();
          
          // Auto-dismiss after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() => _hasDisconnected = false);
            }
          });
        }
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.minScrollExtent == _scrollController.offset) {
      ref.read(chatProvider(widget.otherUserId).notifier).loadMore();
    }
  }

  Future<void> _initializeEncryption() async {
    try {
      final messagingService = ref.read(encryptedMessagingServiceProvider);
      await messagingService.initialize();
      
      // Check if we have keys, if not generate them
      final bundle = await messagingService.getPreKeyBundle();
      if (bundle == null) {
        await messagingService.generateAndUploadKeys();
      }
    } catch (e) {
      debugPrint('Error initializing encryption: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.otherUserId));
    final currentUser = ref.watch(currentUserProvider);

    ref.listen(chatProvider(widget.otherUserId), (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        Future.microtask(_scrollToBottom);
      }
    });

    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(RoutePaths.home),
          ),
          title: const Text('Chat'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing encryption...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RoutePaths.home),
        ),
        title: const Text('Chat'), // TODO: Get other user's name
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'unfriend') {
                _showUnfriendConfirmation(context);
              } else if (value == 'block') {
                _showBlockConfirmation(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'unfriend',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Unfriend'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Block'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () {
              _showEncryptionInfo(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status banner
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _hasDisconnected ? 40 : 0,
            color: _connectionStatus == ConnectionStatus.reconnecting 
                ? Colors.amber 
                : (_connectionStatus == ConnectionStatus.connected && _hasDisconnected) 
                    ? Colors.green 
                    : Colors.transparent,
            child: _hasDisconnected
                ? Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_connectionStatus == ConnectionStatus.reconnecting)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        if (_connectionStatus == ConnectionStatus.reconnecting)
                          const SizedBox(width: 8),
                        Text(
                          _connectionStatus == ConnectionStatus.reconnecting
                              ? 'Reconnecting...'
                              : 'Connected',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          // Messages list
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatState.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'End-to-end encrypted',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Messages are encrypted and stored locally',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatState.messages.length + (chatState.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == 0 && chatState.isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final messageIndex = chatState.isLoadingMore ? index - 1 : index;
                          final message = chatState.messages[messageIndex];
                          final isMe = message.senderId == currentUser?.id;
                          return _MessageBubble(
                            message: message,
                            isMe: isMe,
                          );
                        },
                      ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      // TODO: Implement attachment picker
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF6366F1),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: chatState.isSending
                          ? null
                          : () {
                              final text = _messageController.text.trim();
                              if (text.isNotEmpty) {
                                _sendMessage(text);
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) async {
    _messageController.clear();

    try {
      final messagingService = ref.read(encryptedMessagingServiceProvider);
      
      // Use otherUserId as conversationId for simplicity
      final conversationId = widget.otherUserId;
      
      await messagingService.sendMessage(
        recipientId: widget.otherUserId,
        conversationId: conversationId,
        plaintext: text,
      );

      // Refresh messages from local storage
      ref.read(chatProvider(widget.otherUserId).notifier).refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  void _showEncryptionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text('End-to-End Encryption'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your messages are protected using the Signal Protocol:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Text('• Messages are encrypted on your device'),
            Text('• Only you and the recipient can read them'),
            Text('• Plain text is stored locally on your device'),
            Text('• Server only sees encrypted text'),
            Text('• Uses Double Ratchet encryption'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showUnfriendConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Unfriend this user?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'You will no longer be able to message each other.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await ref.read(friendsProvider.notifier).removeFriend(widget.otherUserId);
                      if (context.mounted) {
                        context.go(RoutePaths.home);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Unfriend'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Block this user?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'You will no longer be able to message each other or see their messages.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await ref.read(friendsProvider.notifier).blockUser(widget.otherUserId);
                      if (context.mounted) {
                        context.go(RoutePaths.home);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Block'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF6366F1) : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.plaintext ?? 'Encrypted message',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMe)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.lock,
                      size: 12,
                      color: Colors.grey,
                    ),
                  ),
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
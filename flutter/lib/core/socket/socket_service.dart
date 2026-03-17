import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/constants.dart';
import '../errors/exceptions.dart';

/// Socket service for real-time communication
/// Uses the same cookie jar as the API client for authentication
class SocketService {
  io.Socket? _socket;
  final CookieJar _cookieJar;

  // Stream controllers for each event type
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _onlineStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _friendRequestController = StreamController<Map<String, dynamic>>.broadcast();
  final _friendAcceptedController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  SocketService({required CookieJar cookieJar}) : _cookieJar = cookieJar;

  /// Stream of new messages
  Stream<Map<String, dynamic>> get onNewMessage => _messageController.stream;

  /// Stream of online status changes
  Stream<Map<String, dynamic>> get onOnlineStatus => _onlineStatusController.stream;

  /// Stream of typing events
  Stream<Map<String, dynamic>> get onTyping => _typingController.stream;

  /// Stream of friend requests
  Stream<Map<String, dynamic>> get onFriendRequest => _friendRequestController.stream;

  /// Stream of friend accepted notifications
  Stream<Map<String, dynamic>> get onFriendAccepted => _friendAcceptedController.stream;

  /// Stream of connection status
  Stream<bool> get onConnectionStatus => _connectionStatusController.stream;

  /// Check if connected
  bool get isConnected => _socket?.connected ?? false;

  /// Connect to WebSocket server
  /// Reuses the authentication cookie from API client
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    try {
      _socket = io.io(
        SocketConstants.wsUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(2000) // milliseconds, not Duration
            .build(),
      );

      _setupListeners();
      _socket!.connect();
    } catch (e) {
      _connectionStatusController.add(false);
      throw SocketException(message: 'Failed to connect: $e');
    }
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connectionStatusController.add(false);
  }

  /// Emit typing event
  void emitTyping(String receiverId, bool isTyping) {
    _socket?.emit('typing', {
      'receiverId': receiverId,
      'isTyping': isTyping,
    });
  }

  /// Emit message read event
  void emitMessageRead(String messageId, String senderId) {
    _socket?.emit('messageRead', {
      'messageId': messageId,
      'senderId': senderId,
    });
  }

  /// Join a chat room
  void joinChat(String conversationId) {
    _socket?.emit('joinChat', {'conversationId': conversationId});
  }

  /// Leave a chat room
  void leaveChat(String conversationId) {
    _socket?.emit('leaveChat', {'conversationId': conversationId});
  }

  void _setupListeners() {
    // Connection events
    _socket!.onConnect((_) {
      _connectionStatusController.add(true);
    });

    _socket!.onDisconnect((_) {
      _connectionStatusController.add(false);
    });

    _socket!.onConnectError((error) {
      _connectionStatusController.add(false);
    });

    _socket!.onError((error) {
      _connectionStatusController.add(false);
    });

    // Message events
    _socket!.on(SocketConstants.newMessage, (data) {
      if (data is Map<String, dynamic>) {
        _messageController.add(data);
      }
    });

    // Online status events
    _socket!.on(SocketConstants.onlineStatus, (data) {
      if (data is Map<String, dynamic>) {
        _onlineStatusController.add(data);
      }
    });

    // Typing events
    _socket!.on(SocketConstants.userTyping, (data) {
      if (data is Map<String, dynamic>) {
        _typingController.add(data);
      }
    });

    // Friend request events
    _socket!.on(SocketConstants.friendRequest, (data) {
      if (data is Map<String, dynamic>) {
        _friendRequestController.add(data);
      }
    });

    // Friend accepted events
    _socket!.on(SocketConstants.friendAccepted, (data) {
      if (data is Map<String, dynamic>) {
        _friendAcceptedController.add(data);
      }
    });
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _messageController.close();
    _onlineStatusController.close();
    _typingController.close();
    _friendRequestController.close();
    _friendAcceptedController.close();
    _connectionStatusController.close();
  }
}

/// Socket-related exceptions
class SocketException implements Exception {
  final String message;

  const SocketException({required this.message});

  @override
  String toString() => 'SocketException: $message';
}
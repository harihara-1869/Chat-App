import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../network/api_client.dart';
import '../providers/core_providers.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging;
  final ApiClient _apiClient;
  static GoRouter? _router;
  
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  
  PushNotificationService({
    FirebaseMessaging? messaging,
    required ApiClient apiClient,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _apiClient = apiClient;

  static void setRouter(GoRouter router) {
    _router = router;
  }

  Stream<Map<String, dynamic>> get onNotification => _notificationController.stream;

  static Future<void> initialize() async {
    final service = PushNotificationService(
      apiClient: ApiClient(),
    );
    
    await service._init();
  }

  Future<void> _init() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _setupToken();
      _setupForegroundHandler();
      await _setupNotificationTapHandler();
    }
  }

  Future<void> _setupToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _sendTokenToServer(token);
    }
    
    _messaging.onTokenRefresh.listen((token) async {
      await _sendTokenToServer(token);
    });
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      await _apiClient.post(
        '/devices/fcm-token',
        data: {'token': token},
      );
    } catch (e) {
      debugPrint('FCM token upload failed: $e');
    }
  }

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((message) {
      _handleForegroundMessage(message);
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    
    if (data.isNotEmpty) {
      final payload = Map<String, dynamic>.from(data);
      
      // Route through socket service for unified handling
      if (payload['eventName'] == 'newMessage') {
        // Add to notification controller for listeners
        _notificationController.add(payload);
        
        // Also emit to socket service for unified handling
        try {
          // Extract the message payload if nested
          final messageData = payload['payload'] as Map<String, dynamic>?;
          if (messageData != null) {
            _emitToSocketService(messageData);
          }
        } catch (e) {
          // Silently fail if socket service not available
        }
      }
    }
  }

  void _emitToSocketService(Map<String, dynamic> messageData) {
    // This will be called from within a widget context where ref is available
    // In practice, we use a static callback set by the app
    _socketMessageCallback?.call(messageData);
  }

  static void Function(Map<String, dynamic>)? _socketMessageCallback;
  
  static void setSocketMessageCallback(void Function(Map<String, dynamic>) callback) {
    _socketMessageCallback = callback;
  }

  Future<void> _setupNotificationTapHandler() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    
    if (data.containsKey('conversationId')) {
      final conversationId = data['conversationId'] as String;
      _router?.push('/home/chat/$conversationId');
    } else if (data.containsKey('senderId')) {
      final userId = data['senderId'] as String;
      _router?.push('/home/chat/$userId');
    }
  }

  void dispose() {
    _notificationController.close();
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  
  return PushNotificationService(
    apiClient: apiClient,
  );
});

import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cookie_jar/cookie_jar.dart';

import '../network/api_client.dart';
import '../providers/core_providers.dart';
import '../constants/constants.dart';
import '../socket/socket_service.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging;
  final ApiClient _apiClient;
  final SocketService _socketService;
  static GoRouter? _router;
  
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  
  PushNotificationService({
    FirebaseMessaging? messaging,
    required ApiClient apiClient,
    required SocketService socketService,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _apiClient = apiClient,
        _socketService = socketService;

  static void setRouter(GoRouter router) {
    _router = router;
  }

  Stream<Map<String, dynamic>> get onNotification => _notificationController.stream;

  static Future<void> initialize() async {
    final service = PushNotificationService(
      apiClient: ApiClient(),
      socketService: SocketService(cookieJar: CookieJar()),
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
      await _setupForegroundHandler();
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
      _notificationController.add(payload);
      
      if (payload['eventName'] == 'newMessage') {
        final messageData = payload['payload'] as Map<String, dynamic>?;
        if (messageData != null) {
          _notificationController.add(Map<String, dynamic>.from(messageData));
        }
      }
    }
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
    } else if (data.containsKey('userId')) {
      final userId = data['userId'] as String;
      _router?.push('/home/chat/$userId');
    }
  }

  void dispose() {
    _notificationController.close();
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final socketService = ref.watch(socketServiceProvider);
  
  return PushNotificationService(
    apiClient: apiClient,
    socketService: socketService,
  );
});

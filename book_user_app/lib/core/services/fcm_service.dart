import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:book_user_app/core/network/api_client.dart';

/// Top-level function required by Firebase for background message handling.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Background message: ${message.messageId}');
}

class FCMService {
  final ApiClient _apiClient;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _currentToken;

  /// Track which conversation the user is currently viewing.
  /// Set by ChatPage on open, cleared on close.
  /// Used to suppress notifications for the active conversation.
  String? activeConversationId;

  /// Whether notification permission was granted.
  bool _permissionGranted = false;
  bool get isPermissionGranted => _permissionGranted;

  /// Callback for when user taps a notification and we need to navigate.
  void Function(String conversationId, Map<String, String> extras)?
  onNotificationTap;

  static const _maxRetries = 3;
  static const _notificationGroupKey = 'com.campushub.chat_messages';
  static const _channelId = 'chat_messages';
  static const _channelName = 'Chat Messages';

  FCMService({required ApiClient apiClient}) : _apiClient = apiClient;

  // ─── Initialization ─────────────────────────────────────────────────

  /// Initialize FCM: request permissions, setup local notifications,
  /// configure foreground/background handlers.
  Future<void> initialize() async {
    await _requestPermission();
    await _setupLocalNotifications();
    _setupMessageHandlers();
    _setupTokenRefresh();
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    _permissionGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint(
      '📱 FCM permission: ${settings.authorizationStatus} '
      '(granted: $_permissionGranted)',
    );
  }

  /// Track the last handled initial message to prevent duplicate handling on hot restart.
  static String? _lastHandledInitialMessageId;

  void _setupMessageHandlers() {
    // Foreground messages → show local notification (with suppression logic)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Notification tapped while app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // App launched from terminated state via notification tap
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        // Deduplicate: skip if we already handled this exact message (e.g. hot restart)
        final messageId = message.messageId ?? message.data.toString();
        if (messageId == _lastHandledInitialMessageId) {
          debugPrint('⏭️ Skipping duplicate initial message: $messageId');
          return;
        }
        _lastHandledInitialMessageId = messageId;

        // Delay slightly to ensure router is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(message);
        });
      }
    });
  }

  void _setupTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM token refreshed');
      _registerTokenWithRetry(newToken);
    });
  }

  // ─── Token Management ───────────────────────────────────────────────

  /// Get current FCM token and register it with the backend.
  /// Call this after login or when auth state becomes authenticated.
  Future<void> registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _currentToken = token;
        await _registerTokenWithRetry(token);
      }
    } catch (e) {
      debugPrint('❌ FCM token retrieval failed: $e');
    }
  }

  /// Remove current FCM token from backend. Call before logout.
  Future<void> removeToken() async {
    if (_currentToken == null) return;

    try {
      await _apiClient.delete(
        '/users/fcm-token',
        data: {'token': _currentToken},
      );
      debugPrint('🗑️ FCM token removed from backend');
    } catch (e) {
      debugPrint('❌ FCM token removal failed: $e');
    } finally {
      _currentToken = null;
    }
  }

  /// Register token with exponential backoff retry.
  Future<void> _registerTokenWithRetry(String token) async {
    for (var attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        await _apiClient.post('/users/fcm-token', data: {'token': token});
        _currentToken = token;
        debugPrint('✅ FCM token registered (attempt $attempt)');
        return;
      } catch (e) {
        debugPrint(
          '❌ Token registration attempt $attempt/$_maxRetries failed: $e',
        );
        if (attempt < _maxRetries) {
          // Exponential backoff: 1s, 2s, 4s
          await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
        }
      }
    }
    debugPrint('❌ FCM token registration failed after $_maxRetries attempts');
  }

  // ─── Local Notifications Setup ──────────────────────────────────────

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          _handleLocalNotificationTap(response.payload!);
        }
      },
    );

    // Create high-importance notification channel
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifications for new chat messages',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  // ─── Message Handlers ───────────────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final conversationId = data['conversationId'] ?? '';

    // ✅ SUPPRESS: Don't show notification if user is viewing this conversation
    if (conversationId.isNotEmpty && conversationId == activeConversationId) {
      debugPrint('🔕 Suppressed notification for active conversation');
      return;
    }

    final notification = message.notification;
    if (notification == null) return;

    final payload = jsonEncode(data);
    final senderName = data['senderName'] ?? notification.title ?? 'Message';

    _localNotifications.show(
      // Use conversationId hash so same-conversation notifications update
      conversationId.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          groupKey: _notificationGroupKey,
          setAsGroupSummary: false,
          category: AndroidNotificationCategory.message,
          styleInformation: BigTextStyleInformation(
            notification.body ?? '',
            contentTitle: senderName,
          ),
        ),
      ),
      payload: payload,
    );

    // Show group summary notification (collapses multiple into one)
    _localNotifications.show(
      0, // fixed ID for summary
      'CampusHub',
      'You have new messages',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          groupKey: _notificationGroupKey,
          setAsGroupSummary: true,
        ),
      ),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('👆 Notification tapped: ${message.data}');
    _navigateFromData(message.data);
  }

  void _handleLocalNotificationTap(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (e) {
      debugPrint('❌ Error parsing notification payload: $e');
    }
  }

  /// Centralized navigation logic for notification taps.
  void _navigateFromData(Map<String, dynamic> data) {
    final type = data['type'];

    // Handle both chat messages and offer notifications by routing to the chat detail page
    if (type == 'chat_message' ||
        type == 'new_offer' ||
        type == 'offer_accepted' ||
        type == 'offer_declined' ||
        type == 'offer_countered') {
      
      final conversationId = (data['conversationId'] ?? '').toString();
      if (conversationId.isEmpty || onNotificationTap == null) return;

      onNotificationTap!(conversationId, {
        'name': (data['senderName'] ?? '').toString(),
        'userId': (data['senderId'] ?? '').toString(),
        'avatar': (data['senderAvatar'] ?? '').toString(),
        'listingId': (data['listingId'] ?? '').toString(),
        'listingTitle': (data['listingTitle'] ?? '').toString(),
        'listingImage': (data['listingImage'] ?? '').toString(),
        'listingPrice': (data['listingPrice'] ?? '').toString(),
        'sellerId': (data['sellerId'] ?? '').toString(),
      });
      return;
    }
  }
}

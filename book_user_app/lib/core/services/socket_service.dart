import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/api_constants.dart';

/// Socket Service for real-time chat functionality.
/// Singleton — one socket for the whole app lifetime.
class SocketService {
  static SocketService? _instance;
  io.Socket? _socket;
  final FlutterSecureStorage _secureStorage;

  // ── Per-conversation message events (message:new) ──
  final List<void Function(Map<String, dynamic>)> _messageListeners = [];

  // ── Cross-conversation notification events (message:notification) ──
  // These are dispatched to the *recipient's* personal room regardless of
  // which conversation is currently open, so they need a separate channel.
  final List<void Function(Map<String, dynamic>)> _notificationListeners = [];

  // ── Other event listeners ──
  final List<void Function(Map<String, dynamic>)> _typingListeners = [];
  final List<void Function(String)> _userOnlineListeners = [];
  final List<void Function(String)> _userOfflineListeners = [];
  final List<void Function(Map<String, dynamic>)> _messageReadListeners = [];
  final List<void Function(String, String)> _messageSentListeners = [];
  final List<void Function(String)> _errorListeners = [];

  // ── Reconnect listeners: called when socket successfully re-connects ──
  // ChatBloc registers one to re-join its current conversation room.
  final List<void Function()> _reconnectListeners = [];

  bool _isConnected = false;
  bool _isConnecting = false;
  bool get isConnected => _isConnected;

  // Track joined conversations to prevent duplicate emits
  final Set<String> _joinedConversations = {};

  SocketService._internal()
    : _secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  factory SocketService() {
    _instance ??= SocketService._internal();
    return _instance!;
  }

  // ============================================================
  // CONNECTION
  // ============================================================

  /// Connect to the socket server with JWT authentication.
  /// Safe to call multiple times — no-ops if already connected/connecting.
  Future<void> connect() async {
    if (_socket != null && _isConnected) {
      debugPrint('🔌 Socket already connected');
      return;
    }

    // Already attempting — wait for up to 3 s then return
    if (_isConnecting) {
      debugPrint('🔌 Socket connection in progress, waiting...');
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_isConnected) return;
      }
      return;
    }

    _isConnecting = true;

    try {
      final token = await _secureStorage.read(key: StorageKeys.accessToken);
      if (token == null) {
        debugPrint('❌ No auth token found, cannot connect to socket');
        return;
      }

      // Dispose stale socket if any
      _socket?.dispose();
      _socket = null;

      _socket = io.io(
        ApiConstants.baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(2000)
            .build(),
      );

      _setupEventListeners();

      // Wait up to 5 s for the socket to confirm it is connected
      for (int i = 0; i < 50; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_isConnected) break;
      }
    } finally {
      _isConnecting = false;
    }
  }

  void _setupEventListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;
      _isConnecting = false;
      _joinedConversations.clear(); // rooms are gone after reconnect

      debugPrint('✅ Socket connected');

      // Notify all registered re-join handlers (e.g. active ChatBloc)
      for (final fn in List.from(_reconnectListeners)) {
        try {
          fn();
        } catch (e) {
          debugPrint('❌ Error in reconnect listener: $e');
        }
      }
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      _joinedConversations.clear();
      debugPrint('🔌 Socket disconnected');
    });

    _socket?.onConnectError((error) {
      _isConnected = false;
      _isConnecting = false;
      debugPrint('❌ Socket connection error: $error');
    });

    _socket?.onError((error) {
      debugPrint('❌ Socket error: $error');
      for (final l in List.from(_errorListeners)) {
        try {
          l(error.toString());
        } catch (e) {
          debugPrint('❌ Error in error listener: $e');
        }
      }
    });

    // ── message:new → only active ChatBloc (per-conversation) ──
    _socket?.on('message:new', (data) {
      debugPrint('📩 message:new received');
      if (data == null) return;
      final payload = Map<String, dynamic>.from(data);
      for (final l in List.from(_messageListeners)) {
        try {
          l(payload);
        } catch (e) {
          debugPrint('❌ Error in message listener: $e');
        }
      }
    });

    // ── message:notification → global ConversationsBloc only ──
    // Sent to the recipient's personal room for every inbound message.
    // ChatBloc must NOT handle this — it would drop messages for other
    // conversations and cause duplicates for the current one.
    _socket?.on('message:notification', (data) {
      debugPrint('🔔 message:notification received');
      if (data == null) return;
      final payload = Map<String, dynamic>.from(data);
      for (final l in List.from(_notificationListeners)) {
        try {
          l(payload);
        } catch (e) {
          debugPrint('❌ Error in notification listener: $e');
        }
      }
    });

    // ── message:sent confirmation ──
    _socket?.on('message:sent', (data) {
      if (data == null) return;
      final messageId = data['messageId']?.toString() ?? '';
      final conversationId = data['conversationId']?.toString() ?? '';
      for (final l in List.from(_messageSentListeners)) {
        try {
          l(messageId, conversationId);
        } catch (e) {
          debugPrint('❌ Error in message-sent listener: $e');
        }
      }
    });

    // ── typing ──
    _socket?.on('typing:update', (data) {
      if (data == null) return;
      for (final l in List.from(_typingListeners)) {
        try {
          l(Map<String, dynamic>.from(data));
        } catch (e) {
          debugPrint('❌ Error in typing listener: $e');
        }
      }
    });

    // ── online / offline ──
    _socket?.on('user:online', (data) {
      if (data == null) return;
      final userId = data['userId']?.toString() ?? '';
      for (final l in List.from(_userOnlineListeners)) {
        try {
          l(userId);
        } catch (e) {
          debugPrint('❌ Error in user-online listener: $e');
        }
      }
    });

    _socket?.on('user:offline', (data) {
      if (data == null) return;
      final userId = data['userId']?.toString() ?? '';
      for (final l in List.from(_userOfflineListeners)) {
        try {
          l(userId);
        } catch (e) {
          debugPrint('❌ Error in user-offline listener: $e');
        }
      }
    });

    // ── read receipts ──
    _socket?.on('message:read', (data) {
      if (data == null) return;
      for (final l in List.from(_messageReadListeners)) {
        try {
          l(Map<String, dynamic>.from(data));
        } catch (e) {
          debugPrint('❌ Error in message-read listener: $e');
        }
      }
    });

    // ── server-side errors ──
    _socket?.on('error', (data) {
      final message = data?['message']?.toString() ?? 'Unknown error';
      debugPrint('⚠️ Server error: $message');
      for (final l in List.from(_errorListeners)) {
        try {
          l(message);
        } catch (e) {
          debugPrint('❌ Error in error listener: $e');
        }
      }
    });
  }

  // ============================================================
  // EMITTERS
  // ============================================================

  /// Join a conversation room.
  /// Returns true if the emit was sent, false if socket not ready.
  bool joinConversation(String conversationId) {
    if (conversationId.isEmpty) return false;
    if (!_isConnected || _socket == null) {
      debugPrint('⚠️ joinConversation: socket not connected');
      return false;
    }
    if (_joinedConversations.contains(conversationId)) {
      debugPrint('🔌 Already joined conversation: $conversationId');
      return true;
    }
    _joinedConversations.add(conversationId);
    _socket?.emit('conversation:join', {'conversationId': conversationId});
    debugPrint('📥 Joined conversation: $conversationId');
    return true;
  }

  void leaveConversation(String conversationId) {
    if (conversationId.isEmpty) return;
    _joinedConversations.remove(conversationId);
    _socket?.emit('conversation:leave', {'conversationId': conversationId});
    debugPrint('📤 Left conversation: $conversationId');
  }

  void sendMessage({
    required String conversationId,
    String? text,
    String? image,
  }) {
    if (!_isConnected || _socket == null) {
      debugPrint('⚠️ sendMessage: socket not connected');
      return;
    }
    if (text == null && image == null) {
      debugPrint('⚠️ sendMessage: nothing to send');
      return;
    }
    final data = <String, dynamic>{'conversationId': conversationId};
    if (text != null) data['text'] = text;
    if (image != null) data['image'] = {'url': image};
    debugPrint('📤 Sending message to $conversationId');
    _socket?.emit('message:send', data);
  }

  void startTyping(String conversationId) {
    _socket?.emit('typing:start', {'conversationId': conversationId});
  }

  void stopTyping(String conversationId) {
    _socket?.emit('typing:stop', {'conversationId': conversationId});
  }

  void markMessagesRead(String conversationId) {
    _socket?.emit('message:read', {'conversationId': conversationId});
  }

  void checkOnlineStatus(List<String> userIds) {
    _socket?.emit('user:check-online', {'userIds': userIds});
  }

  // ============================================================
  // LISTENERS — message:new (per-conversation, ChatBloc only)
  // ============================================================

  void addMessageListener(void Function(Map<String, dynamic>) l) =>
      _messageListeners.add(l);
  void removeMessageListener(void Function(Map<String, dynamic>) l) =>
      _messageListeners.remove(l);

  // ============================================================
  // LISTENERS — message:notification (global, ConversationsBloc)
  // ============================================================

  void addNotificationListener(void Function(Map<String, dynamic>) l) =>
      _notificationListeners.add(l);
  void removeNotificationListener(void Function(Map<String, dynamic>) l) =>
      _notificationListeners.remove(l);

  // ============================================================
  // LISTENERS — reconnect (ChatBloc re-join)
  // ============================================================

  void addReconnectListener(void Function() l) => _reconnectListeners.add(l);
  void removeReconnectListener(void Function() l) =>
      _reconnectListeners.remove(l);

  // ============================================================
  // LISTENERS — other events
  // ============================================================

  void addTypingListener(void Function(Map<String, dynamic>) l) =>
      _typingListeners.add(l);
  void removeTypingListener(void Function(Map<String, dynamic>) l) =>
      _typingListeners.remove(l);

  void addUserOnlineListener(void Function(String) l) =>
      _userOnlineListeners.add(l);
  void removeUserOnlineListener(void Function(String) l) =>
      _userOnlineListeners.remove(l);

  void addUserOfflineListener(void Function(String) l) =>
      _userOfflineListeners.add(l);
  void removeUserOfflineListener(void Function(String) l) =>
      _userOfflineListeners.remove(l);

  void addMessageSentListener(void Function(String, String) l) =>
      _messageSentListeners.add(l);
  void removeMessageSentListener(void Function(String, String) l) =>
      _messageSentListeners.remove(l);

  void addMessageReadListener(void Function(Map<String, dynamic>) l) =>
      _messageReadListeners.add(l);
  void removeMessageReadListener(void Function(Map<String, dynamic>) l) =>
      _messageReadListeners.remove(l);

  void addErrorListener(void Function(String) l) => _errorListeners.add(l);
  void removeErrorListener(void Function(String) l) =>
      _errorListeners.remove(l);

  // ============================================================
  // LIFECYCLE
  // ============================================================

  /// Reconnect if the app resumes from background and the socket dropped.
  Future<void> reconnectIfNeeded() async {
    if (!_isConnected && !_isConnecting) {
      debugPrint('🔄 App resumed — reconnecting socket…');
      await connect();
    }
  }

  void disconnect() {
    _joinedConversations.clear();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _isConnecting = false;
    debugPrint('🔌 Socket disposed');
  }

  void clearAllListeners() {
    _messageListeners.clear();
    _notificationListeners.clear();
    _typingListeners.clear();
    _userOnlineListeners.clear();
    _userOfflineListeners.clear();
    _messageSentListeners.clear();
    _messageReadListeners.clear();
    _errorListeners.clear();
    _reconnectListeners.clear();
  }
}

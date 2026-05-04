import 'package:dartz/dartz.dart';
import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/network/api_exceptions.dart';
import 'package:book_user_app/core/services/socket_service.dart';
import 'package:book_user_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:book_user_app/features/auth/domain/entities/user.dart';
import 'package:book_user_app/features/chat/data/models/chat_message.dart';
import 'package:book_user_app/features/chat/data/models/conversation.dart';

/// Repository for chat operations
/// Combines socket (real-time) and HTTP (fallback/initial load)
class ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  final SocketService _socketService;

  ChatRepository({
    ChatRemoteDataSource? remoteDataSource,
    SocketService? socketService,
  }) : _remoteDataSource = remoteDataSource ?? ChatRemoteDataSource(),
       _socketService = socketService ?? SocketService();

  // ============== CONNECTION ==============

  /// Connect to socket server
  Future<void> connectSocket() async {
    await _socketService.connect();
  }

  /// Disconnect from socket
  void disconnectSocket() {
    _socketService.disconnect();
  }

  bool get isSocketConnected => _socketService.isConnected;

  // ============== CONVERSATIONS ==============

  /// Get all conversations
  Future<Either<Failure, List<Conversation>>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final conversations = await _remoteDataSource.getConversations(
        page: page,
        limit: limit,
      );
      return Right(conversations);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Create or get existing conversation
  Future<Either<Failure, Conversation>> createConversation({
    required String listingId,
    required String sellerId,
  }) async {
    try {
      final conversation = await _remoteDataSource.createConversation(
        listingId: listingId,
        sellerId: sellerId,
      );
      return Right(conversation);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Delete a conversation
  Future<Either<Failure, void>> deleteConversation(
    String conversationId,
  ) async {
    try {
      await _remoteDataSource.deleteConversation(conversationId);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ============== MESSAGES ==============

  /// Get messages for a conversation (initial load via HTTP)
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final messages = await _remoteDataSource.getMessages(
        conversationId,
        page: page,
        limit: limit,
      );
      return Right(messages);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Send a message via socket when connected, otherwise HTTP for plain text.
  ///
  /// Returns `Right(null)` when sent on the socket (confirmation via realtime).
  /// Returns `Right(serverMessage)` when sent over HTTP.
  Future<Either<Failure, ChatMessage?>> sendMessage({
    required String conversationId,
    String? text,
    String? imageUrl,
    String? messageType,
    Map<String, dynamic>? metadata,
  }) async {
    if (_socketService.isConnected) {
      _socketService.sendMessage(
        conversationId: conversationId,
        text: text,
        image: imageUrl,
        messageType: messageType,
        metadata: metadata,
      );
      return const Right(null);
    }

    if (messageType == 'offer') {
      return const Left(
        ServerFailure(
          'Chat is disconnected. Reconnect to send offers.',
        ),
      );
    }

    if (imageUrl != null) {
      return const Left(
        ServerFailure(
          'Chat is disconnected. Reconnect to send images.',
        ),
      );
    }

    final trimmed = text?.trim() ?? '';
    if (trimmed.isEmpty) {
      return const Left(ServerFailure('Nothing to send.'));
    }

    try {
      final msg = await _remoteDataSource.sendMessage(
        conversationId,
        text: trimmed,
      );
      return Right(msg);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Send location message via socket only (no REST equivalent).
  Future<Either<Failure, void>> sendLocationMessage({
    required String conversationId,
    required double latitude,
    required double longitude,
  }) async {
    if (!_socketService.isConnected) {
      return const Left(
        ServerFailure(
          'Chat is disconnected. Reconnect to send your location.',
        ),
      );
    }
    _socketService.sendMessage(
      conversationId: conversationId,
      location: {'latitude': latitude, 'longitude': longitude},
    );
    return const Right(null);
  }

  /// Upload image and return URL
  Future<Either<Failure, String>> uploadImage(
    String conversationId,
    String imagePath,
  ) async {
    try {
      final url = await _remoteDataSource.uploadChatImage(
        conversationId,
        imagePath,
      );
      return Right(url);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Mark messages as read
  Future<Either<Failure, void>> markAsRead(String conversationId) async {
    try {
      // HTTP call for persistence
      await _remoteDataSource.markAsRead(conversationId);
      // Socket call for real-time notification
      _socketService.markMessagesRead(conversationId);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ============== REAL-TIME LISTENERS ==============

  /// Join a conversation room (for real-time messages)
  void joinConversation(String conversationId) {
    _socketService.joinConversation(conversationId);
  }

  /// Leave a conversation room
  void leaveConversation(String conversationId) {
    _socketService.leaveConversation(conversationId);
  }

  /// Start typing indicator
  void startTyping(String conversationId) {
    _socketService.startTyping(conversationId);
  }

  /// Stop typing indicator
  void stopTyping(String conversationId) {
    _socketService.stopTyping(conversationId);
  }

  // ── per-conversation messages (ChatBloc only) ──
  void addMessageListener(void Function(Map<String, dynamic>) listener) =>
      _socketService.addMessageListener(listener);
  void removeMessageListener(void Function(Map<String, dynamic>) listener) =>
      _socketService.removeMessageListener(listener);

  // ── cross-conversation notifications (global ConversationsBloc) ──
  void addNotificationListener(void Function(Map<String, dynamic>) listener) =>
      _socketService.addNotificationListener(listener);
  void removeNotificationListener(
    void Function(Map<String, dynamic>) listener,
  ) => _socketService.removeNotificationListener(listener);

  // ── socket reconnect (ChatBloc re-join) ──
  void addReconnectListener(void Function() listener) =>
      _socketService.addReconnectListener(listener);
  void removeReconnectListener(void Function() listener) =>
      _socketService.removeReconnectListener(listener);

  /// Listen for typing updates
  void addTypingListener(void Function(Map<String, dynamic>) listener) {
    _socketService.addTypingListener(listener);
  }

  void removeTypingListener(void Function(Map<String, dynamic>) listener) {
    _socketService.removeTypingListener(listener);
  }

  /// Listen for offer updates
  void addOfferUpdatedListener(void Function(Map<String, dynamic>) listener) {
    _socketService.addOfferUpdatedListener(listener);
  }

  void removeOfferUpdatedListener(void Function(Map<String, dynamic>) listener) {
    _socketService.removeOfferUpdatedListener(listener);
  }

  /// Listen for user online/offline
  void addUserOnlineListener(void Function(String) listener) {
    _socketService.addUserOnlineListener(listener);
  }

  void removeUserOnlineListener(void Function(String) listener) {
    _socketService.removeUserOnlineListener(listener);
  }

  void addUserOfflineListener(void Function(String) listener) {
    _socketService.addUserOfflineListener(listener);
  }

  void removeUserOfflineListener(void Function(String) listener) {
    _socketService.removeUserOfflineListener(listener);
  }

  // ============== BLOCKING ==============

  /// Get blocked users
  Future<Either<Failure, List<User>>> getBlockedUsers() async {
    try {
      final blockedUsers = await _remoteDataSource.getBlockedUsers();
      return Right(blockedUsers);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Block a user
  Future<Either<Failure, void>> blockUser(String userId) async {
    try {
      await _remoteDataSource.blockUser(userId);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Unblock a user
  Future<Either<Failure, void>> unblockUser(String userId) async {
    try {
      await _remoteDataSource.unblockUser(userId);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:book_user_app/core/network/api_client.dart';
import 'package:book_user_app/core/network/api_exceptions.dart';
import 'package:book_user_app/core/network/api_response.dart';
import 'package:book_user_app/features/auth/data/models/user_model.dart';
import 'package:book_user_app/features/chat/data/models/chat_message.dart';
import 'package:book_user_app/features/chat/data/models/conversation.dart';
import 'package:dio/dio.dart';

/// Remote data source for chat API operations
class ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // ============== CONVERSATIONS ==============

  /// Get all conversations for the current user
  Future<List<Conversation>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.chat}/conversations',
      queryParameters: {'page': page, 'limit': limit},
    );

    throwIfApiFailure(response);
    final data = response.data as Map<String, dynamic>;
    if (data['success'] == false) {
      throw ApiException(
        message: data['message']?.toString() ?? 'Failed to load conversations',
        statusCode: response.statusCode,
      );
    }
    final conversations = (data['data'] as List?) ?? [];
    return conversations
        .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Create a new conversation or get existing one
  Future<Conversation> createConversation({
    required String listingId,
    required String sellerId,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.chat}/conversations',
      data: {'listingId': listingId, 'sellerId': sellerId},
    );

    throwIfApiFailure(response);
    final data = response.data as Map<String, dynamic>;

    if (data['success'] == false) {
      throw ApiException(
        message: data['message']?.toString() ?? 'Failed to create conversation',
        statusCode: response.statusCode,
      );
    }

    final conversationData = data['data'] as Map<String, dynamic>?;
    if (conversationData == null) {
      throw ApiException(
        message: 'No conversation data returned',
        statusCode: response.statusCode,
      );
    }

    return Conversation.fromJson(conversationData);
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    final response = await _apiClient.delete(
      '${ApiConstants.chat}/conversations/$conversationId',
    );
    throwIfApiFailure(response);
  }

  // ============== MESSAGES ==============

  /// Get messages for a conversation
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.chat}/conversations/$conversationId/messages',
      queryParameters: {'page': page, 'limit': limit},
    );

    throwIfApiFailure(response);
    final data = response.data as Map<String, dynamic>;
    if (data['success'] == false) {
      throw ApiException(
        message: data['message']?.toString() ?? 'Failed to load messages',
        statusCode: response.statusCode,
      );
    }
    final messages = (data['data'] as List?) ?? [];
    return messages
        .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Send a message via HTTP (fallback for when socket fails)
  Future<ChatMessage> sendMessage(
    String conversationId, {
    String? text,
    String? imagePath,
  }) async {
    final formData = FormData();

    if (text != null) {
      formData.fields.add(MapEntry('text', text));
    }

    if (imagePath != null) {
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(imagePath, filename: 'chat_image.jpg'),
        ),
      );
    }

    final response = await _apiClient.post(
      '${ApiConstants.chat}/conversations/$conversationId/messages',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    throwIfApiFailure(response);
    final data = response.data as Map<String, dynamic>;
    final messageJson = data['data'] as Map<String, dynamic>?;
    if (messageJson == null) {
      throw ApiException(
        message: 'No message in response',
        statusCode: response.statusCode,
      );
    }
    return ChatMessage.fromJson(messageJson);
  }

  /// Upload chat image and get URL
  Future<String> uploadChatImage(
    String conversationId,
    String imagePath,
  ) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imagePath,
        filename: 'chat_image.jpg',
      ),
    });

    final response = await _apiClient.post(
      '${ApiConstants.chat}/conversations/$conversationId/images',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    throwIfApiFailure(response);
    final data = response.data as Map<String, dynamic>;
    final url = data['imageUrl'] as String?;
    if (url == null || url.isEmpty) {
      throw ApiException(
        message: 'No image URL in response',
        statusCode: response.statusCode,
      );
    }
    return url;
  }

  /// Mark messages in a conversation as read
  Future<void> markAsRead(String conversationId) async {
    final response = await _apiClient.put(
      '${ApiConstants.chat}/conversations/$conversationId/read',
    );
    throwIfApiFailure(response);
  }

  /// Edit a message
  Future<ChatMessage> editMessage(String messageId, String newText) async {
    final response = await _apiClient.put(
      '${ApiConstants.chat}/messages/$messageId',
      data: {'text': newText},
    );

    throwIfApiFailure(response);
    final data = response.data as Map<String, dynamic>;
    final messageJson = data['data'] as Map<String, dynamic>?;
    if (messageJson == null) {
      throw ApiException(
        message: 'No message in response',
        statusCode: response.statusCode,
      );
    }
    return ChatMessage.fromJson(messageJson);
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    final response = await _apiClient.delete(
      '${ApiConstants.chat}/messages/$messageId',
    );
    throwIfApiFailure(response);
  }

  // ============== BLOCKING ==============

  /// Get blocked users
  Future<List<UserModel>> getBlockedUsers() async {
    final response = await _apiClient.get('${ApiConstants.chat}/blocked');
    throwIfApiFailure(response);
    final data = response.data as Map<String, dynamic>;
    if (data['success'] == false) {
      throw ApiException(
        message: data['message']?.toString() ?? 'Failed to load blocked users',
        statusCode: response.statusCode,
      );
    }
    final blocked = (data['data'] as List?) ?? [];
    return blocked
        .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  /// Block a user
  Future<void> blockUser(String userId) async {
    final response = await _apiClient.post(
      '${ApiConstants.chat}/block/$userId',
    );
    throwIfApiFailure(response);
  }

  /// Unblock a user
  Future<void> unblockUser(String userId) async {
    final response = await _apiClient.delete(
      '${ApiConstants.chat}/block/$userId',
    );
    throwIfApiFailure(response);
  }
}

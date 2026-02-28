import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:book_user_app/features/chat/data/models/chat_message.dart';
import 'package:book_user_app/features/chat/data/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final FlutterSecureStorage _storage;
  String? _currentUserId;

  bool _listenersSetUp = false;

  /// Set of processed message IDs to prevent duplicates
  final Set<String> _processedMessageIds = {};

  String? get currentUserId => _currentUserId;

  ChatBloc({ChatRepository? repository, FlutterSecureStorage? storage})
    : _repository = repository ?? ChatRepository(),
      _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          ),
      super(const ChatState()) {
    on<LoadMessages>(_onLoadMessages);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<SendTextMessage>(_onSendTextMessage);
    on<SendLocationMessage>(_onSendLocationMessage);
    on<SendImageMessage>(_onSendImageMessage);
    on<MessageReceived>(_onMessageReceived);
    on<TypingUpdate>(_onTypingUpdate);
    on<StartTyping>(_onStartTyping);
    on<StopTyping>(_onStopTyping);
    on<UserOnlineStatusChanged>(_onUserOnlineStatusChanged);
    on<MarkAsRead>(_onMarkAsRead);
    on<LeaveConversation>(_onLeaveConversation);
  }

  // ── Listener registration ────────────────────────────────────

  void _setupListeners() {
    if (_listenersSetUp) return;
    _listenersSetUp = true;

    // ChatBloc only cares about message:new events for the open conversation.
    _repository.addMessageListener(_handleNewMessage);
    _repository.addTypingListener(_handleTypingUpdate);
    _repository.addUserOnlineListener(_handleUserOnline);
    _repository.addUserOfflineListener(_handleUserOffline);

    // When the socket reconnects (e.g. network drop), re-join the room so
    // message:new events start arriving again.
    _repository.addReconnectListener(_handleReconnect);
  }

  void _removeListeners() {
    if (!_listenersSetUp) return;
    _listenersSetUp = false;

    _repository.removeMessageListener(_handleNewMessage);
    _repository.removeTypingListener(_handleTypingUpdate);
    _repository.removeUserOnlineListener(_handleUserOnline);
    _repository.removeUserOfflineListener(_handleUserOffline);
    _repository.removeReconnectListener(_handleReconnect);
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    if (!isClosed) add(MessageReceived(data));
  }

  void _handleTypingUpdate(Map<String, dynamic> data) {
    if (!isClosed) {
      final users =
          (data['users'] as List?)?.whereType<String>().toList() ?? [];
      add(TypingUpdate(users));
    }
  }

  void _handleUserOnline(String userId) {
    if (!isClosed) add(UserOnlineStatusChanged(userId: userId, isOnline: true));
  }

  void _handleUserOffline(String userId) {
    if (!isClosed)
      add(UserOnlineStatusChanged(userId: userId, isOnline: false));
  }

  /// Called when the socket re-establishes a connection.
  /// Re-join the current conversation room so message:new resumes.
  void _handleReconnect() {
    final convId = state.conversationId;
    if (convId.isNotEmpty) {
      debugPrint('🔄 Socket reconnected — re-joining conversation $convId');
      _repository.joinConversation(convId);
    }
  }

  // ── Event handlers ───────────────────────────────────────────

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ChatStatus.loading,
        conversationId: event.conversationId,
      ),
    );

    _currentUserId = await _storage.read(key: StorageKeys.userId);
    _processedMessageIds.clear();

    // Set up listeners BEFORE connecting so no events are missed
    _setupListeners();

    // Connect socket
    await _repository.connectSocket();

    // Retry joining the room: wait up to 5 s for socket to confirm connected
    bool joined = false;
    for (int attempt = 0; attempt < 10; attempt++) {
      if (_repository.isSocketConnected) {
        _repository.joinConversation(event.conversationId);
        joined = true;
        break;
      }
      await Future.delayed(Duration(milliseconds: 200 * (attempt + 1)));
    }

    if (!joined) {
      debugPrint(
        '⚠️ Could not join socket room for ${event.conversationId} — '
        'running in HTTP-only mode',
      );
    }

    // Load initial batch via HTTP
    final result = await _repository.getMessages(
      event.conversationId,
      page: event.page,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: ChatStatus.error, error: failure.message),
      ),
      (messages) {
        for (final msg in messages) {
          _processedMessageIds.add(msg.id);
        }
        emit(
          state.copyWith(
            status: ChatStatus.loaded,
            messages: messages,
            currentPage: event.page,
            hasMore: messages.length >= 50,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (!state.hasMore || state.status == ChatStatus.loading) return;

    final nextPage = state.currentPage + 1;
    final result = await _repository.getMessages(
      state.conversationId,
      page: nextPage,
    );

    result.fold(
      (failure) {}, // Silently skip pagination failures
      (messages) {
        final allMessages = [...state.messages, ...messages];
        emit(
          state.copyWith(
            messages: allMessages,
            currentPage: nextPage,
            hasMore: messages.length >= 50,
          ),
        );
      },
    );
  }

  Future<void> _onSendTextMessage(
    SendTextMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (event.text.trim().isEmpty) return;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final localMessage = ChatMessage.local(
      tempId: tempId,
      conversationId: state.conversationId,
      sender: MessageSender(id: _currentUserId ?? '', name: 'You'),
      text: event.text,
    );

    // Optimistic UI
    emit(
      state.copyWith(
        status: ChatStatus.sending,
        messages: [localMessage, ...state.messages],
        sendingMessageId: tempId,
      ),
    );

    _repository.sendMessage(
      conversationId: state.conversationId,
      text: event.text,
    );
    _repository.stopTyping(state.conversationId);

    emit(state.copyWith(status: ChatStatus.loaded, sendingMessageId: null));
  }

  Future<void> _onSendLocationMessage(
    SendLocationMessage event,
    Emitter<ChatState> emit,
  ) async {
    _repository.sendLocationMessage(
      conversationId: state.conversationId,
      latitude: event.latitude,
      longitude: event.longitude,
    );
  }

  Future<void> _onSendImageMessage(
    SendImageMessage event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.sending));

    final uploadResult = await _repository.uploadImage(
      state.conversationId,
      event.imagePath,
    );

    await uploadResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: ChatStatus.error,
            error: 'Failed to upload image',
          ),
        );
      },
      (imageUrl) async {
        final tempId = 'temp_img_${DateTime.now().millisecondsSinceEpoch}';
        final localMessage = ChatMessage(
          id: tempId,
          conversation: state.conversationId,
          sender: MessageSender(id: _currentUserId ?? '', name: 'You'),
          image: ImageData(url: imageUrl),
          messageType: MessageType.image,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        emit(
          state.copyWith(
            status: ChatStatus.loaded,
            messages: [localMessage, ...state.messages],
          ),
        );

        _repository.sendMessage(
          conversationId: state.conversationId,
          imageUrl: imageUrl,
        );
      },
    );
  }

  void _onMessageReceived(MessageReceived event, Emitter<ChatState> emit) {
    try {
      final messageData = event.data['message'] as Map<String, dynamic>?;
      if (messageData == null) {
        debugPrint('⚠️ MessageReceived: no message data');
        return;
      }

      final message = ChatMessage.fromJson(messageData);

      // Only handle messages for the currently open conversation
      if (message.conversation != state.conversationId) {
        debugPrint(
          '⚠️ MessageReceived: message belongs to a different conversation — ignoring',
        );
        return;
      }

      // Deduplicate
      if (_processedMessageIds.contains(message.id)) {
        debugPrint('⚠️ MessageReceived: duplicate ${message.id} — skipping');
        return;
      }
      _processedMessageIds.add(message.id);

      // Remove the matching optimistic temp message (if any)
      final updatedMessages = state.messages.where((m) {
        if (!m.id.startsWith('temp_')) return true;
        final isMatch =
            m.text == message.text &&
            m.sender.id == message.sender.id &&
            m.messageType == message.messageType &&
            message.createdAt.difference(m.createdAt).inSeconds.abs() < 30;
        return !isMatch;
      }).toList();

      emit(state.copyWith(messages: [message, ...updatedMessages]));
    } catch (e, stack) {
      debugPrint('❌ MessageReceived error: $e\n$stack');
    }
  }

  void _onTypingUpdate(TypingUpdate event, Emitter<ChatState> emit) {
    final typingUsers = event.typingUsers
        .where((id) => id != _currentUserId)
        .toList();
    emit(state.copyWith(typingUsers: typingUsers));
  }

  void _onStartTyping(StartTyping event, Emitter<ChatState> emit) {
    _repository.startTyping(state.conversationId);
  }

  void _onStopTyping(StopTyping event, Emitter<ChatState> emit) {
    _repository.stopTyping(state.conversationId);
  }

  void _onUserOnlineStatusChanged(
    UserOnlineStatusChanged event,
    Emitter<ChatState> emit,
  ) {
    if (event.userId == state.otherUserId) {
      emit(state.copyWith(isOtherUserOnline: event.isOnline));
    }
  }

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<ChatState> emit) async {
    await _repository.markAsRead(state.conversationId);
  }

  void _onLeaveConversation(LeaveConversation event, Emitter<ChatState> emit) {
    _repository.leaveConversation(state.conversationId);
    _repository.stopTyping(state.conversationId);
  }

  @override
  Future<void> close() {
    _removeListeners();
    _processedMessageIds.clear();
    if (state.conversationId.isNotEmpty) {
      _repository.leaveConversation(state.conversationId);
    }
    return super.close();
  }
}

import 'package:book_user_app/features/chat/data/models/chat_message.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:book_user_app/features/chat/data/models/conversation.dart';
import 'package:book_user_app/features/chat/data/repositories/chat_repository.dart';

part 'conversations_event.dart';
part 'conversations_state.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final ChatRepository _repository;
  final FlutterSecureStorage _storage;
  String? _currentUserId;
  bool _listeningSetUp = false;

  ConversationsBloc({ChatRepository? repository, FlutterSecureStorage? storage})
    : _repository = repository ?? ChatRepository(),
      _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          ),
      super(const ConversationsState()) {
    on<LoadConversations>(_onLoadConversations);
    on<RefreshConversations>(_onRefreshConversations);
    on<StartConversationsListening>(_onStartListening);
    on<StopConversationsListening>(_onStopListening);
    on<ConversationUpdated>(_onConversationUpdated);
    on<DeleteConversation>(_onDeleteConversation);
  }

  String? get currentUserId => _currentUserId;

  @override
  Future<void> close() {
    // Use notification channel — not message channel
    _repository.removeNotificationListener(_handleIncomingNotification);
    _listeningSetUp = false;
    return super.close();
  }

  // ── Handler: called for EVERY message:notification received on this device ──
  // This fires regardless of which screen the user is on.
  void _handleIncomingNotification(Map<String, dynamic> data) {
    if (!isClosed) {
      add(ConversationUpdated(data));
    }
  }

  Future<void> _onStartListening(
    StartConversationsListening event,
    Emitter<ConversationsState> emit,
  ) async {
    if (_listeningSetUp) return;
    _listeningSetUp = true;

    // Ensure socket is connected so notifications can arrive.
    // Safe to call if already connected — it's a no-op.
    await _repository.connectSocket();

    // Subscribe to the notification channel (NOT the per-conversation
    // message:new channel which belongs to ChatBloc exclusively).
    _repository.addNotificationListener(_handleIncomingNotification);
  }

  void _onStopListening(
    StopConversationsListening event,
    Emitter<ConversationsState> emit,
  ) {
    _repository.removeNotificationListener(_handleIncomingNotification);
    _listeningSetUp = false;
  }

  Future<void> _onConversationUpdated(
    ConversationUpdated event,
    Emitter<ConversationsState> emit,
  ) async {
    // message:notification payload has a nested "message" object
    final messageData = event.data['message'] as Map<String, dynamic>?;
    if (messageData == null) return;

    try {
      final message = ChatMessage.fromJson(messageData);
      final conversationId = message.conversation;

      final index = state.conversations.indexWhere(
        (c) => c.id == conversationId,
      );

      if (index != -1) {
        // Known conversation — refresh to pull latest preview + unread count
        add(const LoadConversations(page: 1, refresh: true));
      } else {
        // Brand-new conversation the user hasn't seen yet — refresh list
        add(const LoadConversations(page: 1, refresh: true));
      }
    } catch (_) {
      // Non-fatal: ignore parse errors
    }
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationsState> emit,
  ) async {
    _currentUserId ??= await _storage.read(key: StorageKeys.userId);

    // Start listening the first time conversations are loaded
    if (event.page == 1 && !_listeningSetUp) {
      add(const StartConversationsListening());
    }

    if (event.refresh) {
      emit(state.copyWith(status: ConversationsStatus.loading));
    } else if (state.conversations.isEmpty) {
      emit(state.copyWith(status: ConversationsStatus.loading));
    }

    final result = await _repository.getConversations(
      page: event.page,
      limit: 20,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ConversationsStatus.error,
          error: failure.message,
        ),
      ),
      (conversations) {
        final allConversations = event.refresh || event.page == 1
            ? conversations
            : [...state.conversations, ...conversations];

        emit(
          state.copyWith(
            status: ConversationsStatus.loaded,
            conversations: allConversations,
            currentPage: event.page,
            hasMore: conversations.length >= 20,
          ),
        );
      },
    );
  }

  Future<void> _onRefreshConversations(
    RefreshConversations event,
    Emitter<ConversationsState> emit,
  ) async {
    add(const LoadConversations(page: 1, refresh: true));
  }

  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<ConversationsState> emit,
  ) async {
    final result = await _repository.deleteConversation(event.conversationId);

    result.fold(
      (failure) {
        // Show error but keep item in list
      },
      (_) {
        final updated = state.conversations
            .where((c) => c.id != event.conversationId)
            .toList();
        emit(state.copyWith(conversations: updated));
      },
    );
  }
}

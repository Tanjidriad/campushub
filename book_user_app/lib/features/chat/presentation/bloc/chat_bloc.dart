import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:book_user_app/core/services/listing_status_notifier.dart';
import 'package:book_user_app/features/chat/data/models/chat_message.dart';
import 'package:book_user_app/features/chat/data/repositories/chat_repository.dart';
import 'package:book_user_app/features/offers/data/datasources/offer_remote_datasource.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final FlutterSecureStorage _storage;
  final OfferRemoteDataSource? _offerDataSource;
  String? _currentUserId;

  bool _listenersSetUp = false;

  // Store stable handler references so we can reliably add/remove socket listeners.
  late void Function(Map<String, dynamic>) _newMessageListener;
  late void Function(Map<String, dynamic>) _typingUpdateListener;
  late void Function(Map<String, dynamic>) _offerUpdatedListener;
  late void Function(String) _userOnlineListener;
  late void Function(String) _userOfflineListener;
  late void Function() _reconnectListener;

  /// Set of processed message IDs to prevent duplicates
  final Set<String> _processedMessageIds = {};

  String? get currentUserId => _currentUserId;

  ChatBloc({ChatRepository? repository, FlutterSecureStorage? storage, OfferRemoteDataSource? offerDataSource})
    : _repository = repository ?? ChatRepository(),
      _offerDataSource = offerDataSource,
      _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          ),
      super(const ChatState()) {
    _newMessageListener = _handleNewMessage;
    _typingUpdateListener = _handleTypingUpdate;
    _offerUpdatedListener = _handleOfferUpdated;
    _userOnlineListener = _handleUserOnline;
    _userOfflineListener = _handleUserOffline;
    _reconnectListener = _handleReconnect;

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
    on<BlockUser>(_onBlockUser);
    on<UnblockUser>(_onUnblockUser);
    on<CheckBlockStatus>(_onCheckBlockStatus);
    on<SendOfferMessage>(_onSendOfferMessage);
    on<RespondToOfferInChat>(_onRespondToOfferInChat);
    on<OfferUpdatedReceived>(_onOfferUpdatedReceived);
  }

  // ── Listener registration ────────────────────────────────────

  void _setupListeners() {
    if (_listenersSetUp) return;
    _listenersSetUp = true;

    // ChatBloc only cares about message:new events for the open conversation.
    _repository.addMessageListener(_newMessageListener);
    _repository.addTypingListener(_typingUpdateListener);
    _repository.addOfferUpdatedListener(_offerUpdatedListener);
    _repository.addUserOnlineListener(_userOnlineListener);
    _repository.addUserOfflineListener(_userOfflineListener);

    // When the socket reconnects (e.g. network drop), re-join the room so
    // message:new events start arriving again.
    _repository.addReconnectListener(_reconnectListener);
  }

  void _removeListeners() {
    if (!_listenersSetUp) return;
    _listenersSetUp = false;

    _repository.removeMessageListener(_newMessageListener);
    _repository.removeTypingListener(_typingUpdateListener);
    _repository.removeOfferUpdatedListener(_offerUpdatedListener);
    _repository.removeUserOnlineListener(_userOnlineListener);
    _repository.removeUserOfflineListener(_userOfflineListener);
    _repository.removeReconnectListener(_reconnectListener);
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

  void _handleOfferUpdated(Map<String, dynamic> data) {
    if (!isClosed) add(OfferUpdatedReceived(data));
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

    // Start socket connection in the background so it doesn't block HTTP fetch
    _connectAndJoinSocket(event.conversationId);

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

        // Determine otherUserId from messages if not already known
        String? detectedOtherUserId;
        if (_currentUserId != null && _currentUserId!.isNotEmpty) {
          for (final msg in messages) {
            if (msg.sender.id != _currentUserId) {
              detectedOtherUserId = msg.sender.id;
              break;
            }
          }
        }

        emit(
          state.copyWith(
            status: ChatStatus.loaded,
            messages: messages,
            currentPage: event.page,
            hasMore: messages.length >= 50,
            otherUserId: detectedOtherUserId,
          ),
        );

        // Check block status after loading
        if (detectedOtherUserId != null) {
          add(CheckBlockStatus(detectedOtherUserId));
        }
      },
    );
  }

  Future<void> _connectAndJoinSocket(String conversationId) async {
    await _repository.connectSocket();

    final joinDeadline = DateTime.now().add(const Duration(seconds: 15));
    bool joined = false;
    while (DateTime.now().isBefore(joinDeadline)) {
      if (_repository.isSocketConnected) {
        _repository.joinConversation(conversationId);
        joined = true;
        break;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (!joined) {
      debugPrint(
        '⚠️ Could not join socket room for $conversationId — '
        'running in HTTP-only mode',
      );
    }
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

    final result = await _repository.sendMessage(
      conversationId: state.conversationId,
      text: event.text,
    );

    _repository.stopTyping(state.conversationId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ChatStatus.error,
            error: failure.message,
            messages: state.messages.where((m) => m.id != tempId).toList(),
            sendingMessageId: null,
          ),
        );
      },
      (serverMessage) {
        if (serverMessage != null) {
          final withoutTemp =
              state.messages.where((m) => m.id != tempId).toList();
          emit(
            state.copyWith(
              status: ChatStatus.loaded,
              messages: [serverMessage, ...withoutTemp],
              sendingMessageId: null,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: ChatStatus.loaded,
              sendingMessageId: null,
            ),
          );
        }
      },
    );
  }

  Future<void> _onSendLocationMessage(
    SendLocationMessage event,
    Emitter<ChatState> emit,
  ) async {
    final tempId = 'temp_loc_${DateTime.now().millisecondsSinceEpoch}';

    final localMessage = ChatMessage.local(
      tempId: tempId,
      conversationId: state.conversationId,
      sender: MessageSender(id: _currentUserId ?? '', name: 'You'),
      location: LocationData(
        latitude: event.latitude,
        longitude: event.longitude,
      ),
    );

    emit(state.copyWith(messages: [localMessage, ...state.messages]));

    final result = await _repository.sendLocationMessage(
      conversationId: state.conversationId,
      latitude: event.latitude,
      longitude: event.longitude,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ChatStatus.error,
            error: failure.message,
            messages: state.messages.where((m) => m.id != tempId).toList(),
          ),
        );
      },
      (_) {},
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

        final sendResult = await _repository.sendMessage(
          conversationId: state.conversationId,
          imageUrl: imageUrl,
        );

        sendResult.fold(
          (failure) {
            emit(
              state.copyWith(
                status: ChatStatus.error,
                error: failure.message,
                messages: state.messages.where((m) => m.id != tempId).toList(),
              ),
            );
          },
          (serverMessage) {
            if (serverMessage != null) {
              final withoutTemp =
                  state.messages.where((m) => m.id != tempId).toList();
              emit(
                state.copyWith(
                  status: ChatStatus.loaded,
                  messages: [serverMessage, ...withoutTemp],
                ),
              );
            }
          },
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
        if (m.sender.id != message.sender.id) return true;
        if (m.messageType != message.messageType) return true;
        if (message.createdAt.difference(m.createdAt).inSeconds.abs() >= 30)
          return true;
        // For offer messages, match by offerId (text may differ due to server sanitization)
        if (m.messageType == MessageType.offer) {
          final match = m.offer?.offerId == message.offer?.offerId;
          if (match) {
            debugPrint('🟢 Dedup: removing temp offer ${m.id} (offerId=${m.offer?.offerId}), '
                'replacing with server message ${message.id}');
          }
          return !match;
        }
        // For location messages, match by coordinates instead of text
        if (m.messageType == MessageType.location) {
          return m.location?.latitude != message.location?.latitude ||
              m.location?.longitude != message.location?.longitude;
        }
        return m.text != message.text;
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

  Future<void> _onBlockUser(BlockUser event, Emitter<ChatState> emit) async {
    final result = await _repository.blockUser(event.userId);
    result.fold(
      (failure) => emit(state.copyWith(status: ChatStatus.error, error: failure.message)),
      (_) => emit(state.copyWith(isUserBlocked: true)),
    );
  }

  Future<void> _onUnblockUser(UnblockUser event, Emitter<ChatState> emit) async {
    final result = await _repository.unblockUser(event.userId);
    result.fold(
      (failure) => emit(state.copyWith(status: ChatStatus.error, error: failure.message)),
      (_) => emit(state.copyWith(isUserBlocked: false)),
    );
  }

  Future<void> _onCheckBlockStatus(
    CheckBlockStatus event,
    Emitter<ChatState> emit,
  ) async {
    final result = await _repository.getBlockedUsers();
    result.fold(
      (_) {}, // Silently ignore errors
      (blockedUsers) {
        final isBlocked = blockedUsers.any((u) => u.id == event.otherUserId);
        if (isBlocked) {
          emit(state.copyWith(isUserBlocked: true));
        }
      },
    );
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

  // ── Offer-in-chat handlers ──────────────────────────────────

  Future<void> _onSendOfferMessage(
    SendOfferMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Guard: don't send offer messages with empty/zero data
      if (event.offerId.isEmpty || event.amount <= 0) {
        debugPrint('⚠️ SendOfferMessage: invalid data (offerId="${event.offerId}", amount=${event.amount}) — skipping');
        return;
      }
      final offerData = OfferData(
        offerId: event.offerId,
        amount: event.amount,
        status: 'pending',
        roundNumber: 1,
        listingTitle: event.listingTitle,
        listingImage: event.listingImage,
        listingPrice: event.listingPrice,
        listingId: event.listingId,
      );

      final tempId = 'temp_offer_${DateTime.now().millisecondsSinceEpoch}';
      final localMessage = ChatMessage.local(
        tempId: tempId,
        conversationId: state.conversationId,
        sender: MessageSender(id: _currentUserId ?? '', name: 'You'),
        text: '💰 Offer: \$${event.amount.toStringAsFixed(2)}',
        offer: offerData,
      );

      emit(state.copyWith(messages: [localMessage, ...state.messages]));

      final sendResult = await _repository.sendMessage(
        conversationId: state.conversationId,
        text: '💰 Offer: \$${event.amount.toStringAsFixed(2)}',
        messageType: 'offer',
        metadata: offerData.toJson(),
      );

      sendResult.fold(
        (failure) {
          emit(
            state.copyWith(
              status: ChatStatus.error,
              error: failure.message,
              messages: state.messages.where((m) => m.id != tempId).toList(),
            ),
          );
        },
        (_) {},
      );
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: 'Failed to send offer: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRespondToOfferInChat(
    RespondToOfferInChat event,
    Emitter<ChatState> emit,
  ) async {
    if (_offerDataSource == null) return;

    try {
      debugPrint('🔵 RespondToOfferInChat: action=${event.action}, offerId=${event.offerId}');
      final updatedOffer = await _offerDataSource.respondToOffer(
        offerId: event.offerId,
        action: event.action,
        counterAmount: event.counterAmount,
      );

      debugPrint('🔵 API response: status=${updatedOffer.status}, '
          'counterAmount=${updatedOffer.counterAmount}, roundNumber=${updatedOffer.roundNumber}');

      // Update the offer bubble in the message list
      int matchCount = 0;
      final updatedMessages = state.messages.map((msg) {
        if (msg.messageType == MessageType.offer &&
            msg.offer?.offerId == event.offerId) {
          matchCount++;
          debugPrint('🔵 Matched offer bubble: id=${msg.id}, '
              'old status=${msg.offer?.status} → new status=${updatedOffer.status}');
          return msg.copyWithOffer(
            msg.offer!.copyWith(
              status: updatedOffer.status,
              counterAmount: updatedOffer.counterAmount,
              roundNumber: updatedOffer.roundNumber,
            ),
          );
        }
        return msg;
      }).toList();

      debugPrint('🔵 Updated $matchCount offer bubble(s), emitting new state');
      emit(state.copyWith(messages: updatedMessages));

      // Notify the listings feature when an offer is accepted (listing becomes sold)
      if (event.action == 'accept' && updatedOffer.listingId.isNotEmpty) {
        debugPrint('🔵 Offer accepted → notifying listing ${updatedOffer.listingId} as sold');
        ListingStatusNotifier.instance.notifyListingSold(updatedOffer.listingId);
      }
    } catch (e) {
      debugPrint('❌ RespondToOfferInChat error: $e');
      emit(state.copyWith(
        status: ChatStatus.error,
        error: 'Failed to respond to offer: ${e.toString()}',
      ));
    }
  }

  Future<void> _onOfferUpdatedReceived(
    OfferUpdatedReceived event,
    Emitter<ChatState> emit,
  ) async {
    final offerId = event.data['offerId']?.toString();
    if (offerId == null) return;

    final updatedOfferStatus = event.data['status']?.toString();

    debugPrint('🟡 OfferUpdatedReceived: offerId=$offerId, '
        'status=${event.data['status']}, counterAmount=${event.data['counterAmount']}, '
        'roundNumber=${event.data['roundNumber']}');

    // Log all offer IDs in current messages for matching
    for (final msg in state.messages) {
      if (msg.messageType == MessageType.offer) {
        debugPrint('🟡 Message offer id: "${msg.offer?.offerId}", match=${msg.offer?.offerId == offerId}');
      }
    }

    String? listingIdToNotify;
    if (updatedOfferStatus == 'accepted') {
      for (final msg in state.messages) {
        if (msg.messageType == MessageType.offer && msg.offer?.offerId == offerId) {
          listingIdToNotify = msg.offer?.listingId;
          break;
        }
      }
    }

    final updatedMessages = state.messages.map((msg) {
      if (msg.messageType == MessageType.offer && msg.offer?.offerId == offerId) {
        return msg.copyWithOffer(
          msg.offer!.copyWith(
            status: event.data['status']?.toString() ?? msg.offer!.status,
            counterAmount: event.data['counterAmount'] != null
                ? double.tryParse(event.data['counterAmount'].toString())
                : msg.offer!.counterAmount,
            roundNumber: event.data['roundNumber'] != null
                ? int.tryParse(event.data['roundNumber'].toString())
                : msg.offer!.roundNumber,
          ),
        );
      }
      return msg;
    }).toList();

    emit(state.copyWith(messages: updatedMessages));

    if (updatedOfferStatus == 'accepted' &&
        listingIdToNotify != null &&
        listingIdToNotify.isNotEmpty) {
      debugPrint('🔵 Offer accepted (socket update) → notifying listing $listingIdToNotify as sold');
      ListingStatusNotifier.instance.notifyListingSold(listingIdToNotify);
    }
  }
}

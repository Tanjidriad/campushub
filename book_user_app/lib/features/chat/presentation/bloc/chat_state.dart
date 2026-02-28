part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, loaded, error, sending }

class ChatState extends Equatable {
  final ChatStatus status;
  final String conversationId;
  final List<ChatMessage> messages;
  final List<String> typingUsers;
  final bool isOtherUserOnline;
  final String? otherUserId;
  final int currentPage;
  final bool hasMore;
  final String? error;
  final String? sendingMessageId;

  const ChatState({
    this.status = ChatStatus.initial,
    this.conversationId = '',
    this.messages = const [],
    this.typingUsers = const [],
    this.isOtherUserOnline = false,
    this.otherUserId,
    this.currentPage = 1,
    this.hasMore = true,
    this.error,
    this.sendingMessageId,
  });

  ChatState copyWith({
    ChatStatus? status,
    String? conversationId,
    List<ChatMessage>? messages,
    List<String>? typingUsers,
    bool? isOtherUserOnline,
    String? otherUserId,
    int? currentPage,
    bool? hasMore,
    String? error,
    String? sendingMessageId,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      typingUsers: typingUsers ?? this.typingUsers,
      isOtherUserOnline: isOtherUserOnline ?? this.isOtherUserOnline,
      otherUserId: otherUserId ?? this.otherUserId,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      sendingMessageId: sendingMessageId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    conversationId,
    messages,
    typingUsers,
    isOtherUserOnline,
    otherUserId,
    currentPage,
    hasMore,
    error,
    sendingMessageId,
  ];
}

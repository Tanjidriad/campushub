part of 'conversations_bloc.dart';

enum ConversationsStatus { initial, loading, loaded, error }

class ConversationsState extends Equatable {
  final ConversationsStatus status;
  final List<Conversation> conversations;
  final int currentPage;
  final bool hasMore;
  final String? error;

  const ConversationsState({
    this.status = ConversationsStatus.initial,
    this.conversations = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.error,
  });

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<Conversation>? conversations,
    int? currentPage,
    bool? hasMore,
    String? error,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    conversations,
    currentPage,
    hasMore,
    error,
  ];

  /// Get total unread message count across all conversations for a user
  int getTotalUnreadFor(String userId) {
    int total = 0;
    for (final conv in conversations) {
      total += conv.getUnreadFor(userId);
    }
    return total;
  }
}

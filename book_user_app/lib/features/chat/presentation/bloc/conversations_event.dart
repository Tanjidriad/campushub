part of 'conversations_bloc.dart';

abstract class ConversationsEvent extends Equatable {
  const ConversationsEvent();

  @override
  List<Object?> get props => [];
}

/// Load conversations list
class LoadConversations extends ConversationsEvent {
  final int page;
  final bool refresh;

  const LoadConversations({this.page = 1, this.refresh = false});

  @override
  List<Object?> get props => [page, refresh];
}

/// Refresh conversations (pull to refresh)
class RefreshConversations extends ConversationsEvent {
  const RefreshConversations();
}

/// Delete a conversation
class DeleteConversation extends ConversationsEvent {
  final String conversationId;

  const DeleteConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Start listening to socket events
class StartConversationsListening extends ConversationsEvent {
  const StartConversationsListening();
}

/// Stop listening to socket events
class StopConversationsListening extends ConversationsEvent {
  const StopConversationsListening();
}

/// Internal event when a message is received via socket
class ConversationUpdated extends ConversationsEvent {
  final Map<String, dynamic> data;

  const ConversationUpdated(this.data);

  @override
  List<Object?> get props => [data];
}

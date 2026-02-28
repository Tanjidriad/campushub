part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Load messages for a conversation
class LoadMessages extends ChatEvent {
  final String conversationId;
  final int page;

  const LoadMessages({required this.conversationId, this.page = 1});

  @override
  List<Object?> get props => [conversationId, page];
}

/// Load more messages (pagination)
class LoadMoreMessages extends ChatEvent {
  const LoadMoreMessages();
}

/// Send a text message
class SendTextMessage extends ChatEvent {
  final String text;

  const SendTextMessage(this.text);

  @override
  List<Object?> get props => [text];
}

/// Send a location message
class SendLocationMessage extends ChatEvent {
  final double latitude;
  final double longitude;

  const SendLocationMessage({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Send an image message
class SendImageMessage extends ChatEvent {
  final String imagePath;

  const SendImageMessage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

/// New message received from socket
class MessageReceived extends ChatEvent {
  final Map<String, dynamic> data;

  const MessageReceived(this.data);

  @override
  List<Object?> get props => [data];
}

/// Typing indicator update
class TypingUpdate extends ChatEvent {
  final List<String> typingUsers;

  const TypingUpdate(this.typingUsers);

  @override
  List<Object?> get props => [typingUsers];
}

/// Start typing
class StartTyping extends ChatEvent {
  const StartTyping();
}

/// Stop typing
class StopTyping extends ChatEvent {
  const StopTyping();
}

/// User online status change
class UserOnlineStatusChanged extends ChatEvent {
  final String userId;
  final bool isOnline;

  const UserOnlineStatusChanged({required this.userId, required this.isOnline});

  @override
  List<Object?> get props => [userId, isOnline];
}

/// Mark messages as read
class MarkAsRead extends ChatEvent {
  const MarkAsRead();
}

/// Leave conversation (cleanup)
class LeaveConversation extends ChatEvent {
  const LeaveConversation();
}

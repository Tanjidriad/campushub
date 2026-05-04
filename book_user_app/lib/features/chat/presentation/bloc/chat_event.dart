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

/// Block user
class BlockUser extends ChatEvent {
  final String userId;

  const BlockUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Unblock user
class UnblockUser extends ChatEvent {
  final String userId;

  const UnblockUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Check if other user is blocked
class CheckBlockStatus extends ChatEvent {
  final String otherUserId;

  const CheckBlockStatus(this.otherUserId);

  @override
  List<Object?> get props => [otherUserId];
}

/// Send an offer message (renders chat bubble for an already-created offer)
class SendOfferMessage extends ChatEvent {
  final String offerId;
  final String listingId;
  final double amount;
  final String listingTitle;
  final String? listingImage;
  final double listingPrice;

  const SendOfferMessage({
    required this.offerId,
    required this.listingId,
    required this.amount,
    required this.listingTitle,
    this.listingImage,
    required this.listingPrice,
  });

  @override
  List<Object?> get props => [offerId, listingId, amount, listingTitle, listingImage, listingPrice];
}

/// Respond to an offer inline from the chat bubble
class RespondToOfferInChat extends ChatEvent {
  final String offerId;
  final String action; // 'accept', 'decline', 'counter'
  final double? counterAmount;

  const RespondToOfferInChat({
    required this.offerId,
    required this.action,
    this.counterAmount,
  });

  @override
  List<Object?> get props => [offerId, action, counterAmount];
}

/// Received an offer status update from the socket
class OfferUpdatedReceived extends ChatEvent {
  final Map<String, dynamic> data;

  const OfferUpdatedReceived(this.data);

  @override
  List<Object?> get props => [data];
}

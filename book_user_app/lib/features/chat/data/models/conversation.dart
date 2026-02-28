import 'package:equatable/equatable.dart';

class ConversationParticipant extends Equatable {
  final String id;
  final String name;
  final String? avatar;

  const ConversationParticipant({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    return ConversationParticipant(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'avatar': avatar};

  @override
  List<Object?> get props => [id, name, avatar];
}

class ConversationListing extends Equatable {
  final String id;
  final String title;
  final double? price;
  final List<String> images; // URLs only
  final String? sellerId;

  const ConversationListing({
    required this.id,
    required this.title,
    this.price,
    this.images = const [],
    this.sellerId,
  });

  factory ConversationListing.fromJson(Map<String, dynamic> json) {
    // Handle images - can be list of strings or list of objects with 'url'
    List<String> imageUrls = [];
    final imagesData = json['images'];
    if (imagesData is List) {
      for (final img in imagesData) {
        if (img is String) {
          imageUrls.add(img);
        } else if (img is Map<String, dynamic>) {
          final url = img['url']?.toString();
          if (url != null) imageUrls.add(url);
        }
      }
    }

    return ConversationListing(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble(),
      images: imageUrls,
      sellerId: json['seller']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'price': price,
    'images': images,
    'seller': sellerId,
  };

  String? get firstImage => images.isNotEmpty ? images.first : null;

  @override
  List<Object?> get props => [id, title, price, images, sellerId];
}

class LastMessage extends Equatable {
  final String? text;
  final String? sender;
  final DateTime? timestamp;
  final bool hasImage;

  const LastMessage({
    this.text,
    this.sender,
    this.timestamp,
    this.hasImage = false,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      text: json['text']?.toString(),
      sender: json['sender']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
      hasImage: json['hasImage'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'sender': sender,
    'timestamp': timestamp?.toIso8601String(),
    'hasImage': hasImage,
  };

  @override
  List<Object?> get props => [text, sender, timestamp, hasImage];
}

class Conversation extends Equatable {
  final String id;
  final List<ConversationParticipant> participants;
  final ConversationListing listing;
  final LastMessage? lastMessage;
  final Map<String, int>? unreadCount;
  final int unreadCountRaw; // For API that returns single number
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.participants,
    required this.listing,
    this.lastMessage,
    this.unreadCount,
    this.unreadCountRaw = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Parse participants
    final participantsList = <ConversationParticipant>[];
    final participantsData = json['participants'];
    if (participantsData is List) {
      for (final p in participantsData) {
        if (p is Map<String, dynamic>) {
          participantsList.add(ConversationParticipant.fromJson(p));
        }
      }
    }

    // Parse listing
    final listingData = json['listing'];
    final listing = listingData is Map<String, dynamic>
        ? ConversationListing.fromJson(listingData)
        : ConversationListing(id: '', title: 'Unknown');

    // Parse lastMessage
    final lastMsgData = json['lastMessage'];
    final lastMessage = lastMsgData is Map<String, dynamic>
        ? LastMessage.fromJson(lastMsgData)
        : null;

    // Parse unreadCount - handle both Map and number formats
    Map<String, int>? unreadCount;
    int unreadCountRaw = 0;
    final unreadData = json['unreadCount'];
    if (unreadData is Map<String, dynamic>) {
      unreadCount = unreadData.map((k, v) => MapEntry(k, (v as num).toInt()));
    } else if (unreadData is num) {
      unreadCountRaw = unreadData.toInt();
    }

    return Conversation(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      participants: participantsList,
      listing: listing,
      lastMessage: lastMessage,
      unreadCount: unreadCount,
      unreadCountRaw: unreadCountRaw,
      isActive: json['isActive'] != false,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'participants': participants.map((p) => p.toJson()).toList(),
    'listing': listing.toJson(),
    'lastMessage': lastMessage?.toJson(),
    'unreadCount': unreadCount ?? unreadCountRaw,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Get the other participant (not the current user)
  ConversationParticipant getOtherParticipant(String currentUserId) {
    return participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => participants.isNotEmpty
          ? participants.first
          : const ConversationParticipant(id: '', name: 'Unknown'),
    );
  }

  /// Get unread count for a specific user
  int getUnreadFor(String userId) {
    // If we have a map, use it; otherwise use raw count
    if (unreadCount != null && unreadCount!.containsKey(userId)) {
      return unreadCount![userId] ?? 0;
    }
    return unreadCountRaw;
  }

  @override
  List<Object?> get props => [
    id,
    participants,
    listing,
    lastMessage,
    unreadCount,
    unreadCountRaw,
    isActive,
    createdAt,
    updatedAt,
  ];
}

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

// ==================== ENUMS ====================
enum MessageType { text, image, location, system, offer }

MessageType _parseMessageType(dynamic value) {
  if (value == null) return MessageType.text;
  final str = value.toString().toLowerCase();
  switch (str) {
    case 'image':
      return MessageType.image;
    case 'location':
      return MessageType.location;
    case 'system':
      return MessageType.system;
    case 'offer':
      return MessageType.offer;
    default:
      return MessageType.text;
  }
}

String _messageTypeToString(MessageType type) {
  switch (type) {
    case MessageType.image:
      return 'image';
    case MessageType.location:
      return 'location';
    case MessageType.system:
      return 'system';
    case MessageType.offer:
      return 'offer';
    default:
      return 'text';
  }
}

class ImageData extends Equatable {
  final String? url;
  final String? publicId;

  const ImageData({this.url, this.publicId});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      url: json['url']?.toString(),
      publicId: json['publicId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'url': url, 'publicId': publicId};

  @override
  List<Object?> get props => [url, publicId];
}

class LocationData extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
  };

  @override
  List<Object?> get props => [latitude, longitude, address];
}

class OfferData extends Equatable {
  final String offerId;
  final double amount;
  final String status;
  final double? counterAmount;
  final int roundNumber;
  final String? listingTitle;
  final String? listingImage;
  final double? listingPrice;
  final String? listingId;

  const OfferData({
    required this.offerId,
    required this.amount,
    required this.status,
    this.counterAmount,
    this.roundNumber = 1,
    this.listingTitle,
    this.listingImage,
    this.listingPrice,
    this.listingId,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
  bool get isCountered => status == 'countered';
  bool get isExpired => status == 'expired';
  bool get canCounter => roundNumber < 3;

  factory OfferData.fromJson(Map<String, dynamic> json) {
    final parsedAmount = double.tryParse(json['amount']?.toString() ?? '') ?? 0.0;
    debugPrint('🟠 OfferData.fromJson: raw amount=${json['amount']} (${json['amount']?.runtimeType}), '
        'parsed=$parsedAmount, offerId=${json['offerId']}');
    return OfferData(
      offerId: json['offerId']?.toString() ?? '',
      amount: parsedAmount,
      status: json['status']?.toString() ?? 'pending',
      counterAmount: double.tryParse(json['counterAmount']?.toString() ?? ''),
      roundNumber: json['roundNumber'] ?? 1,
      listingTitle: json['listingTitle']?.toString(),
      listingImage: json['listingImage']?.toString(),
      listingPrice: double.tryParse(json['listingPrice']?.toString() ?? ''),
      listingId: json['listingId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'offerId': offerId,
    'amount': amount,
    'status': status,
    'counterAmount': counterAmount,
    'roundNumber': roundNumber,
    'listingTitle': listingTitle,
    'listingImage': listingImage,
    'listingPrice': listingPrice,
    if (listingId != null) 'listingId': listingId,
  };

  OfferData copyWith({String? status, double? counterAmount, int? roundNumber}) {
    return OfferData(
      offerId: offerId,
      amount: amount,
      status: status ?? this.status,
      counterAmount: counterAmount ?? this.counterAmount,
      roundNumber: roundNumber ?? this.roundNumber,
      listingTitle: listingTitle,
      listingImage: listingImage,
      listingPrice: listingPrice,
      listingId: listingId,
    );
  }

  @override
  List<Object?> get props => [
        offerId,
        amount,
        status,
        counterAmount,
        roundNumber,
        listingTitle,
        listingImage,
        listingPrice,
        listingId,
      ];
}

class MessageSender extends Equatable {
  final String id;
  final String name;
  final String? avatar;

  const MessageSender({required this.id, required this.name, this.avatar});

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'avatar': avatar};

  @override
  List<Object?> get props => [id, name, avatar];
}

class ChatMessage extends Equatable {
  final String id;
  final String conversation;
  final MessageSender sender;
  final String? text;
  final ImageData? image;
  final MessageType messageType;
  final LocationData? location;
  final OfferData? offer;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final bool isDeleted;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatMessage({
    required this.id,
    required this.conversation,
    required this.sender,
    this.text,
    this.image,
    this.messageType = MessageType.text,
    this.location,
    this.offer,
    this.deliveredAt,
    this.readAt,
    this.isDeleted = false,
    this.isEdited = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Parse sender - can be string ID or object
    MessageSender sender;
    final senderData = json['sender'];
    if (senderData is Map<String, dynamic>) {
      sender = MessageSender.fromJson(senderData);
    } else {
      sender = MessageSender(id: senderData?.toString() ?? '', name: 'Unknown');
    }

    // Parse image
    ImageData? image;
    final imageData = json['image'];
    if (imageData is Map<String, dynamic>) {
      image = ImageData.fromJson(imageData);
    }

    // Parse location
    LocationData? location;
    final locationData = json['location'];
    if (locationData is Map<String, dynamic>) {
      location = LocationData.fromJson(locationData);
    }

    // Parse offer — from explicit 'offer' field or from 'metadata' (server-persisted)
    OfferData? offer;
    final offerData = json['offer'];
    if (offerData is Map<String, dynamic>) {
      offer = OfferData.fromJson(offerData);
    } else if (_parseMessageType(json['messageType']) == MessageType.offer) {
      // Server stores offer fields in 'metadata'
      final meta = json['metadata'];
      if (meta is Map<String, dynamic>) {
        offer = OfferData.fromJson(meta);
      }
    }

    return ChatMessage(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      conversation: json['conversation']?.toString() ?? '',
      sender: sender,
      text: json['text']?.toString(),
      image: image,
      messageType: _parseMessageType(json['messageType']),
      location: location,
      offer: offer,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'].toString())
          : null,
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'].toString())
          : null,
      isDeleted: json['isDeleted'] == true,
      isEdited: json['isEdited'] == true,
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
    'conversation': conversation,
    'sender': sender.toJson(),
    'text': text,
    'image': image?.toJson(),
    'messageType': _messageTypeToString(messageType),
    'location': location?.toJson(),
    'offer': offer?.toJson(),
    'deliveredAt': deliveredAt?.toIso8601String(),
    'readAt': readAt?.toIso8601String(),
    'isDeleted': isDeleted,
    'isEdited': isEdited,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Creates a local message for optimistic UI updates
  factory ChatMessage.local({
    required String tempId,
    required String conversationId,
    required MessageSender sender,
    String? text,
    ImageData? image,
    LocationData? location,
    OfferData? offer,
  }) {
    final now = DateTime.now();
    return ChatMessage(
      id: tempId,
      conversation: conversationId,
      sender: sender,
      text: text,
      image: image,
      location: location,
      offer: offer,
      messageType: offer != null
          ? MessageType.offer
          : location != null
          ? MessageType.location
          : image != null
          ? MessageType.image
          : MessageType.text,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Returns a copy with updated offer data
  ChatMessage copyWithOffer(OfferData newOffer) {
    return ChatMessage(
      id: id,
      conversation: conversation,
      sender: sender,
      text: text,
      image: image,
      messageType: messageType,
      location: location,
      offer: newOffer,
      deliveredAt: deliveredAt,
      readAt: readAt,
      isDeleted: isDeleted,
      isEdited: isEdited,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  bool get isOutgoing => false; // Determined by comparing with current user ID

  @override
  List<Object?> get props => [
    id,
    conversation,
    sender,
    text,
    image,
    messageType,
    location,
    offer,
    deliveredAt,
    readAt,
    isDeleted,
    isEdited,
    createdAt,
    updatedAt,
  ];
}

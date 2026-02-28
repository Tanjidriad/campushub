import 'package:equatable/equatable.dart';

enum MessageType { text, image, location, system }

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

    return ChatMessage(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      conversation: json['conversation']?.toString() ?? '',
      sender: sender,
      text: json['text']?.toString(),
      image: image,
      messageType: _parseMessageType(json['messageType']),
      location: location,
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
  }) {
    final now = DateTime.now();
    return ChatMessage(
      id: tempId,
      conversation: conversationId,
      sender: sender,
      text: text,
      image: image,
      location: location,
      messageType: location != null
          ? MessageType.location
          : image != null
          ? MessageType.image
          : MessageType.text,
      createdAt: now,
      updatedAt: now,
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
    deliveredAt,
    readAt,
    isDeleted,
    isEdited,
    createdAt,
    updatedAt,
  ];
}

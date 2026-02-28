import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.username,
    super.avatar,
    super.phone,
    super.bio,
    super.location,
    super.role,
    super.isVerified,
    super.isOnline,
    super.lastActive,
    super.createdAt,
    super.activeListings,
    super.totalSold,
    super.totalListings,
    super.averageRating,
    super.totalReviews,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      username: json['username'],
      avatar: json['avatar'],
      phone: json['phone'],
      bio: json['bio'],
      location: json['location'],
      role: json['role'] ?? 'student',
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      lastActive: json['lastActive'] != null
          ? DateTime.tryParse(json['lastActive'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      activeListings: json['activeListings'] ?? 0,
      totalSold: json['totalSold'] ?? 0,
      totalListings: json['totalListings'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'avatar': avatar,
      'phone': phone,
      'bio': bio,
      'location': location,
      'role': role,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'lastActive': lastActive?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'activeListings': activeListings,
      'totalSold': totalSold,
      'totalListings': totalListings,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }
}

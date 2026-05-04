import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? username;
  final String? avatar;
  final String? phone;
  final String? bio;
  final String? location;
  final String? educationLevel;
  final String? stream;
  final String? department;
  final String? classOrSemester;
  final String role;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastActive;
  final DateTime? createdAt;

  final int activeListings;
  final int totalSold;
  final int totalListings;
  final double averageRating;
  final int totalReviews;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.username,
    this.avatar,
    this.phone,
    this.bio,
    this.location,
    this.educationLevel,
    this.stream,
    this.department,
    this.classOrSemester,
    this.role = 'student',
    this.isVerified = false,
    this.isOnline = false,
    this.lastActive,
    this.createdAt,
    this.activeListings = 0,
    this.totalSold = 0,
    this.totalListings = 0,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    username,
    avatar,
    phone,
    bio,
    location,
    educationLevel,
    stream,
    department,
    classOrSemester,
    role,
    isVerified,
    isOnline,
    lastActive,
    createdAt,
    activeListings,
    totalSold,
    totalListings,
    averageRating,
    totalReviews,
  ];
}

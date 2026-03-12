import '../../domain/entities/users_response.dart';
import 'user_model.dart';

class UserStatsModel extends UserStats {
  const UserStatsModel({
    required super.total,
    required super.active,
    required super.banned,
    required super.admins,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      total: json['total'] as int? ?? 0,
      active: json['active'] as int? ?? 0,
      banned: json['banned'] as int? ?? 0,
      admins: json['admins'] as int? ?? 0,
    );
  }
}

class UsersResponseModel extends UsersResponse {
  const UsersResponseModel({required super.users, required super.stats});

  factory UsersResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] ?? [];
    final users = data.map((e) => AdminUserModel.fromJson(e)).toList();

    final statsJson = json['statistics'] as Map<String, dynamic>? ?? {};
    final stats = UserStatsModel.fromJson(statsJson);

    return UsersResponseModel(users: users, stats: stats);
  }
}

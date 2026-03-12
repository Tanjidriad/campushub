import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../entities/users_response.dart';
import '../repositories/user_repository.dart';

class GetUsersUseCase implements UseCase<UsersResponse, GetUsersParams> {
  final UserRepository repository;

  GetUsersUseCase(this.repository);

  @override
  Future<Either<Failure, UsersResponse>> call(GetUsersParams params) async {
    return await repository.getUsers(
      limit: params.limit,
      search: params.search,
      role: params.role,
      status: params.status,
    );
  }
}

class GetUsersParams extends Equatable {
  final int? limit;
  final String? search;
  final String? role;
  final String? status;

  const GetUsersParams({this.limit, this.search, this.role, this.status});

  @override
  List<Object?> get props => [limit, search, role, status];
}

class GetUserUseCase implements UseCase<AdminUserEntity, String> {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  @override
  Future<Either<Failure, AdminUserEntity>> call(String userId) async {
    return await repository.getUser(userId);
  }
}

class ToggleBanUseCase implements UseCase<Unit, String> {
  final UserRepository repository;

  ToggleBanUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String userId) async {
    return await repository.toggleBan(userId);
  }
}

class ChangeRoleParams extends Equatable {
  final String userId;
  final String newRole;

  const ChangeRoleParams({required this.userId, required this.newRole});

  @override
  List<Object> get props => [userId, newRole];
}

class ChangeRoleUseCase implements UseCase<Unit, ChangeRoleParams> {
  final UserRepository repository;

  ChangeRoleUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ChangeRoleParams params) async {
    return await repository.changeRole(params.userId, params.newRole);
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/admin_user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<AdminUser, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AdminUser>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class CheckAuthUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;
  CheckAuthUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.checkAuth();
  }
}

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}

class GetSavedUserUseCase implements UseCase<AdminUser?, NoParams> {
  final AuthRepository repository;
  GetSavedUserUseCase(this.repository);

  @override
  Future<Either<Failure, AdminUser?>> call(NoParams params) async {
    return await repository.getSavedUser();
  }
}

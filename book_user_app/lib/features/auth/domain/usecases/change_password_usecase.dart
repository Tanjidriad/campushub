import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/usecases/usecase.dart';
import 'package:book_user_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class ChangePasswordUseCase implements UseCase<void, ChangePasswordParams> {
  final AuthRepository authRepository;

  ChangePasswordUseCase(this.authRepository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    return await authRepository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}

class ChangePasswordParams extends Equatable {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

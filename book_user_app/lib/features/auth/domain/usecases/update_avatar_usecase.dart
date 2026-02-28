import 'dart:io';

import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/usecases/usecase.dart';
import 'package:book_user_app/features/auth/domain/entities/user.dart';
import 'package:book_user_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateAvatarUseCase implements UseCase<User, File> {
  final AuthRepository authRepository;

  UpdateAvatarUseCase(this.authRepository);

  @override
  Future<Either<Failure, User>> call(File imageFile) async {
    return await authRepository.updateAvatar(imageFile);
  }
}

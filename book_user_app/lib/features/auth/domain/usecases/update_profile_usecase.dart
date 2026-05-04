import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/usecases/usecase.dart';
import 'package:book_user_app/features/auth/domain/entities/user.dart';
import 'package:book_user_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UpdateProfileUseCase implements UseCase<User, UpdateProfileParams> {
  final AuthRepository authRepository;

  UpdateProfileUseCase(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await authRepository.updateProfile(
      name: params.name,
      username: params.username,
      phone: params.phone,
      bio: params.bio,
      location: params.location,
      educationLevel: params.educationLevel,
      stream: params.stream,
      department: params.department,
      classOrSemester: params.classOrSemester,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? name;
  final String? username;
  final String? phone;
  final String? bio;
  final String? location;
  final String? educationLevel;
  final String? stream;
  final String? department;
  final String? classOrSemester;

  const UpdateProfileParams({
    this.name,
    this.username,
    this.phone,
    this.bio,
    this.location,
    this.educationLevel,
    this.stream,
    this.department,
    this.classOrSemester,
  });

  @override
  List<Object?> get props => [
        name,
        username,
        phone,
        bio,
        location,
        educationLevel,
        stream,
        department,
        classOrSemester,
      ];
}

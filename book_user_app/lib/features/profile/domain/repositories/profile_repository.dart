import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/features/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  Future<Either<Failure, User>> getUserProfile(String id);
}

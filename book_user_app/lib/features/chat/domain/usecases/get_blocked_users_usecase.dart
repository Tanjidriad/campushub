import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/usecases/usecase.dart';
import 'package:book_user_app/features/auth/domain/entities/user.dart';
import 'package:book_user_app/features/chat/data/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class GetBlockedUsersUseCase implements UseCase<List<User>, NoParams> {
  final ChatRepository repository;

  GetBlockedUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(NoParams params) async {
    return await repository.getBlockedUsers();
  }
}

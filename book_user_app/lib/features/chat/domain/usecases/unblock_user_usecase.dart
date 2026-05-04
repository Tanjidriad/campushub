import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/usecases/usecase.dart';
import 'package:book_user_app/features/chat/data/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class UnblockUserUseCase implements UseCase<void, UnblockUserParams> {
  final ChatRepository repository;

  UnblockUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UnblockUserParams params) async {
    return await repository.unblockUser(params.userId);
  }
}

class UnblockUserParams {
  final String userId;

  UnblockUserParams({required this.userId});
}

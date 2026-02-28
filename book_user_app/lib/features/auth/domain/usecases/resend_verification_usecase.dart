import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ResendVerificationUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  ResendVerificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.resendVerification();
  }
}

import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base UseCase interface
/// All use cases should implement this interface
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Used when no parameters are needed
class NoParams {
  const NoParams();
}

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Server failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Unauthorized failures
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

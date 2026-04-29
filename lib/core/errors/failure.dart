abstract class Failure {
  final String message;
  final Object? cause;

  const Failure(this.message, {this.cause});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.cause});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.cause});
}

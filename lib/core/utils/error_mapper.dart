import '../errors/failure.dart';

class ErrorMapper {
  static Failure toFailure(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('network') ||
        text.contains('socketexception') ||
        text.contains('cannot reach api')) {
      return NetworkFailure('Network unavailable. Please try again.');
    }
    if (text.contains('auth') || text.contains('password') || text.contains('email')) {
      return AuthFailure('Authentication failed. Verify your credentials.');
    }
    if (text.contains('validation') || text.contains('invalid')) {
      return ValidationFailure('Some input fields are invalid.');
    }
    return ServerFailure('Something went wrong. Please try again.');
  }
}

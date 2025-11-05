class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class UserDisabledException extends AuthException {
  UserDisabledException() : super('Your account has been disabled by an administrator.');
}

class UserNotFoundException extends AuthException {
  UserNotFoundException() : super('User data not found in database.');
}

class WeakPasswordException extends AuthException {
  WeakPasswordException() : super('Password should be at least 6 characters.');
}

class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException() : super('An account already exists with this email.');
}

class InvalidEmailException extends AuthException {
  InvalidEmailException() : super('The email address is invalid.');
}

class WrongPasswordException extends AuthException {
  WrongPasswordException() : super('Incorrect password.');
}

class NetworkException extends AuthException {
  NetworkException() : super('Network error. Please check your connection.');
}
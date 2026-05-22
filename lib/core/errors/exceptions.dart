// Custom Exceptions for Domain Layer

class NetworkException implements Exception {
  final String message;
  final String? code;

  NetworkException(this.message, {this.code});

  @override
  String toString() => 'NetworkException: $message';
}

class AIServiceException implements Exception {
  final String message;
  final String? code;
  final int? retryAfterSeconds;

  AIServiceException(
    this.message, {
    this.code,
    this.retryAfterSeconds,
  });

  @override
  String toString() => 'AIServiceException: $message';
}

class DomainAuthException implements Exception {
  final String message;
  final String? code;

  DomainAuthException(this.message, {this.code});

  @override
  String toString() => 'DomainAuthException: $message';
}

class ValidationException implements Exception {
  final Map<String, String> fieldErrors;

  ValidationException(this.fieldErrors);

  @override
  String toString() => 'ValidationException: ${fieldErrors.toString()}';
}

class DataException implements Exception {
  final String message;
  final String? code;

  DataException(this.message, {this.code});

  @override
  String toString() => 'DataException: $message';
}

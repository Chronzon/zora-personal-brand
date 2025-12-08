/// Abstract Failure Classes
abstract class Failure {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory NetworkFailure.noConnection() {
    return const NetworkFailure(
      message: 'No internet connection. Please check your network.',
      code: 'NETWORK_NO_CONNECTION',
    );
  }

  factory NetworkFailure.timeout() {
    return const NetworkFailure(
      message: 'Request timed out. Please try again.',
      code: 'NETWORK_TIMEOUT',
    );
  }

  factory NetworkFailure.poorConnection() {
    return const NetworkFailure(
      message: 'Poor connection detected. Consider switching to Wi-Fi.',
      code: 'NETWORK_POOR_CONNECTION',
    );
  }
}

/// AI Service failures
class AIServiceFailure extends Failure {
  final int? retryAfterSeconds;

  const AIServiceFailure({
    required super.message,
    super.code,
    super.originalError,
    this.retryAfterSeconds,
  });

  factory AIServiceFailure.rateLimited({int? retryAfter}) {
    return AIServiceFailure(
      message: retryAfter != null
          ? 'AI is busy. Try again in $retryAfter seconds.'
          : 'Too many requests. Please wait a moment.',
      code: 'AI_RATE_LIMITED',
      retryAfterSeconds: retryAfter,
    );
  }

  factory AIServiceFailure.serviceDown() {
    return const AIServiceFailure(
      message: 'AI service is temporarily unavailable. Please try again later.',
      code: 'AI_SERVICE_DOWN',
    );
  }

  factory AIServiceFailure.invalidResponse() {
    return const AIServiceFailure(
      message: 'AI returned unexpected data. Please try again.',
      code: 'AI_INVALID_RESPONSE',
    );
  }

  factory AIServiceFailure.contentFiltered() {
    return const AIServiceFailure(
      message: 'Content was filtered by AI safety systems. Please rephrase.',
      code: 'AI_CONTENT_FILTERED',
    );
  }
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AuthFailure.sessionExpired() {
    return const AuthFailure(
      message: 'Your session has expired. Please sign in again.',
      code: 'AUTH_SESSION_EXPIRED',
    );
  }

  factory AuthFailure.invalidCredentials() {
    return const AuthFailure(
      message: 'Invalid email or password.',
      code: 'AUTH_INVALID_CREDENTIALS',
    );
  }

  factory AuthFailure.emailAlreadyExists() {
    return const AuthFailure(
      message: 'This email is already registered.',
      code: 'AUTH_EMAIL_EXISTS',
    );
  }

  factory AuthFailure.unauthorized() {
    return const AuthFailure(
      message: 'You do not have permission to perform this action.',
      code: 'AUTH_UNAUTHORIZED',
    );
  }
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    required this.fieldErrors,
  });

  factory ValidationFailure.fromFields(Map<String, String> errors) {
    return ValidationFailure(
      message: 'Please fix the errors in the form.',
      code: 'VALIDATION_ERROR',
      fieldErrors: errors,
    );
  }
}

/// Data failures
class DataFailure extends Failure {
  const DataFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory DataFailure.notFound() {
    return const DataFailure(
      message: 'Data not found.',
      code: 'DATA_NOT_FOUND',
    );
  }

  factory DataFailure.saveFailed() {
    return const DataFailure(
      message: 'Failed to save data. Please try again.',
      code: 'DATA_SAVE_FAILED',
    );
  }

  factory DataFailure.conflictDetected() {
    return const DataFailure(
      message: 'Data was modified in another session.',
      code: 'DATA_CONFLICT',
    );
  }
}

/// Server failures
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  factory ServerFailure.internal() {
    return const ServerFailure(
      message: 'Server error occurred. Please try again later.',
      code: 'SERVER_INTERNAL_ERROR',
      statusCode: 500,
    );
  }

  factory ServerFailure.maintenance() {
    return const ServerFailure(
      message: 'Server is under maintenance. Please try again later.',
      code: 'SERVER_MAINTENANCE',
      statusCode: 503,
    );
  }
}

/// Unknown/Generic failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  factory UnknownFailure.fromException(dynamic error) {
    return UnknownFailure(
      message: 'An unexpected error occurred: ${error.toString()}',
      code: 'UNKNOWN_ERROR',
      originalError: error,
    );
  }
}
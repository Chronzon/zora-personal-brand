import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'failures.dart';
import 'exceptions.dart';

/// Centralized Error Handler
/// Converts exceptions to user-friendly failures

class ErrorHandler {
  /// Convert exception to Failure
  static Failure handleException(dynamic error, {StackTrace? stackTrace}) {
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }

    // Network errors
    if (error is SocketException) {
      return NetworkFailure.noConnection();
    }

    if (error is NetworkException) {
      if (error.code == 'TIMEOUT') {
        return NetworkFailure.timeout();
      }
      return NetworkFailure(message: error.message, code: error.code);
    }

    // AI Service errors
    if (error is AIServiceException) {
      if (error.code == 'RATE_LIMITED') {
        return AIServiceFailure.rateLimited(
          retryAfter: error.retryAfterSeconds,
        );
      }
      if (error.code == 'SERVICE_DOWN') {
        return AIServiceFailure.serviceDown();
      }
      if (error.code == 'INVALID_RESPONSE') {
        return AIServiceFailure.invalidResponse();
      }
      return AIServiceFailure(message: error.message, code: error.code);
    }

    // Auth errors
    if (error is DomainAuthException) {
      if (error.code == 'SESSION_EXPIRED') {
        return AuthFailure.sessionExpired();
      }
      if (error.code == 'INVALID_CREDENTIALS') {
        return AuthFailure.invalidCredentials();
      }
      if (error.code == 'EMAIL_EXISTS') {
        return AuthFailure.emailAlreadyExists();
      }
      return AuthFailure(message: error.message, code: error.code);
    }

    // Supabase-specific errors
    if (error is AuthApiException) {
      return _handleSupabaseAuthError(error);
    }

    if (error is PostgrestException) {
      return _handleSupabaseDataError(error);
    }

    // Validation errors
    if (error is ValidationException) {
      return ValidationFailure.fromFields(error.fieldErrors);
    }

    // Data errors
    if (error is DataException) {
      if (error.code == 'NOT_FOUND') {
        return DataFailure.notFound();
      }
      if (error.code == 'CONFLICT') {
        return DataFailure.conflictDetected();
      }
      return DataFailure(message: error.message, code: error.code);
    }

    // Unknown error
    return UnknownFailure.fromException(error);
  }

  /// Handle Supabase Auth errors
  static Failure _handleSupabaseAuthError(AuthApiException error) {
    if (error.statusCode == 400) {
      if (error.message.contains('Invalid login credentials')) {
        return AuthFailure.invalidCredentials();
      }
      if (error.message.contains('already registered')) {
        return AuthFailure.emailAlreadyExists();
      }
    }

    if (error.statusCode == 401) {
      return AuthFailure.sessionExpired();
    }

    if (error.statusCode == 403) {
      return AuthFailure.unauthorized();
    }

    return AuthFailure(
      message: error.message,
      code: error.statusCode,
      originalError: error,
    );
  }

  /// Handle Supabase Data errors
  static Failure _handleSupabaseDataError(PostgrestException error) {
    if (error.code == 'PGRST116') {
      // No rows returned
      return DataFailure.notFound();
    }

    if (error.code?.startsWith('23') ?? false) {
      // Database constraint violation
      return DataFailure(
        message: 'Data integrity error. Please check your input.',
        code: error.code,
        originalError: error,
      );
    }

    return DataFailure(
      message: error.message,
      code: error.code,
      originalError: error,
    );
  }

  /// Show error to user via SnackBar
  static void showErrorSnackBar(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
  }) {
    final snackBar = SnackBar(
      content: Text(failure.message),
      backgroundColor: Colors.red[700],
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(failure.message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
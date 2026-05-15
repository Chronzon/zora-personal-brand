import 'package:personal_branding_app/core/network/api_client.dart';
import 'package:personal_branding_app/core/errors/exceptions.dart';
import 'package:personal_branding_app/features/auth/domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  ApiUser? get currentUser => _apiClient.currentUser;

  @override
  Future<bool> restoreSession() {
    return _apiClient.restoreSession();
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _apiClient.post('/login',
          body: {
            'email': email,
            'password': password,
          },
          requiresAuth: false);
      return AuthResult(_apiClient.currentUser!);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await _apiClient.post('/register',
          body: {
            'email': email,
            'password': password,
            'full_name': fullName,
          },
          requiresAuth: false);
      return AuthResult(_apiClient.currentUser!);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (_apiClient.isAuthenticated) {
        await _apiClient.post('/logout');
      }
    } finally {
      await _apiClient.clearSession();
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    throw DomainAuthException(
      'Google login belum tersedia di backend Laravel lokal.',
      code: 'GOOGLE_LOGIN_UNAVAILABLE',
    );
  }

  Object _handleError(dynamic error) {
    if (error is DomainAuthException) return error;
    if (error is NetworkException || error is DataException) return error;
    if (error is ApiException && error.statusCode != 422) return error;

    final message = error.toString();
    if (message.contains('Email atau password salah')) {
      return DomainAuthException(
        'Email atau password salah.',
        code: 'INVALID_CREDENTIALS',
      );
    }
    if (message.contains('has already been taken')) {
      return DomainAuthException(
        'Email ini sudah terdaftar. Silakan login.',
        code: 'EMAIL_EXISTS',
      );
    }
    return DomainAuthException(message);
  }
}

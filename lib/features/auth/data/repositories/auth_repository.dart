import 'package:personal_branding_app/core/network/api_client.dart';
import 'package:personal_branding_app/features/auth/domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  ApiUser? get currentUser => _apiClient.currentUser;

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
      _apiClient.clearSession();
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    throw 'Google login belum tersedia di backend Laravel lokal.';
  }

  String _handleError(dynamic error) {
    final message = error.toString();
    if (message.contains('Email atau password salah')) {
      return 'Email atau password salah.';
    }
    if (message.contains('has already been taken')) {
      return 'Email ini sudah terdaftar. Silakan login.';
    }
    return message;
  }
}

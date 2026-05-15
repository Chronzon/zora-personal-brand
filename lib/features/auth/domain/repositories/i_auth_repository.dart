import 'package:personal_branding_app/core/network/api_client.dart';

class AuthResult {
  final ApiUser user;

  const AuthResult(this.user);
}

abstract class AuthRepository {
  ApiUser? get currentUser;

  Future<bool> restoreSession();

  Future<AuthResult> signIn({
    required String email,
    required String password,
  });

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> signOut();

  Future<bool> signInWithGoogle();
}

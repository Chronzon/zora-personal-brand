import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Mendapatkan user saat ini (Session)
  User? get currentUser => _supabase.auth.currentUser;

  // Login dengan Email & Password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Register dengan Email, Password, & Nama Lengkap
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName
        }, // Metadata ini akan ditangkap Trigger Database
      );
    } catch (e) {
      print("ERROR GOOGLE SIGN IN: $e"); // <--- Tambahkan Log ini
      throw _handleError(e);
    }
  }

  // Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      // 1. Trigger Login Google Native (Android Dialog muncul)
      // PENTING: Ganti WEB_CLIENT_ID dengan Client ID dari TAHAP 2A
      const webClientId =
          '746741768835-enftvpsh4f0tolp10fu9lsdk4vnp3p0g.apps.googleusercontent.com';

      // Android Client ID tidak perlu dimasukkan di kodingan,
      // Google mendeteksinya otomatis lewat SHA-1 package name.

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;

      if (googleAuth == null) {
        throw 'Google Sign In dibatalkan oleh user.';
      }

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // 2. Kirim Token ke Supabase
      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      print("ERROR GOOGLE SIGN IN: $e"); // <--- Tambahkan Log ini
      throw _handleError(e);
    }
  }

  // Helper untuk pesan error yang lebih manusiawi
  String _handleError(dynamic error) {
    if (error is AuthException) {
      if (error.message.contains('Invalid login credentials')) {
        return 'Email atau password salah.';
      }
      if (error.message.contains('User already registered')) {
        return 'Email ini sudah terdaftar. Silakan login.';
      }
    }
    return error.toString();
  }
}

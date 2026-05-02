import 'package:flutter/material.dart';
import 'package:personal_branding_app/core/network/api_client.dart';
import 'package:personal_branding_app/features/auth/domain/repositories/i_auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiUser? get currentUser => _repository.currentUser;

  // Actions
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _repository.signIn(email: email, password: password);
      _setLoading(false);
      return true; // Sukses
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false; // Gagal
    }
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    _setLoading(true);
    try {
      await _repository.signUp(
          email: email, password: password, fullName: fullName);
      _setLoading(false);
      return true; // Sukses
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false; // Gagal
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _repository.signInWithGoogle();
      _setLoading(false);
      return true; // Sukses
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false; // Gagal
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null; // Reset error saat loading mulai
    notifyListeners();
  }
}

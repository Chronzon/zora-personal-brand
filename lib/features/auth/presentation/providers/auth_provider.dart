import 'package:flutter/material.dart';
import 'package:personal_branding_app/core/errors/error_handler.dart';
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
  Future<bool> restoreSession() async {
    try {
      final restored = await _repository.restoreSession();
      notifyListeners();
      return restored;
    } catch (e, stackTrace) {
      final failure = ErrorHandler.handleException(e, stackTrace: stackTrace);
      _errorMessage = failure.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _repository.signIn(email: email, password: password);
      return true; // Sukses
    } catch (e, stackTrace) {
      final failure = ErrorHandler.handleException(e, stackTrace: stackTrace);
      _errorMessage = failure.message;
      return false; // Gagal
    } finally {
      _setLoading(false, clearError: false);
    }
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    _setLoading(true);
    try {
      await _repository.signUp(
          email: email, password: password, fullName: fullName);
      return true; // Sukses
    } catch (e, stackTrace) {
      final failure = ErrorHandler.handleException(e, stackTrace: stackTrace);
      _errorMessage = failure.message;
      return false; // Gagal
    } finally {
      _setLoading(false, clearError: false);
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
      return true; // Sukses
    } catch (e, stackTrace) {
      final failure = ErrorHandler.handleException(e, stackTrace: stackTrace);
      _errorMessage = failure.message;
      return false; // Gagal
    } finally {
      _setLoading(false, clearError: false);
    }
  }

  void _setLoading(bool value, {bool clearError = true}) {
    _isLoading = value;
    if (clearError) {
      _errorMessage = null; // Reset error saat loading mulai
    }
    notifyListeners();
  }
}

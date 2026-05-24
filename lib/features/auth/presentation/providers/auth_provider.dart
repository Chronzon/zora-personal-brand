import 'package:flutter/material.dart';
import 'package:personal_branding_app/core/errors/error_handler.dart';
import 'package:personal_branding_app/core/network/api_client.dart';
import 'package:personal_branding_app/features/auth/domain/repositories/i_auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  bool _isLoading = false;
  bool _isGoogleConnectionLoading = false;
  bool _hasLoadedGoogleConnection = false;
  GoogleConnection? _googleConnection;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isGoogleConnectionLoading => _isGoogleConnectionLoading;
  GoogleConnection? get googleConnection => _googleConnection;
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

  Future<bool> completeOAuthSession(String token) async {
    _setLoading(true);
    try {
      final completed = await _repository.completeOAuthSession(token);
      _resetGoogleConnection();
      return completed;
    } catch (e, stackTrace) {
      final failure = ErrorHandler.handleException(e, stackTrace: stackTrace);
      _errorMessage = failure.message;
      return false;
    } finally {
      _setLoading(false, clearError: false);
    }
  }

  void setExternalAuthError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _repository.signIn(email: email, password: password);
      _resetGoogleConnection();
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
      _resetGoogleConnection();
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
    _resetGoogleConnection();
    notifyListeners();
  }

  Future<void> loadGoogleConnection({bool force = false}) async {
    if (currentUser == null || currentUser!.isAnonymous) return;
    if (_isGoogleConnectionLoading) return;
    if (_hasLoadedGoogleConnection && !force) return;

    _isGoogleConnectionLoading = true;
    notifyListeners();

    try {
      _googleConnection = await _repository.getGoogleConnection();
      _hasLoadedGoogleConnection = true;
    } catch (e, stackTrace) {
      final failure = ErrorHandler.handleException(e, stackTrace: stackTrace);
      _errorMessage = failure.message;
    } finally {
      _isGoogleConnectionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      return await _repository.signInWithGoogle();
    } catch (e, stackTrace) {
      final failure = ErrorHandler.handleException(e, stackTrace: stackTrace);
      _errorMessage = failure.message;
      return false; // Gagal
    } finally {
      _setLoading(false, clearError: false);
    }
  }

  Future<bool> connectGoogle() async {
    _setLoading(true);
    try {
      return await _repository.connectGoogle();
    } catch (e, stackTrace) {
      final failure = ErrorHandler.handleException(e, stackTrace: stackTrace);
      _errorMessage = failure.message;
      return false;
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

  void _resetGoogleConnection() {
    _googleConnection = null;
    _hasLoadedGoogleConnection = false;
    _isGoogleConnectionLoading = false;
  }
}

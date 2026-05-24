import 'dart:async';
import 'dart:convert';

import 'package:personal_branding_app/core/errors/exceptions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiUser {
  final String id;
  final String email;
  final String name;
  final bool isAnonymous;

  const ApiUser({
    required this.id,
    required this.email,
    required this.name,
    this.isAnonymous = false,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      isAnonymous: (json['email'] ?? '').startsWith('guest-'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'is_anonymous': isAnonymous,
    };
  }
}

class ApiClient {
  ApiClient()
      : baseUrl = (dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api')
            .replaceFirst(RegExp(r'/$'), '');

  static const Duration _requestTimeout = Duration(seconds: 120);
  static const String _tokenKey = 'api_token';
  static const String _userKey = 'api_user';

  final String baseUrl;
  String? _token;
  ApiUser? _currentUser;

  ApiUser? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null;

  Future<bool> completeOAuthSession(String token) async {
    if (token.isEmpty) return false;

    _token = token;

    try {
      final response = await get('/me');
      if (response is Map<String, dynamic> &&
          response['user'] is Map<String, dynamic>) {
        _currentUser = ApiUser.fromJson(response['user']);
        await _persistSession();
        return true;
      }
    } catch (_) {
      await clearSession();
      rethrow;
    }

    await clearSession();
    return false;
  }

  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(_tokenKey);
    final storedUser = prefs.getString(_userKey);

    if (storedToken == null || storedToken.isEmpty) {
      await clearSession();
      return false;
    }

    _token = storedToken;

    if (storedUser != null && storedUser.isNotEmpty) {
      try {
        final decodedUser = jsonDecode(storedUser);
        if (decodedUser is Map<String, dynamic>) {
          _currentUser = ApiUser.fromJson(decodedUser);
        }
      } catch (_) {
        _currentUser = null;
      }
    }

    try {
      final response = await get('/me');
      if (response is Map<String, dynamic> &&
          response['user'] is Map<String, dynamic>) {
        _currentUser = ApiUser.fromJson(response['user']);
        await _persistSession();
      }
      return _currentUser != null;
    } on DomainAuthException {
      await clearSession();
      return false;
    } catch (_) {
      return _currentUser != null;
    }
  }

  Future<void> ensureGuestSession() async {
    if (isAuthenticated) return;

    const uuid = Uuid();
    final guestId = uuid.v4();
    await post(
      '/register',
      body: {
        'email': 'guest-$guestId@local.test',
        'password': guestId,
        'full_name': 'Guest User',
      },
      requiresAuth: false,
    );
  }

  Future<dynamic> get(String path, {bool requiresAuth = true}) {
    return _send('GET', path, requiresAuth: requiresAuth);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) {
    return _send('POST', path, body: body, requiresAuth: requiresAuth);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) {
    return _send('PUT', path, body: body, requiresAuth: requiresAuth);
  }

  Future<dynamic> delete(String path, {bool requiresAuth = true}) {
    return _send('DELETE', path, requiresAuth: requiresAuth);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    if (requiresAuth && _token == null) {
      await ensureGuestSession();
    }

    final uri = Uri.parse('$baseUrl$path');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    final requestBody = body == null ? null : jsonEncode(body);
    late http.Response response;

    try {
      response = switch (method) {
        'GET' => await http.get(uri, headers: headers).timeout(_requestTimeout),
        'POST' => await http
            .post(uri, headers: headers, body: requestBody)
            .timeout(_requestTimeout),
        'PUT' => await http
            .put(uri, headers: headers, body: requestBody)
            .timeout(_requestTimeout),
        'DELETE' =>
          await http.delete(uri, headers: headers).timeout(_requestTimeout),
        _ => throw ApiException('Unsupported HTTP method: $method'),
      };
    } on TimeoutException {
      throw NetworkException(
        'Request timed out. Please try again.',
        code: 'TIMEOUT',
      );
    } catch (e) {
      throw NetworkException(
        'Cannot connect to API at $baseUrl. $e',
        code: 'CONNECTION_FAILED',
      );
    }

    final decoded = _decodeResponse(response);

    if (response.statusCode == 401) {
      await clearSession();
      throw DomainAuthException(
        _extractMessage(decoded,
            fallback: 'Session expired. Please login again.'),
        code: 'SESSION_EXPIRED',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _extractMessage(decoded, fallback: response.body),
        statusCode: response.statusCode,
      );
    }

    if (decoded is Map<String, dynamic> && decoded['token'] != null) {
      _token = decoded['token'];
      if (decoded['user'] is Map<String, dynamic>) {
        _currentUser = ApiUser.fromJson(decoded['user']);
        await _persistSession();
      }
    }

    return decoded;
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.body.isEmpty) return null;

    try {
      return jsonDecode(response.body);
    } on FormatException {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        throw DataException(
          'API returned an invalid response.',
          code: 'INVALID_JSON',
        );
      }
      return response.body;
    }
  }

  String _extractMessage(dynamic decoded, {required String fallback}) {
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'];
      if (message is String && message.isNotEmpty) return message;

      final error = decoded['error'];
      if (error is String && error.isNotEmpty) return error;

      final errors = decoded['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstValue = errors.values.first;
        if (firstValue is List && firstValue.isNotEmpty) {
          return firstValue.first.toString();
        }
        return firstValue.toString();
      }

      return decoded.toString();
    }

    if (decoded is String && decoded.isNotEmpty) return decoded;
    return fallback.isNotEmpty ? fallback : 'Unexpected API error.';
  }

  Future<void> _persistSession() async {
    if (_token == null || _currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token!);
    await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
  }

  Future<void> clearSession() async {
    _token = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}

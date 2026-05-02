import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
}

class ApiClient {
  ApiClient()
      : baseUrl = (dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api')
            .replaceFirst(RegExp(r'/$'), '');

  final String baseUrl;
  String? _token;
  ApiUser? _currentUser;

  ApiUser? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null;

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
        'GET' => await http.get(uri, headers: headers),
        'POST' => await http.post(uri, headers: headers, body: requestBody),
        'PUT' => await http.put(uri, headers: headers, body: requestBody),
        'DELETE' => await http.delete(uri, headers: headers),
        _ => throw ApiException('Unsupported HTTP method: $method'),
      };
    } catch (e) {
      throw ApiException('Cannot connect to API at $baseUrl. $e');
    }

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ?? decoded.toString()
          : response.body;
      throw ApiException(message, statusCode: response.statusCode);
    }

    if (decoded is Map<String, dynamic> && decoded['token'] != null) {
      _token = decoded['token'];
      _currentUser = ApiUser.fromJson(decoded['user']);
    }

    return decoded;
  }

  void clearSession() {
    _token = null;
    _currentUser = null;
  }
}

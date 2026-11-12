import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String get _baseUrl {
    const override = String.fromEnvironment('API_URL');
    if (override.isNotEmpty) return override;
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }
  static const _tokenKey = 'neon_session_token';

  static String? _token;
  static Map<String, dynamic>? _currentUser;
  static bool _initialized = false;

  static bool get hasConfiguration => true;
  static bool get isLoggedIn => _token != null;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static String get baseUrl => _baseUrl;

  static Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _initialized = true;
    if (_token != null) {
      await refreshUser();
    }
  }

  static bool get configured => true;

  static String? get currentToken => _token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Cookie': '__Secure-neon-auth.session_token=$_token',
      };

  static Future<void> _saveToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  static Future<void> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/neon/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw StateError(_errorMessage(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    await _saveToken(data['sessionToken'] as String?);
    _currentUser = data['usuario'] as Map<String, dynamic>?;
  }

  static Future<void> signUp(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/neon/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    if (response.statusCode != 201) {
      throw StateError(_errorMessage(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    await _saveToken(data['sessionToken'] as String?);
    _currentUser = data['usuario'] as Map<String, dynamic>?;
  }

  static Future<void> signOut() async {
    await _saveToken(null);
    _currentUser = null;
  }

  static Future<void> updateName(String name) async {
    if (_token == null) {
      throw StateError('No hay sesion activa.');
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/neon/update-user'),
      headers: _headers,
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode != 200) {
      throw StateError(_errorMessage(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _currentUser = data['usuario'] as Map<String, dynamic>?;
  }

  static Future<void> refreshUser() async {
    if (_token == null) {
      _currentUser = null;
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/neon/me'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _currentUser = data['usuario'] as Map<String, dynamic>?;
      } else {
        await _saveToken(null);
        _currentUser = null;
      }
    } catch (_) {
      _currentUser = null;
    }
  }

  static String _errorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['error']?.toString() ?? 'Error de autenticacion.';
    } catch (_) {
      return 'Error de autenticacion.';
    }
  }
}
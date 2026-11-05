import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static SupabaseClient? _client;
  static bool _initialized = false;
  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _key = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get hasConfiguration => _url.isNotEmpty || _key.isNotEmpty;

  static Future<void> init() async {
    if (_initialized) return;

    if (_url.isEmpty || _key.isEmpty) {
      throw StateError(
        'Configura SUPABASE_URL y SUPABASE_ANON_KEY con --dart-define.',
      );
    }

    await Supabase.initialize(url: _url, publishableKey: _key);

    _client = Supabase.instance.client;
    _initialized = true;
  }

  static bool get configured => _initialized;
  static SupabaseClient get client => _client!;
  static User? get currentUser =>
      _initialized ? _client!.auth.currentUser : null;
  static Stream<AuthState> get authState =>
      _initialized ? _client!.auth.onAuthStateChange : const Stream.empty();

  static Future<void> signIn(String email, String password) async {
    if (!_initialized) {
      throw StateError('Supabase no configurado con --dart-define.');
    }
    await _client!.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signUp(String email, String password, String name) async {
    if (!_initialized) {
      throw StateError('Supabase no configurado con --dart-define.');
    }
    await _client!.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
  }

  static Future<void> resetPassword(String email) async {
    if (!_initialized) {
      throw StateError('Supabase no configurado con --dart-define.');
    }
    await _client!.auth.resetPasswordForEmail(email);
  }

  static Future<void> signOut() async {
    if (_initialized) await _client!.auth.signOut();
  }

  static Future<void> signInWithGoogle() async {
    if (!_initialized) {
      throw StateError('Supabase no configurado con --dart-define.');
    }
    await _client!.auth.signInWithOAuth(OAuthProvider.google);
  }
}

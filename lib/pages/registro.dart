import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text_field.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});
  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();

  bool _showPass = false;
  bool _showPass2 = false;
  bool _terms = false;
  bool _loading = false;
  String? _error;
  String? _usernameError;

  String get _baseUrl => const String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:3000');

  Future<bool> _checkUsername() async {
    final u = _username.text.trim();
    if (u.length < 3) return false;
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/auth/check-username?username=$u'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['available'] == true;
      }
    } catch (_) {}
    return true;
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (!_terms) { setState(() => _error = 'Debes aceptar los términos y condiciones'); return; }
    setState(() { _loading = true; _error = null; _usernameError = null; });
    final available = await _checkUsername();
    if (!available) {
      setState(() { _usernameError = 'Este nombre de usuario ya está en uso. Prueba con otro.'; _loading = false; });
      return;
    }
    try {
      await AuthService.signUp(
        _email.text.trim().toLowerCase(),
        _pass.text,
        '${_nombre.text.trim()} ${_apellidos.text.trim()}',
      );
      try {
        await http.post(Uri.parse('$_baseUrl/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _email.text.trim().toLowerCase(),
            'nombre': _nombre.text.trim(),
            'apellidos': _apellidos.text.trim(),
            'usuario': _username.text.trim(),
          }),
        );
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro exitoso. Inicia sesión.')));
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field(TextEditingController c, String hint, IconData icon, {bool obscure = false, Widget? suffix, TextInputType? kb, String? Function(String?)? v}) {
    return AppTextField(controller: c, hint: hint, obscure: obscure, keyboardType: kb, validator: v,
      suffix: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: AppColors.textSecondary, size: 20), ?suffix]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _form,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.salmonLight, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.storefront, color: AppColors.primary)),
                    const SizedBox(width: 10),
                    RichText(text: const TextSpan(children: [
                      TextSpan(text: 'Shop', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      TextSpan(text: 'Now', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ])),
                  ]),
                  const SizedBox(height: 32),
                  const Text('ÚNETE A LA COMUNIDAD', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  const Text('Crear cuenta', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 30)),
                  const SizedBox(height: 8),
                  const Text('Compra, guarda y encuentra justo\nlo que necesitas.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4)),
                  const SizedBox(height: 24),
                  _field(_nombre, 'Nombre', Icons.person_outline, v: (v) => (v == null || v.trim().isEmpty) ? 'Nombre obligatorio' : null),
                  const SizedBox(height: 12),
                  _field(_apellidos, 'Apellidos', Icons.badge_outlined, v: (v) => (v == null || v.trim().isEmpty) ? 'Apellidos obligatorios' : null),
                  const SizedBox(height: 12),
                  _field(_username, 'Username', Icons.account_circle_outlined, v: (v) {
                    if (v == null || v.trim().isEmpty) return 'Username obligatorio';
                    final t = v.trim();
                    if (t.length < 3 || t.length > 30) return 'Entre 3 y 30 caracteres';
                    if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(t)) return 'Solo letras, números, _, ., -';
                    if (t.contains(' ')) return 'Sin espacios';
                    return null;
                  }),
                  if (_usernameError != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_usernameError!, style: const TextStyle(color: Colors.red, fontSize: 12))),
                  const SizedBox(height: 12),
                  _field(_email, 'Correo electrónico', Icons.mail_outline, kb: TextInputType.emailAddress, v: (v) {
                    if (v == null || v.trim().isEmpty) return 'Correo obligatorio';
                    final t = v.trim().toLowerCase();
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(t)) return 'Formato de correo inválido';
                    return null;
                  }),
                  const SizedBox(height: 12),
                  _field(_pass, 'Contraseña', Icons.lock_outline, obscure: !_showPass,
                    suffix: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary, size: 20), onPressed: () => setState(() => _showPass = !_showPass)),
                    v: (v) {
                      if (v == null || v.isEmpty) return 'Contraseña obligatoria';
                      if (v.length < 8) return 'Mínimo 8 caracteres';
                      return null;
                    }),
                  const SizedBox(height: 12),
                  _field(_pass2, 'Verificar contraseña', Icons.lock_outline, obscure: !_showPass2,
                    suffix: IconButton(icon: Icon(_showPass2 ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary, size: 20), onPressed: () => setState(() => _showPass2 = !_showPass2)),
                    v: (v) {
                      if (v == null || v.isEmpty) return 'Confirmación obligatoria';
                      if (v != _pass.text) return 'Las contraseñas no coinciden';
                      return null;
                    }),
                  const SizedBox(height: 16),
                  Row(children: [
                    Checkbox(value: _terms, onChanged: (v) => setState(() => _terms = v ?? false), activeColor: AppColors.primary),
                    const Expanded(child: Text('Acepto los Términos y condiciones y la Política de privacidad.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                  ]),
                  if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
                  const SizedBox(height: 8),
                  SizedBox(height: 44, width: double.infinity, child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 2, shadowColor: AppColors.primary.withValues(alpha: 0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _loading ? null : _submit,
                    child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Registrarse', style: TextStyle(fontWeight: FontWeight.w600)),
                  )),
                  const SizedBox(height: 24),
                  Center(child: GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: RichText(text: const TextSpan(children: [
                      TextSpan(text: '¿Ya tienes cuenta? ', style: TextStyle(color: AppColors.textSecondary)),
                      TextSpan(text: 'Inicia sesión', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ])),
                  )),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
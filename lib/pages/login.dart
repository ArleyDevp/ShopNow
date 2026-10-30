import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text_field.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _show = false;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final email = _email.text.trim();
    final pass = _pass.text;
    if (email.isEmpty || !email.contains('@')) { setState(() => _error = 'Correo inválido'); return; }
    if (pass.isEmpty) { setState(() => _error = 'Contraseña requerida'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.signIn(email, pass);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: AppColors.salmonLight, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.storefront, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    RichText(text: const TextSpan(children: [
                      TextSpan(text: 'Shop', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      TextSpan(text: 'Now', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ])),
                  ]),
                  const SizedBox(height: 40),
                  const Text('HOLA DE NUEVO', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  const Text('Iniciar sesión', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 30)),
                  const SizedBox(height: 8),
                  const Text('Ingresa para descubrir productos\nincreíbles elegidos para ti.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4)),
                  const SizedBox(height: 32),
                  const Text('Correo electrónico', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 8),
                  AppTextField(controller: _email, hint: 'nombre@correo.com', keyboardType: TextInputType.emailAddress,
                    suffix: const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.mail_outline, color: AppColors.textSecondary))),
                  const SizedBox(height: 16),
                  const Text('Contraseña', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 8),
                  AppTextField(controller: _pass, hint: 'Ingresa tu contraseña', obscure: !_show,
                    suffix: IconButton(icon: Icon(_show ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary), onPressed: () => setState(() => _show = !_show))),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/recuperar-password'),
                    child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  )),
                  if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
                  SizedBox(height: 44, width: double.infinity, child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 2, shadowColor: AppColors.primary.withValues(alpha: 0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _loading ? null : _submit,
                    child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Iniciar sesión', style: TextStyle(fontWeight: FontWeight.w600)),
                  )),
                  const SizedBox(height: 24),
                  Row(children: const [
                    Expanded(child: Divider(color: AppColors.border)),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('o continúa con', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                    Expanded(child: Divider(color: AppColors.border)),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(height: 48, width: double.infinity, child: OutlinedButton(
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: AppColors.border)),
                    onPressed: () async {
                      try { await AuthService.signInWithGoogle(); } catch (e) { debugPrint(e.toString()); }
                    },
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Image.network('https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg', width: 20, height: 20, errorBuilder: (_, _, _) => const Icon(Icons.g_mobiledata)),
                      const SizedBox(width: 8),
                      const Text('Google', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500)),
                    ]),
                  )),
                  const SizedBox(height: 32),
                  Center(child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/registro'),
                    child: RichText(text: const TextSpan(children: [
                      TextSpan(text: '¿Aún no tienes cuenta? ', style: TextStyle(color: AppColors.textSecondary)),
                      TextSpan(text: 'Crear cuenta', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ])),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
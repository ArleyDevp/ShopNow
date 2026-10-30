import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text_field.dart';
import '../services/auth_service.dart';

class RecuperarPasswordPage extends StatefulWidget {
  const RecuperarPasswordPage({super.key});
  @override
  State<RecuperarPasswordPage> createState() => _RecuperarPasswordPageState();
}

class _RecuperarPasswordPageState extends State<RecuperarPasswordPage> {
  final _email = TextEditingController();
  bool _loading = false;
  String? _msg;

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) { setState(() => _msg = 'Correo inválido'); return; }
    setState(() { _loading = true; _msg = null; });
    try {
      await AuthService.resetPassword(email);
      setState(() => _msg = 'Si existe una cuenta asociada a este correo, recibirás un enlace para recuperar tu contraseña.');
    } catch (e) {
      setState(() => _msg = e.toString());
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Align(alignment: Alignment.centerLeft, child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 20)),
                )),
                const SizedBox(height: 32),
                // Ilustración
                Stack(alignment: Alignment.center, children: [
                  Container(width: 160, height: 160, decoration: BoxDecoration(color: AppColors.salmonLight, shape: BoxShape.circle)),
                  Container(width: 110, height: 110, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), shape: BoxShape.circle)),
                  Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.mail_outline, color: Colors.white, size: 32)),
                  Positioned(top: 20, right: 28, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))),
                  Positioned(bottom: 24, left: 30, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.textDark, shape: BoxShape.circle))),
                ]),
                const SizedBox(height: 40),
                const Text('RECUPERA TU ACCESO', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 2)),
                const SizedBox(height: 8),
                const Text('¿Olvidaste tu\ncontraseña?', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 26, height: 1.2)),
                const SizedBox(height: 8),
                const Text('No te preocupes. Escribe tu correo y te\nenviaremos un enlace de recuperación.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4)),
                const SizedBox(height: 32),
                Align(alignment: Alignment.centerLeft, child: const Text('Correo electrónico', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500, fontSize: 14))),
                const SizedBox(height: 8),
                AppTextField(controller: _email, hint: 'nombre@correo.com', keyboardType: TextInputType.emailAddress,
                  suffix: const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.mail_outline, color: AppColors.textSecondary))),
                const SizedBox(height: 16),
                if (_msg != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_msg!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                SizedBox(height: 44, width: double.infinity, child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 2, shadowColor: AppColors.primary.withValues(alpha: 0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _loading ? null : _submit,
                  child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Enviar enlace', style: TextStyle(fontWeight: FontWeight.w600)),
                )),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.textSecondary),
                  label: const Text('Volver a iniciar sesión', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
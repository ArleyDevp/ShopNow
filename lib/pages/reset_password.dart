import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? token;
  const ResetPasswordPage({super.key, this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _mostrar = false;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) _tokenController.text = widget.token!;
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validaPass(String v) =>
      v.length >= 8 && RegExp(r'[A-Z]').hasMatch(v) && RegExp(r'[a-z]').hasMatch(v) && RegExp(r'[0-9]').hasMatch(v);

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await AuthService.resetPassword(_tokenController.text.trim(), _passController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña restablecida correctamente.'), backgroundColor: AppColors.success),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo restablecer: $e'), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tokenController,
                decoration: const InputDecoration(labelText: 'Token'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Token obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passController,
                obscureText: !_mostrar,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(_mostrar ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _mostrar = !_mostrar),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa la contraseña';
                  if (!_validaPass(v)) return 'Mín 8, mayúscula, minúscula y número';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                obscureText: !_mostrar,
                decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
                validator: (v) {
                  if (v != _passController.text) return 'No coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _guardar,
                  child: Text(_cargando ? 'Guardando...' : 'Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

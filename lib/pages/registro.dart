import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/shopnow_logo.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();

  // Campos extra del flujo original (no visibles en el mockup de paso 1).
  final _apellido = TextEditingController();
  final _usuario = TextEditingController();
  final _confirmar = TextEditingController();

  bool _mostrarPassword = false;
  bool _aceptaTerminos = false;
  bool _cargando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _password.dispose();
    _apellido.dispose();
    _usuario.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _cargando = true);
    // TODO: conectar con el backend (POST /api/auth/register).
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _cargando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cuenta creada. Inicia sesión para continuar.'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purple,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
              child: Row(
                children: [
                  const ShopNowLogo(size: 38, showText: true),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      '+12k vecinos',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HAZTE PARTE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tu próxima joya\nestá cerca.',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 0.98,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lime,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Tu mercado te espera',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _AvatarStack(),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 26, 28, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PASO 01',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textMuted,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Crea tu perfil',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.text,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.purple,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Tu nombre',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nombre,
                          decoration: const InputDecoration(
                            hintText: '¿Cómo te llamas?',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              size: 20,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ingresa tu nombre'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tu correo',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _correo,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'nombre@correo.com',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              size: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(value.trim())) {
                              return 'Correo no válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Crea una contraseña',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _password,
                          obscureText: !_mostrarPassword,
                          decoration: InputDecoration(
                            hintText: 'Mínimo 8 caracteres',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _mostrarPassword = !_mostrarPassword,
                              ),
                              icon: Icon(
                                _mostrarPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Crea una contraseña';
                            }
                            if (value.length < 8) {
                              return 'Usa al menos 8 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: _aceptaTerminos,
                              onChanged: (v) => setState(
                                () => _aceptaTerminos = v ?? false,
                              ),
                              activeColor: AppColors.purple,
                            ),
                            Expanded(
                              child: Text(
                                'Acepto los Términos y la Política de privacidad',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _cargando ? null : _registrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _cargando
                                  ? 'Creando...'
                                  : 'Crear mi cuenta  →',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¿Ya eres parte? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  'Inicia sesión',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.purple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 48,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _Avatar(color: AppColors.lime, initials: 'MA'),
          ),
          Positioned(
            left: 26,
            child: _Avatar(color: const Color(0xFF90CAF9), initials: 'JP'),
          ),
          Positioned(
            left: 52,
            child: _Avatar(color: const Color(0xFFF48FB1), initials: 'LU'),
          ),
          Positioned(
            left: 78,
            child: _Avatar(color: Colors.white, initials: '+'),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.color, required this.initials});

  final Color color;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: color == Colors.white ? AppColors.purple : Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

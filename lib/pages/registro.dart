
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../widgets/app_text_field.dart';

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

  String get _baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';

  // ==========================================
  // VERIFICAR DISPONIBILIDAD DEL USERNAME
  // ==========================================

  Future<bool> _checkUsername() async {
    final username = _username.text.trim();

    final uri = Uri.parse(
      '$_baseUrl/api/auth/check-username',
    ).replace(
      queryParameters: {
        'username': username,
      },
    );

    final response = await http.get(uri).timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo verificar el nombre de usuario.',
      );
    }

    final data = jsonDecode(response.body);

    return data['available'] == true;
  }

  // ==========================================
  // REGISTRAR USUARIO EN SUPABASE
  // ==========================================

  Future<void> _submit() async {
    if (_loading) return;

    FocusScope.of(context).unfocus();

    if (!_form.currentState!.validate()) {
      return;
    }

    if (!_terms) {
      setState(() {
        _error = 'Debes aceptar los términos y condiciones.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _usernameError = null;
    });

    try {
      // 1. Verificar username

      final available = await _checkUsername();

      if (!mounted) return;

      if (!available) {
        setState(() {
          _usernameError =
              'Este nombre de usuario ya está en uso.';
        });
        return;
      }

      // 2. Enviar datos al backend

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'nombre': _nombre.text.trim(),
              'apellidos': _apellidos.text.trim(),
              'usuario': _username.text.trim(),
              'email': _email.text.trim().toLowerCase(),
              'password': _pass.text,
              'confirmarPassword': _pass2.text,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
          );

      final data = jsonDecode(response.body);

      // 3. Registro exitoso

      if (response.statusCode == 201) {
        if (!mounted) return;

        final mensaje = data['message'] ??
            'Cuenta creada correctamente.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            duration: const Duration(seconds: 5),
            backgroundColor: AppColors.primary,
          ),
        );

        Navigator.pushReplacementNamed(
          context,
          '/login',
        );

        return;
      }

      // 4. Errores del servidor

      if (response.statusCode == 409) {
        final mensaje = data['error'] ??
            'El usuario o correo ya está registrado.';

        setState(() {
          _error = mensaje;

          if (mensaje.toLowerCase().contains('username')) {
            _usernameError = mensaje;
          }
        });

        return;
      }

      setState(() {
        _error = data['error'] ??
            'No se pudo completar el registro.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ==========================================
  // CAMPOS PERSONALIZADOS
  // ==========================================

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscure = false,
    Widget? suffix,
    TextInputType? kb,
    String? Function(String?)? validator,
  }) {
    return AppTextField(
      controller: controller,
      hint: hint,
      obscure: obscure,
      keyboardType: kb,
      validator: validator,
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
            size: 20,
          ),
          ?suffix,
        ],
      ),
    );
  }

  // ==========================================
  // LIBERAR CONTROLADORES
  // ==========================================

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    _username.dispose();
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();

    super.dispose();
  }

  // ==========================================
  // INTERFAZ
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // LOGO SHOPNOW

                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.salmonLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Shop',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              TextSpan(
                                text: 'Now',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // TITULO

                    const Text(
                      'ÚNETE A LA COMUNIDAD',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Crear cuenta',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Compra, guarda y encuentra justo\n'
                      'lo que necesitas.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // NOMBRE

                    _field(
                      _nombre,
                      'Nombre',
                      Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Nombre obligatorio';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // APELLIDOS

                    _field(
                      _apellidos,
                      'Apellidos',
                      Icons.badge_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Apellidos obligatorios';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // USERNAME

                    _field(
                      _username,
                      'Username',
                      Icons.account_circle_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Username obligatorio';
                        }

                        final username = v.trim();

                        if (username.length < 3 ||
                            username.length > 30) {
                          return 'Entre 3 y 30 caracteres';
                        }

                        if (!RegExp(
                          r'^[a-zA-Z0-9_.-]+$',
                        ).hasMatch(username)) {
                          return 'Solo letras, números, _, . y -';
                        }

                        return null;
                      },
                    ),

                    if (_usernameError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _usernameError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // CORREO ELECTRONICO

                    _field(
                      _email,
                      'Correo electrónico',
                      Icons.mail_outline,
                      kb: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Correo obligatorio';
                        }

                        final email = v.trim();

                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email)) {
                          return 'Formato de correo inválido';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // CONTRASEÑA

                    _field(
                      _pass,
                      'Contraseña',
                      Icons.lock_outline,
                      obscure: !_showPass,
                      suffix: IconButton(
                        icon: Icon(
                          _showPass
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPass = !_showPass;
                          });
                        },
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Contraseña obligatoria';
                        }

                        if (v.length < 8) {
                          return 'Mínimo 8 caracteres';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // VERIFICAR CONTRASEÑA

                    _field(
                      _pass2,
                      'Verificar contraseña',
                      Icons.lock_outline,
                      obscure: !_showPass2,
                      suffix: IconButton(
                        icon: Icon(
                          _showPass2
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPass2 = !_showPass2;
                          });
                        },
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirmación obligatoria';
                        }

                        if (v != _pass.text) {
                          return 'Las contraseñas no coinciden';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // TERMINOS Y CONDICIONES

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _terms,
                          onChanged: _loading
                              ? null
                              : (v) {
                                  setState(() {
                                    _terms = v ?? false;
                                    _error = null;
                                  });
                                },
                          activeColor: AppColors.primary,
                        ),
                        const Expanded(
                          child: Text(
                            'Acepto los Términos y condiciones '
                            'y la Política de privacidad.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // MENSAJES DE ERROR

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8,
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),

                    // BOTON REGISTRARSE

                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: AppColors.primary.withValues(
                            alpha: 0.3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Registrarse',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // VOLVER AL LOGIN

                    Center(
                      child: GestureDetector(
                        onTap: _loading
                            ? null
                            : () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              },
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: '¿Ya tienes cuenta? ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: 'Inicia sesión',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

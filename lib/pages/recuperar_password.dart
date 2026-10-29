
import 'package:flutter/material.dart';

class RecuperarPasswordPage extends StatefulWidget {
  const RecuperarPasswordPage({super.key});

  @override
  State<RecuperarPasswordPage> createState() =>
      _RecuperarPasswordPageState();
}

class _RecuperarPasswordPageState
    extends State<RecuperarPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();

  bool _solicitudEnviada = false;

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  void _recuperarPassword() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _solicitudEnviada = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperar contraseña'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 450),
            child: _solicitudEnviada
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mark_email_read_outlined,
                        size: 80,
                        color: Colors.indigo,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Solicitud preparada',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'El formulario está listo, pero todavía '
                        'debemos conectar el servidor para enviar '
                        'el correo de recuperación.',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Volver al inicio de sesión'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _solicitudEnviada = false;
                          });
                        },
                        child: Text('Intentar con otro correo'),
                      ),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.lock_reset,
                          size: 80,
                          color: Colors.indigo,
                        ),
                        SizedBox(height: 20),
                        Text(
                          '¿Olvidaste tu contraseña?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Escribe el correo asociado a tu cuenta '
                          'para solicitar la recuperación.',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 28),
                        TextFormField(
                          controller: _correoController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Ingresa tu correo electrónico';
                            }

                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(value.trim())) {
                              return 'Ingresa un correo válido';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: FilledButton(
                            onPressed: _recuperarPassword,
                            child: Text('Solicitar recuperación'),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Volver al inicio de sesión'),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

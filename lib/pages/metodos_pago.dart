import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../services/auth_service.dart';

class MetodosPagoPage extends StatefulWidget {
  const MetodosPagoPage({super.key});

  @override
  State<MetodosPagoPage> createState() => _MetodosPagoPageState();
}

class _MetodosPagoPageState extends State<MetodosPagoPage> {
  static String _keyFor(String email) => 'tarjetas_${email.isEmpty ? 'anon' : email}';

  List<Map<String, dynamic>> _tarjetas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final email = AuthService.currentUser?['email']?.toString() ?? '';
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(email));
    setState(() {
      if (raw != null) {
        _tarjetas = (jsonDecode(raw) as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    final email = AuthService.currentUser?['email']?.toString() ?? '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFor(email), jsonEncode(_tarjetas));
  }

  Future<void> _agregar() async {
    final numeroCtrl = TextEditingController();
    final titularCtrl = TextEditingController();
    final expiracionCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva tarjeta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numeroCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Numero de tarjeta'),
            ),
            TextField(
              controller: titularCtrl,
              decoration: const InputDecoration(labelText: 'Titular'),
            ),
            TextField(
              controller: expiracionCtrl,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(labelText: 'Vencimiento (MM/AA)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    final numero = numeroCtrl.text.replaceAll(' ', '');
    final titular = titularCtrl.text.trim();
    final vencimiento = expiracionCtrl.text.trim();
    if (numero.length < 4 || titular.isEmpty) return;

    setState(() {
      _tarjetas.add({
        'titular': titular,
        'ultimos4': numero.substring(numero.length - 4),
        'vencimiento': vencimiento,
      });
    });
    await _guardar();
  }

  Future<void> _eliminar(int index) async {
    setState(() => _tarjetas.removeAt(index));
    await _guardar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Metodos de pago'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        onPressed: _agregar,
        child: const Icon(Icons.add_rounded),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _tarjetas.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.credit_card_off_outlined,
                            size: 64, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        Text(
                          'Aun no tienes metodos de pago guardados.',
                          textAlign: TextAlign.center,
                          style: AppText.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _tarjetas.length,
                  itemBuilder: (context, index) {
                    final t = _tarjetas[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.coralPale,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.credit_card_rounded,
                              color: AppColors.coral, size: 20),
                        ),
                        title: Text(
                          '**** **** **** ${t['ultimos4']}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${t['titular']}  -  Vence ${t['vencimiento']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.danger),
                          onPressed: () => _eliminar(index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

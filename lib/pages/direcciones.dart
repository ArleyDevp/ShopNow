import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../services/auth_service.dart';

class DireccionesPage extends StatefulWidget {
  const DireccionesPage({super.key});

  @override
  State<DireccionesPage> createState() => _DireccionesPageState();
}

class _DireccionesPageState extends State<DireccionesPage> {
  static String _keyFor(String email) => 'direcciones_${email.isEmpty ? 'anon' : email}';

  List<Map<String, dynamic>> _direcciones = [];
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
        _direcciones = (jsonDecode(raw) as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    final email = AuthService.currentUser?['email']?.toString() ?? '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFor(email), jsonEncode(_direcciones));
  }

  Future<void> _agregar() async {
    final etiquetaCtrl = TextEditingController();
    final direccionCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva direccion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: etiquetaCtrl,
              decoration: const InputDecoration(
                labelText: 'Etiqueta (Casa, Trabajo...)',
              ),
            ),
            TextField(
              controller: direccionCtrl,
              decoration: const InputDecoration(labelText: 'Direccion completa'),
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
    final etiqueta = etiquetaCtrl.text.trim();
    final direccion = direccionCtrl.text.trim();
    if (etiqueta.isEmpty || direccion.isEmpty) return;

    setState(() {
      _direcciones.add({'etiqueta': etiqueta, 'direccion': direccion});
    });
    await _guardar();
  }

  Future<void> _eliminar(int index) async {
    setState(() => _direcciones.removeAt(index));
    await _guardar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Direcciones'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        onPressed: _agregar,
        child: const Icon(Icons.add_rounded),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _direcciones.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off_outlined,
                            size: 64, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        Text(
                          'Aun no tienes direcciones guardadas.',
                          textAlign: TextAlign.center,
                          style: AppText.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _direcciones.length,
                  itemBuilder: (context, index) {
                    final d = _direcciones[index];
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
                          child: const Icon(Icons.location_on_outlined,
                              color: AppColors.coral, size: 20),
                        ),
                        title: Text(
                          d['etiqueta'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(d['direccion'].toString()),
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

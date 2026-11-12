import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/widgets/primary_button.dart';
import '../services/auth_service.dart';
import '../state/favoritos_store.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key, this.onExplorar});

  final VoidCallback? onExplorar;

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  List<Map<String, dynamic>> _productos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/api/products'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final products = data['products'] as List<dynamic>;
        setState(() {
          _productos = products.map((item) {
            final p = item as Map<String, dynamic>;
            return <String, dynamic>{
              'id': p['id'],
              'nombre': p['name']?.toString() ?? '',
              'precio': p['priceRetail'] ?? 0,
              'categoria': 'Productos',
              'icono': Icons.shopping_bag,
            };
          }).toList();
          _cargando = false;
        });
      } else {
        setState(() => _cargando = false);
      }
    } catch (_) {
      setState(() => _cargando = false);
    }
  }

  Map<String, dynamic>? _buscar(String nombre) {
    for (final p in _productos) {
      if (p['nombre'] == nombre) return p;
    }
    return null;
  }

  String _precio(num valor) {
    final texto = valor.round().toString();
    final resultado = StringBuffer();
    for (int i = 0; i < texto.length; i++) {
      if (i > 0 && (texto.length - i) % 3 == 0) {
        resultado.write('.');
      }
      resultado.write(texto[i]);
    }
    return '\$$resultado';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.favorite_rounded, color: AppColors.coral, size: 20),
            SizedBox(width: 8),
            Text('Tus favoritos'),
          ],
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : AnimatedBuilder(
        animation: favoritosStore,
        builder: (context, _) {
          final nombres = favoritosStore.nombres;
          if (nombres.isEmpty) {
            return _EmptyFavoritos(onExplorar: widget.onExplorar ?? () {});
          }

          final items = nombres
              .map(_buscar)
              .whereType<Map<String, dynamic>>()
              .toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('${items.length} productos guardados', style: AppText.small),
              const SizedBox(height: 12),
              ...items.map((p) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.coralPale,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          p['icono'] as IconData,
                          color: AppColors.coral,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        p['nombre'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        '${p['categoria']}  ·  ${_precio(p['precio'] as num)}',
                        style: AppText.small,
                      ),
                      trailing: IconButton(
                        tooltip: 'Quitar de favoritos',
                        onPressed: () =>
                            favoritosStore.alternar(p['nombre'].toString()),
                        icon: const Icon(
                          Icons.favorite_rounded,
                          color: AppColors.coral,
                        ),
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.producto,
                        arguments: p,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyFavoritos extends StatelessWidget {
  const _EmptyFavoritos({required this.onExplorar});

  final VoidCallback onExplorar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.rose,
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 64,
                color: AppColors.coral,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tus favoritos',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Guarda los productos que amas y vuelve a ellos cuando quieras.',
              textAlign: TextAlign.center,
              style: AppText.bodyMuted,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 240,
              child: PrimaryButton(
                label: 'Explorar productos',
                onPressed: onExplorar,
                color: AppColors.coral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

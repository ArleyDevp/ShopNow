import 'package:flutter/material.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/widgets/primary_button.dart';
import '../state/favoritos_store.dart';

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key, this.onExplorar});

  final VoidCallback? onExplorar;

  static const _productos = [
    {
      'nombre': 'Audífonos Bluetooth',
      'precio': 89900,
      'categoria': 'Tecnología',
      'icono': Icons.headphones,
      'descripcion': 'Audífonos inalámbricos para escuchar música.',
    },
    {
      'nombre': 'Reloj inteligente',
      'precio': 129900,
      'categoria': 'Tecnología',
      'icono': Icons.watch,
      'descripcion': 'Reloj inteligente para tus actividades diarias.',
    },
    {
      'nombre': 'Mochila urbana',
      'precio': 74900,
      'categoria': 'Accesorios',
      'icono': Icons.backpack,
      'descripcion': 'Mochila práctica para estudiar y viajar.',
    },
    {
      'nombre': 'Gorra deportiva',
      'precio': 39900,
      'categoria': 'Ropa',
      'icono': Icons.checkroom,
      'descripcion': 'Gorra cómoda para actividades al aire libre.',
    },
    {
      'nombre': 'Camiseta casual',
      'precio': 49900,
      'categoria': 'Ropa',
      'icono': Icons.dry_cleaning,
      'descripcion': 'Camiseta para usar todos los días.',
    },
    {
      'nombre': 'Gafas de sol',
      'precio': 59900,
      'categoria': 'Accesorios',
      'icono': Icons.wb_sunny_outlined,
      'descripcion': 'Gafas de sol con diseño moderno.',
    },
  ];

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
      body: AnimatedBuilder(
        animation: favoritosStore,
        builder: (context, _) {
          final nombres = favoritosStore.nombres;
          if (nombres.isEmpty) {
            return _EmptyFavoritos(
              onExplorar: onExplorar ?? () {},
            );
          }

          final items = nombres
              .map(_buscar)
              .whereType<Map<String, dynamic>>()
              .toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '${items.length} productos guardados',
                style: AppText.small,
              ),
              const SizedBox(height: 12),
              ...items.map((p) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
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
                      onPressed: () => favoritosStore.alternar(
                        p['nombre'].toString(),
                      ),
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

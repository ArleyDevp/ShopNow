import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/widgets/shopnow_logo.dart';
import '../services/auth_service.dart';
import '../state/favoritos_store.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _busqueda = TextEditingController();
  String _categoria = 'Todos';
  List<Map<String, dynamic>> _productos = [];
  bool _cargandoProductos = true;
  String _nombreUsuario = 'Usuario';

  @override
  void initState() {
    super.initState();
    _nombreUsuario = AuthService.currentUser?['name']?.toString() ?? 'Usuario';
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    for (var intento = 0; intento < 3; intento++) {
      try {
        final response = await http.get(Uri.parse('${AuthService.baseUrl}/api/products'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final products = data['products'] as List<dynamic>;
          if (!mounted) return;
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
            _cargandoProductos = false;
          });
          return;
        }
      } catch (_) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
    if (mounted) setState(() => _cargandoProductos = false);
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  String _precio(num valor) {
    final texto = valor.round().toString();
    final resultado = StringBuffer();
    for (var i = 0; i < texto.length; i++) {
      if (i > 0 && (texto.length - i) % 3 == 0) {
        resultado.write('.');
      }
      resultado.write(texto[i]);
    }
    return '\$$resultado';
  }

  @override
  Widget build(BuildContext context) {
    final categorias = [
      ('Todos', '01'),
      ('Productos', '02'),
    ];

    final filtrados = _productos.where((producto) {
      final nombre = producto['nombre'].toString().toLowerCase();
      final texto = _busqueda.text.toLowerCase().trim();

      return nombre.contains(texto) &&
          (_categoria == 'Todos' || producto['categoria'] == _categoria);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const ShopNowLogo(size: 36, showText: true),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.coral,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                'AL',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Buenos días, $_nombreUsuario', style: AppText.headline),
          const SizedBox(height: 4),
          Text('Encuentra tu próximo favorito.', style: AppText.bodyMuted),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _busqueda,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _PromoCard(),
          const SizedBox(height: 22),
          if (_cargandoProductos)
            const Center(child: CircularProgressIndicator()),
          Text('Categorías', style: AppText.title),
          const SizedBox(height: 12),
          SizedBox(
            height: 74,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categorias.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final cat = categorias[i];
                final seleccionada = _categoria == cat.$1;
                return GestureDetector(
                  onTap: () => setState(() => _categoria = cat.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 96,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: seleccionada ? AppColors.lime : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: seleccionada
                            ? AppColors.limeDeep
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cat.$2,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: seleccionada
                                ? AppColors.text
                                : AppColors.textMuted,
                          ),
                        ),
                        Text(
                          cat.$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Text('Elegidos para ti', style: AppText.title),
              const Spacer(),
              Text('${filtrados.length} productos', style: AppText.bodyMuted),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columnas = constraints.maxWidth >= 800
                  ? 4
                  : constraints.maxWidth >= 520
                  ? 3
                  : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtrados.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnas,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  final producto = filtrados[index];
                  return _ProductoCard(
                    producto: producto,
                    precio: _precio(producto['precio'] as num),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.producto,
                      arguments: producto,
                    ),
                  );
                },
              );
            },
          ),
          if (filtrados.isEmpty)
            Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Text(
                  'No se encontraron productos.',
                  style: AppText.bodyMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.greenDark, AppColors.greenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'OFERTA',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hasta 40% off\nen tecnología',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Solo por esta semana',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.headphones_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductoCard extends StatelessWidget {
  const _ProductoCard({
    required this.producto,
    required this.precio,
    required this.onTap,
  });

  final Map<String, dynamic> producto;
  final String precio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: favoritosStore,
      builder: (context, _) {
        final esFav = favoritosStore.esFavorito(producto['nombre'].toString());
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.coralPale,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            producto['icono'] as IconData,
                            size: 46,
                            color: AppColors.coral,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => favoritosStore.alternar(
                              producto['nombre'].toString(),
                            ),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Icon(
                                esFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 16,
                                color: esFav
                                    ? AppColors.coral
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    producto['categoria'].toString(),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    producto['nombre'].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    precio,
                    style: const TextStyle(
                      color: AppColors.coral,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

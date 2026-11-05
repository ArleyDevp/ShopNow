import 'package:flutter/material.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/widgets/shopnow_logo.dart';
import '../state/favoritos_store.dart';

const _products = [
  Product(id:'1', name:'Zapatillas Urban', category:'Moda', price:59.99, image:'https://picsum.photos/200?1', featured:true),
  Product(id:'2', name:'Auriculares Pro', category:'Tech', price:89.99, image:'https://picsum.photos/200?2', featured:true),
  Product(id:'3', name:'Mochila Travel', category:'Accesorios', price:39.99, image:'https://picsum.photos/200?3'),
  Product(id:'4', name:'Reloj Smart', category:'Tech', price:129.99, image:'https://picsum.photos/200?4'),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _q = '';
  final String _cat = 'Todos';

  List<Product> get _filtered => _products.where((p) {
    final okQ = _q.isEmpty || p.name.toLowerCase().contains(_q.toLowerCase());
    final okC = _cat == 'Todos' || p.category == _cat;
    return okQ && okC;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final categorias = [
      ('Todos', '01'),
      ('Tecnología', '02'),
      ('Ropa', '03'),
      ('Accesorios', '04'),
    ];

    final filtrados = _productos.where((producto) {
      final nombre = producto['nombre'].toString().toLowerCase();
      final texto = _busqueda.text.toLowerCase().trim();

      return nombre.contains(texto) &&
          (_categoria == 'Todos' ||
              producto['categoria'] == _categoria);
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
          Text(
            'Buenos días, Arley',
            style: AppText.headline,
          ),
          const SizedBox(height: 4),
          Text(
            'Encuentra tu próximo favorito.',
            style: AppText.bodyMuted,
          ),
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
          Text(
            'Categorías',
            style: AppText.title,
          ),
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
              Text(
                'Elegidos para ti',
                style: AppText.title,
              ),
              const Spacer(),
              Text(
                '${filtrados.length} productos',
                style: AppText.bodyMuted,
              ),
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
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
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
        final esFav = favoritosStore.esFavorito(
          producto['nombre'].toString(),
        );
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
                                    color:
                                        Colors.black.withValues(alpha: 0.08),
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

class _Cat extends StatelessWidget {
  final IconData icon; final String label; final Color bg;
  const _Cat({required this.icon, required this.label, required this.bg});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Column(children: [
      Container(width: 64, height: 64, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: AppColors.textDark)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
    ])));
  }
}
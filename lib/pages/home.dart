import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../main.dart' as m;
import '../services/auth_service.dart';

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
    final user = AuthService.currentUser;
    final name = user?.userMetadata?['full_name'] ?? 'Mariana';
    final initials = name.isNotEmpty ? name[0].toUpperCase() + (name.split(' ').length > 1 ? name.split(' ')[1][0].toUpperCase() : '') : 'ML';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.salmonLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.storefront, color: AppColors.primary)),
              const SizedBox(width: 8),
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'Shop', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                TextSpan(text: 'Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ])),
              const Spacer(),
              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: Stack(children: [const Center(child: Icon(Icons.notifications_none, color: AppColors.textDark)), Positioned(right: 8, top: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)))])),
              const SizedBox(width: 8),
              GestureDetector(onTap: () {}, child: CircleAvatar(backgroundColor: AppColors.textDark, child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            ]),
            const SizedBox(height: 16),
            // Saludo + número decorativo
            Stack(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Buenos días, $name', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('¿Qué quieres\ndescubrir hoy?', style: TextStyle(color: AppColors.textDark, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2)),
              ]),
              Positioned(right: 0, top: 0, child: Text('02', style: TextStyle(color: AppColors.primary.withValues(alpha: 0.15), fontSize: 64, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 16),
            // Buscador
            Row(children: [
              Expanded(child: TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: const InputDecoration(hintText: 'Buscar productos, marcas...', prefixIcon: Icon(Icons.search, color: AppColors.textSecondary)),
              )),
              const SizedBox(width: 8),
              Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.tune, color: Colors.white)),
            ]),
            const SizedBox(height: 16),
            // Banner
            Container(
              height: 150, width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFF1F3B2C), borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Expanded(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('SEMANA SHOPNOW', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Hasta 40% off', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  const Text('En tus favoritos de temporada', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.arrow_forward, size: 16), label: const Text('Comprar ahora'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.textDark, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                ]))),
                Expanded(child: ClipRRect(borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)), child: Image.network('https://picsum.photos/300/200?5', fit: BoxFit.cover))),
              ]),
            ),
            const SizedBox(height: 16),
            // Categorías
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Categorías', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textDark)),
              TextButton(onPressed: () {}, child: const Text('Ver todas', style: TextStyle(color: AppColors.primary))),
            ]),
            const SizedBox(height: 8),
            Row(children: const [
              _Cat(icon: Icons.new_releases_outlined, label: 'Novedades', bg: Color(0xFFFFF0E8)),
              _Cat(icon: Icons.checkroom, label: 'Moda', bg: Color(0xFFEEF2E9)),
              _Cat(icon: Icons.home_outlined, label: 'Hogar', bg: Color(0xFFF0EAF5)),
              _Cat(icon: Icons.face, label: 'Belleza', bg: Color(0xFFF8E9DF)),
            ]),
            const SizedBox(height: 16),
            // Productos destacados
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('ELEGIDOS PARA TI', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                Text('Lo último', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textDark)),
              ]),
              TextButton(onPressed: () {}, child: const Text('Ver todo', style: TextStyle(color: AppColors.primary))),
            ]),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final p = _filtered[i];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(p.image, fit: BoxFit.cover, width: double.infinity))),
                    const SizedBox(height: 6),
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(p.category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Row(children: [
                      Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(icon: Icon(m.favoritesService.isFav(p.id) ? Icons.favorite : Icons.favorite_border, color: AppColors.primary, size: 20), onPressed: () => setState(() => m.favoritesService.toggle(p))),
                      IconButton(icon: const Icon(Icons.add_shopping_cart, size: 20), onPressed: () => setState(() => m.cartService.add(p))),
                    ]),
                  ])),
                );
              },
            ),
          ]),
        ),
      ),
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
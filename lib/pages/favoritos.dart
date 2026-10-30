import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../main.dart' as m;

const _all = [
  Product(id:'1', name:'Zapatillas Urban', category:'Moda', price:59.99, image:'https://picsum.photos/200?1'),
  Product(id:'2', name:'Auriculares Pro', category:'Tech', price:89.99, image:'https://picsum.photos/200?2'),
  Product(id:'3', name:'Mochila Travel', category:'Accesorios', price:39.99, image:'https://picsum.photos/200?3'),
  Product(id:'4', name:'Reloj Smart', category:'Tech', price:129.99, image:'https://picsum.photos/200?4'),
];

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});
  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  @override
  void initState() { super.initState(); m.favoritesService.addListener(_r); m.cartService.addListener(_r); }
  @override
  void dispose() { m.favoritesService.removeListener(_r); m.cartService.removeListener(_r); super.dispose(); }
  void _r() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final favs = m.favoritesService.filter(_all);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.salmonLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.storefront, color: AppColors.primary)),
          const SizedBox(width: 8),
          RichText(text: const TextSpan(children: [
            TextSpan(text: 'Shop', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            TextSpan(text: 'Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ])),
          const Spacer(),
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)), child: const Icon(Icons.notifications_none, color: AppColors.textDark)),
          const SizedBox(width: 8),
          CircleAvatar(backgroundColor: AppColors.textDark, child: const Text('ML', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ])),
        Expanded(child: favs.isEmpty ? _empty() : _grid(favs)),
      ])),
    );
  }

  Widget _empty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 140, height: 140, decoration: BoxDecoration(color: AppColors.salmonLight, borderRadius: BorderRadius.circular(24)),
      child: const Icon(Icons.favorite_border, size: 64, color: AppColors.primary)),
    const SizedBox(height: 16),
    const Text('SHOPNOW', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    const Text('Tus favoritos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
    const SizedBox(height: 8),
    const Text('Aquí guardamos todo lo que te encantó\npara que vuelvas cuando quieras.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
    const SizedBox(height: 24),
    SizedBox(width: 200, child: ElevatedButton(onPressed: () {}, child: const Text('Explorar productos'))),
  ]));

  Widget _grid(List<Product> favs) => Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Mis favoritos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
    Text('${favs.length} productos guardados', style: const TextStyle(color: AppColors.textSecondary)),
    const SizedBox(height: 12),
    Expanded(child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: favs.length,
      itemBuilder: (ctx, i) {
        final p = favs[i];
        return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(p.image, height: 110, width: double.infinity, fit: BoxFit.cover)),
            Positioned(top: 6, right: 6, child: GestureDetector(onTap: () => m.favoritesService.toggle(p), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.favorite, color: AppColors.primary, size: 18)))),
          ]),
          const SizedBox(height: 6),
          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(p.category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Row(children: [
            Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.add_shopping_cart, size: 20), onPressed: () => m.cartService.add(p)),
          ]),
        ])));
      },
    )),
  ]));
}
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../main.dart' as m;

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});
  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  @override
  void initState() { super.initState(); m.cartService.addListener(_r); }
  @override
  void dispose() { m.cartService.removeListener(_r); super.dispose(); }
  void _r() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = m.cartService;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          // Header
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
          Expanded(child: c.isEmpty ? _empty() : _list(c)),
        ]),
      ),
    );
  }

  Widget _empty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 120, height: 120, decoration: BoxDecoration(color: AppColors.salmonLight, shape: BoxShape.circle),
      child: const Icon(Icons.shopping_bag_outlined, size: 56, color: AppColors.primary)),
    const SizedBox(height: 16),
    const Text('Tu carrito está vacío', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
    const SizedBox(height: 8),
    const Text('Descubre productos increíbles y agrégalos a tu carrito.', style: TextStyle(color: AppColors.textSecondary)),
    const SizedBox(height: 24),
    SizedBox(width: 200, child: ElevatedButton(onPressed: () {}, child: const Text('Seguir comprando'))),
  ]));

  Widget _list(dynamic c) => SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
    ...c.items.map((it) => Card(margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: Padding(padding: const EdgeInsets.all(8), child: Row(children: [
      ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(it.product.image, width: 70, height: 70, fit: BoxFit.cover)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(it.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(it.product.category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Text('\$${it.product.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        Text('Subtotal: \$${it.subtotal.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ])),
      Column(children: [
        IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => c.inc(it.product.id)),
        Text('${it.qty}', style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () => c.dec(it.product.id)),
        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => c.remove(it.product.id)),
      ]),
    ])))),
    const SizedBox(height: 8),
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(14)), child: Column(children: [
      _row('Subtotal', c.subtotal),
      _row('IVA (16%)', c.iva),
      _row('Envío', c.shipping),
      const Divider(),
      _row('Total', c.total, bold: true),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, child: const Text('Continuar con la compra'))),
    ])),
  ]));

  Widget _row(String l, double v, {bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(l, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
    Text('\$${v.toStringAsFixed(2)}', style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? AppColors.primary : null)),
  ]));
}
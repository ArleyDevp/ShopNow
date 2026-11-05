import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem({required this.product, this.qty = 1});
  double get subtotal => product.price * qty;
}

class CartService extends ChangeNotifier {
  final List<CartItem> items = [];
  double ivaRate = 0.16;
  double shipping = 49.0;

  void add(Product p) {
    final i = items.indexWhere((e) => e.product.id == p.id);
    if (i >= 0) { items[i].qty += 1; }
    else { items.add(CartItem(product: p)); }
    notifyListeners();
  }
  void inc(String id) { final i = items.indexWhere((e)=>e.product.id==id); if(i>=0) { items[i].qty++; notifyListeners(); } }
  void dec(String id) { final i = items.indexWhere((e)=>e.product.id==id); if(i>=0) { if(items[i].qty>1) { items[i].qty--; } else { items.removeAt(i); } notifyListeners(); } }
  void remove(String id) { items.removeWhere((e)=>e.product.id==id); notifyListeners(); }
  void clear(){ items.clear(); notifyListeners(); }

  int get count => items.fold(0, (s,e)=>s+e.qty);
  double get subtotal => items.fold(0.0, (s,e)=>s+e.subtotal);
  double get iva => subtotal * ivaRate;
  double get total => subtotal + iva + (items.isEmpty ? 0 : shipping);
  bool get isEmpty => items.isEmpty;
}
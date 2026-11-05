import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoritesService extends ChangeNotifier {
  final Set<String> _ids = {};
  bool isFav(String id) => _ids.contains(id);
  void toggle(Product p) {
    if (_ids.contains(p.id)) { _ids.remove(p.id); } else { _ids.add(p.id); }
    notifyListeners();
  }
  List<Product> filter(List<Product> all) => all.where((p)=>_ids.contains(p.id)).toList();
}
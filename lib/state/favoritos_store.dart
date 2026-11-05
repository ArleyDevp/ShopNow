import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado de favoritos. Persiste los nombres de los productos favoritos
/// en SharedPreferences (solo identificadores, la data viene de la lista
/// de productos de la tienda).
class FavoritosStore extends ChangeNotifier {
  FavoritosStore._();
  static final FavoritosStore instance = FavoritosStore._();

  static const _key = 'favoritos_nombres';

  final Set<String> _nombres = <String>{};

  Set<String> get nombres => _nombres;

  bool esFavorito(String nombre) => _nombres.contains(nombre);

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? <String>[];
    _nombres
      ..clear()
      ..addAll(lista);
    notifyListeners();
  }

  Future<void> alternar(String nombre) async {
    if (_nombres.contains(nombre)) {
      _nombres.remove(nombre);
    } else {
      _nombres.add(nombre);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _nombres.toList());
  }

  Future<void> limpiar() async {
    _nombres.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final favoritosStore = FavoritosStore.instance;

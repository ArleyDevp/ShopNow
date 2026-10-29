
import 'package:flutter/material.dart';

class Carrito extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _productos = {};

  List<Map<String, dynamic>> get productos =>
      _productos.values.toList();

  int get cantidadTotal => _productos.values.fold(
        0,
        (total, producto) => total + (producto['cantidad'] as int),
      );

  double get subtotal => _productos.values.fold(
        0.0,
        (total, producto) =>
            total +
            (producto['precio'] as num).toDouble() *
                (producto['cantidad'] as int),
      );

  double get iva => subtotal * 0.19;

  double get envio => _productos.isEmpty || subtotal >= 150000
      ? 0
      : 10000;

  double get total => subtotal + iva + envio;

  void agregar(Map<String, dynamic> producto, {int cantidad = 1}) {
    final nombre = producto['nombre'].toString();

    if (_productos.containsKey(nombre)) {
      _productos[nombre]!['cantidad'] =
          (_productos[nombre]!['cantidad'] as int) + cantidad;
    } else {
      _productos[nombre] = {
        ...producto,
        'cantidad': cantidad,
      };
    }

    notifyListeners();
  }

  void cambiarCantidad(String nombre, int cantidad) {
    if (!_productos.containsKey(nombre)) return;

    if (cantidad <= 0) {
      _productos.remove(nombre);
    } else {
      _productos[nombre]!['cantidad'] = cantidad;
    }

    notifyListeners();
  }

  void eliminar(String nombre) {
    _productos.remove(nombre);
    notifyListeners();
  }

  void vaciar() {
    _productos.clear();
    notifyListeners();
  }
}

final carrito = Carrito();

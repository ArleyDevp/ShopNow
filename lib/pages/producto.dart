
import 'package:flutter/material.dart';
import '../carrito.dart';

class ProductoPage extends StatefulWidget {
  final Map<String, dynamic> producto;

  const ProductoPage({super.key, required this.producto});

  @override
  State<ProductoPage> createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  int cantidad = 1;

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

  void _agregarAlCarrito() {
    carrito.agregar(widget.producto, cantidad: cantidad);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Producto agregado al carrito'),
        action: SnackBarAction(
          label: 'Ver carrito',
          onPressed: () {
            Navigator.pushNamed(context, '/compras');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del producto'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    producto['icono'] as IconData,
                    size: 120,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  producto['categoria'].toString(),
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  producto['nombre'].toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  _precio(producto['precio'] as num),
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  producto['descripcion'].toString(),
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 28),
                Text(
                  'Cantidad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: cantidad > 1
                          ? () => setState(() => cantidad--)
                          : null,
                      icon: Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$cantidad',
                      style: TextStyle(fontSize: 20),
                    ),
                    IconButton(
                      onPressed: () => setState(() => cantidad++),
                      icon: Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _agregarAlCarrito,
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Agregar al carrito'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

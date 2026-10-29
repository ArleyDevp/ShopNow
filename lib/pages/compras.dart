
import 'package:flutter/material.dart';
import '../carrito.dart';

class ComprasPage extends StatelessWidget {
  const ComprasPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi carrito'),
      ),
      body: AnimatedBuilder(
        animation: carrito,
        builder: (context, child) {
          final productos = carrito.productos;

          if (productos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tu carrito está vacío',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Volver a la tienda'),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 850),
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  ...productos.map((producto) {
                    final nombre = producto['nombre'].toString();
                    final cantidad = producto['cantidad'] as int;
                    final precio = producto['precio'] as num;

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.indigo.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                producto['icono'] as IconData,
                                color: Colors.indigo,
                                size: 30,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nombre,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(_precio(precio)),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          carrito.cambiarCantidad(
                                            nombre,
                                            cantidad - 1,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                      ),
                                      Text('$cantidad'),
                                      IconButton(
                                        onPressed: () {
                                          carrito.cambiarCantidad(
                                            nombre,
                                            cantidad + 1,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.add_circle_outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Eliminar producto',
                              onPressed: () => carrito.eliminar(nombre),
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 20),
                  _fila('Subtotal', carrito.subtotal),
                  _fila('IVA (19 %)', carrito.iva),
                  _fila('Envío', carrito.envio),
                  Divider(height: 30),
                  _fila(
                    'TOTAL',
                    carrito.total,
                    destacado: true,
                  ),
                  SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: Text('Confirmar compra'),
                            content: Text(
                              'El total de tu compra es '
                              '${_precio(carrito.total)}. '
                              '¿Deseas simular el pedido?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  carrito.vaciar();
                                  Navigator.pop(dialogContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Compra de demostración completada',
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Confirmar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('Finalizar compra'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _fila(
    String titulo,
    num valor, {
    bool destacado = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: destacado ? 20 : 16,
              fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _precio(valor),
            style: TextStyle(
              fontSize: destacado ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: destacado ? Colors.indigo : null,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/widgets/primary_button.dart';
import '../carrito.dart';

class ComprasPage extends StatelessWidget {
  const ComprasPage({super.key, this.onSeguir});

  final VoidCallback? onSeguir;

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.shopping_bag_rounded, color: AppColors.coral, size: 20),
            SizedBox(width: 8),
            Text('Mi carrito'),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: carrito,
        builder: (context, child) {
          final productos = carrito.productos;

          if (productos.isEmpty) {
            return _EmptyCarrito(
              onSeguir: onSeguir ?? () {},
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '${carrito.cantidadTotal} productos listos',
                style: AppText.headline,
              ),
              const SizedBox(height: 4),
              Text(
                'Revisa y confirma tu pedido.',
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: 16),
              ...productos.map((producto) {
                final nombre = producto['nombre'].toString();
                final cantidad = producto['cantidad'] as int;
                final precio = producto['precio'] as num;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.coralPale,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            producto['icono'] as IconData,
                            color: AppColors.coral,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _precio(precio),
                                style: const TextStyle(
                                  color: AppColors.coral,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove_rounded,
                                    onPressed: () => carrito.cambiarCantidad(
                                      nombre,
                                      cantidad - 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Text(
                                      '$cantidad',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add_rounded,
                                    onPressed: () => carrito.cambiarCantidad(
                                      nombre,
                                      cantidad + 1,
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
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _Fila('Subtotal', carrito.subtotal, _precio),
                    _Fila('IVA (19 %)', carrito.iva, _precio),
                    _Fila('Envío', carrito.envio, _precio),
                    const Divider(height: 24),
                    _Fila(
                      'TOTAL',
                      carrito.total,
                      _precio,
                      destacado: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Finalizar compra',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text('Confirmar compra'),
                        content: Text(
                          'El total de tu compra es '
                          '${_precio(carrito.total)}. '
                          '¿Deseas simular el pedido?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () {
                              carrito.vaciar();
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Compra de demostración completada',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            child: const Text('Confirmar'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: onSeguir,
                  child: const Text('Seguir comprando'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.text),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila(
    this.titulo,
    this.valor,
    this.precio, {
    this.destacado = false,
  });

  final String titulo;
  final num valor;
  final String Function(num) precio;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: destacado ? 18 : 15,
              fontWeight: destacado ? FontWeight.w800 : FontWeight.w500,
              color: destacado ? AppColors.text : AppColors.textMuted,
            ),
          ),
          Text(
            precio(valor),
            style: TextStyle(
              fontSize: destacado ? 18 : 15,
              fontWeight: FontWeight.w800,
              color: destacado ? AppColors.coral : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCarrito extends StatelessWidget {
  const _EmptyCarrito({required this.onSeguir});

  final VoidCallback onSeguir;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.creamDeep,
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.coral,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tu carrito',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no has agregado productos.\nExplora la tienda y empieza a comprar.',
              textAlign: TextAlign.center,
              style: AppText.bodyMuted,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 240,
              child: PrimaryButton(
                label: 'Seguir comprando',
                onPressed: onSeguir,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

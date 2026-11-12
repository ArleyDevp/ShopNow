import 'package:flutter/material.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/widgets/primary_button.dart';
import '../carrito.dart';
import '../state/favoritos_store.dart';

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

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Producto agregado al carrito'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'Ver carrito',
          textColor: Colors.white,
          onPressed: () {
            messenger.clearSnackBars();
            Navigator.of(context).pushNamed(AppRoutes.compras);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final nombre = producto['nombre'].toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Detalle del producto'),
        actions: [
          AnimatedBuilder(
            animation: favoritosStore,
            builder: (context, _) {
              final esFav = favoritosStore.esFavorito(nombre);
              return IconButton(
                tooltip: 'Favorito',
                onPressed: () => favoritosStore.alternar(nombre),
                icon: Icon(
                  esFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: esFav ? AppColors.coral : AppColors.text,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.coralPale, AppColors.creamDeep],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    producto['icono'] as IconData,
                    size: 140,
                    color: AppColors.coral,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  producto['categoria'].toString(),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _precio(producto['precio'] as num),
                  style: const TextStyle(
                    fontSize: 26,
                    color: AppColors.coral,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                if ((producto['descripcion']?.toString() ?? '').isNotEmpty)
                  Text(
                    producto['descripcion'].toString(),
                    style: AppText.body,
                  ),
                const SizedBox(height: 24),
                Text(
                  'Cantidad',
                  style: AppText.title,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove_rounded,
                      enabled: cantidad > 1,
                      onPressed: () => setState(() => cantidad--),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        '$cantidad',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add_rounded,
                      onPressed: () => setState(() => cantidad++),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Agregar al carrito',
                  icon: Icons.shopping_cart_rounded,
                  onPressed: _agregarAlCarrito,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onPressed,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? AppColors.background : AppColors.border,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.text : AppColors.textMuted,
        ),
      ),
    );
  }
}

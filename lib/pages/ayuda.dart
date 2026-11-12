import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';

class AyudaPage extends StatelessWidget {
  const AyudaPage({super.key});

  static const _faqs = [
    ('¿Como hago un pedido?', 'Agrega productos al carrito, revisa tu pedido en la seccion Carrito y confirma la compra.'),
    ('¿Puedo guardar productos para despues?', 'Si. Toca el corazon en cualquier producto para guardarlo en Favoritos.'),
    ('¿Cuanto cuesta el envio?', 'El envio es gratis en compras superiores a \$150.000; de lo contrario cuesta \$10.000.'),
    ('¿Como cambio mis datos?', 'Ve a Perfil, toca el lapiz y podras editar tu nombre. Se guarda en tu cuenta.'),
    ('¿Olvide mi contrasena?', 'En la pantalla de inicio de sesion usa la opcion de recuperacion para recibir ayuda.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Ayuda'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Preguntas frecuentes', style: AppText.title),
          const SizedBox(height: 12),
          ..._faqs.map((faq) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: ExpansionTile(
                shape: const Border(),
                title: Text(
                  faq.$1,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                children: [Text(faq.$2, style: AppText.body)],
              ),
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Necesitas mas ayuda?', style: AppText.title),
                const SizedBox(height: 8),
                Text(
                  'Escribenos y te respondemos lo antes posible.',
                  style: AppText.bodyMuted,
                ),
                const SizedBox(height: 14),
                const Text('Escrbenos a:'),
                const SelectableText(
                  'soporte@shopnow.com',
                  style: TextStyle(
                    color: AppColors.coral,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

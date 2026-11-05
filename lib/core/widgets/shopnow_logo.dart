import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Logo oficial de ShopNow (archivo en assets/images/logo_shopnow.png).
/// Se usa en TODAS las pantallas para mantener la marca.
class ShopNowLogo extends StatelessWidget {
  const ShopNowLogo({
    super.key,
    this.size = 44,
    this.showText = false,
    this.dark = false,
  });

  final double size;
  final bool showText;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22),
          child: Image.asset(
            'assets/images/logo_shopnow.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.25),
          Text(
            'ShopNow',
            style: TextStyle(
              fontSize: size * 0.52,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ],
    );
  }
}

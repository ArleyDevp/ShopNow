import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos de texto reutilizables de ShopNow.
class AppText {
  AppText._();

  static const display = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    height: 1.05,
    letterSpacing: -1,
  );

  static const headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: 1.4,
  );

  static const bodyMuted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static const small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static const label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.2,
  );
}

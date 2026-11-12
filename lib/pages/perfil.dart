import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/widgets/shopnow_logo.dart';
import '../services/auth_service.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  void _abrir(String ruta) {
    Navigator.pushNamed(context, ruta).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final nombre = user?['name']?.toString() ?? 'Usuario';
    final email = user?['email']?.toString() ?? '';
    final iniciales = nombre.isNotEmpty
        ? nombre.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join()
        : 'U';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.person_rounded, color: AppColors.coral, size: 20),
            SizedBox(width: 8),
            Text('Mi perfil'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.coral,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    iniciales.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: AppText.title),
                      const SizedBox(height: 2),
                      Text(email, style: AppText.small),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lime,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Cliente premium',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _abrir('/editar-perfil'),
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Mi cuenta', style: AppText.title),
          const SizedBox(height: 10),
          _MenuItem(
            icon: Icons.receipt_long_outlined,
            label: 'Mis compras',
            onTap: () => _abrir(AppRoutes.compras),
          ),
          _MenuItem(
            icon: Icons.location_on_outlined,
            label: 'Direcciones',
            onTap: () => _abrir('/direcciones'),
          ),
          _MenuItem(
            icon: Icons.credit_card_outlined,
            label: 'Métodos de pago',
            onTap: () => _abrir('/metodos-pago'),
          ),
          _MenuItem(
            icon: Icons.help_outline_rounded,
            label: 'Ayuda',
            onTap: () => _abrir('/ayuda'),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () async {
                await AuthService.signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                foregroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(child: const ShopNowLogo(size: 32, showText: true)),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.coralPale,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.coral, size: 20),
          ),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

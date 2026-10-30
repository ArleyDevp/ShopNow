import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});
  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  @override
  Widget build(BuildContext context) {
    final u = AuthService.currentUser;
    final name = u?.userMetadata?['full_name'] ?? 'Usuario';
    final email = u?.email ?? '';
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2 ? '${parts[0][0]}${parts[1][0]}'.toUpperCase() : (name.isNotEmpty ? name[0].toUpperCase() : 'U');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Header
            Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.salmonLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.storefront, color: AppColors.primary)),
              const SizedBox(width: 8),
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'Shop', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                TextSpan(text: 'Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ])),
              const Spacer(),
              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)), child: const Icon(Icons.notifications_none, color: AppColors.textDark)),
              const SizedBox(width: 8),
              CircleAvatar(backgroundColor: AppColors.textDark, child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 32),
            // Avatar grande
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.salmonLight, width: 3)),
              child: CircleAvatar(radius: 48, backgroundColor: AppColors.textDark, child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 12),
            const Text('MI PERFIL', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 2)),
            const SizedBox(height: 4),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 24),
            // Tarjeta opciones
            Container(decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(children: [
                _opt(Icons.shopping_bag_outlined, 'Mis compras', () => _snack(context, 'Todavía no tienes compras')),
                _div(),
                _opt(Icons.location_on_outlined, 'Direcciones', () => _snack(context, 'Sin direcciones guardadas')),
                _div(),
                _opt(Icons.credit_card_outlined, 'Métodos de pago', () => _snack(context, 'Todavía no tienes métodos de pago configurados')),
                _div(),
                _opt(Icons.help_outline, 'Ayuda', () => _snack(context, 'Centro de ayuda')),
              ])),
            const SizedBox(height: 24),
            TextButton(onPressed: () async {
              final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                title: const Text('Cerrar sesión'),
                content: const Text('¿Deseas cerrar sesión?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cerrar sesión', style: TextStyle(color: AppColors.primary))),
                ],
              ));
              if (ok == true) {
                await AuthService.signOut();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              }
            }, child: const Text('Cerrar sesión', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
          ]),
        ),
      ),
    );
  }

  Widget _opt(IconData i, String l, VoidCallback onTap) => ListTile(leading: Icon(i, color: AppColors.primary), title: Text(l, style: const TextStyle(color: AppColors.textDark)), trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary), onTap: onTap);
  Widget _div() => const Divider(height: 1, color: AppColors.border);
  void _snack(BuildContext ctx, String m) => ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(m)));
}
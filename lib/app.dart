import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'pages/login.dart';
import 'pages/registro.dart';
import 'pages/recuperar_password.dart';
import 'pages/main_shell.dart';
import 'pages/producto.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopNow',
      theme: AppTheme.light(),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.registro: (_) => const RegistroPage(),
        AppRoutes.recuperarPassword: (_) => const RecuperarPasswordPage(),
        AppRoutes.shell: (_) => const MainShell(),
        AppRoutes.favoritos: (_) => const MainShell(initialIndex: 1),
        AppRoutes.compras: (_) => const MainShell(initialIndex: 2),
        AppRoutes.perfil: (_) => const MainShell(initialIndex: 3),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.producto) {
          final producto = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ProductoPage(producto: producto),
          );
        }
        return null;
      },
    );
  }
}

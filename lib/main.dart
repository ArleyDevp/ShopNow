 import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'core/routes/app_routes.dart';
import 'pages/ayuda.dart';
import 'pages/direcciones.dart';
import 'pages/editar_perfil.dart';
import 'pages/metodos_pago.dart';
import 'pages/producto.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/favorites_service.dart';
import 'pages/login.dart';
import 'pages/registro.dart';
import 'pages/recuperar_password.dart';
import 'pages/main_shell.dart';
import 'pages/compras.dart';

final cartService = CartService();
final favoritesService = FavoritesService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  await _iniciarBackend();
  runApp(const MainApp());
}

Future<void> _iniciarBackend() async {
  if (!Platform.isWindows) return;

  try {
    final ping = await http
        .get(Uri.parse('http://localhost:3000/'))
        .timeout(const Duration(seconds: 2));
    if (ping.statusCode == 200) return;
  } catch (_) {
    // backend no responde, se intenta arrancar
  }

  var dir = Directory.current;
  for (var i = 0; i < 3; i++) {
    if (File('${dir.path}/backend/index.js').existsSync()) {
      try {
        await Process.start(
          'node',
          ['index.js'],
          workingDirectory: '${dir.path}/backend',
          mode: ProcessStartMode.detached,
        );
        await Future<void>.delayed(const Duration(seconds: 2));
      } catch (_) {}
      return;
    }
    dir = dir.parent;
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopNow',
      theme: AppTheme.light(),
      initialRoute: AuthService.isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/registro': (context) => const RegistroPage(),
        '/recuperar-password': (context) => const RecuperarPasswordPage(),
        '/home': (context) => const MainShell(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.producto:
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => ProductoPage(producto: args ?? {}),
              settings: settings,
            );
          case AppRoutes.compras:
            return MaterialPageRoute(
              builder: (_) => const ComprasPage(),
              settings: settings,
            );
          case '/direcciones':
            return MaterialPageRoute(
              builder: (_) => const DireccionesPage(),
              settings: settings,
            );
          case '/metodos-pago':
            return MaterialPageRoute(
              builder: (_) => const MetodosPagoPage(),
              settings: settings,
            );
          case '/ayuda':
            return MaterialPageRoute(
              builder: (_) => const AyudaPage(),
              settings: settings,
            );
          case '/editar-perfil':
            return MaterialPageRoute(
              builder: (_) => const EditarPerfilPage(),
              settings: settings,
            );
        }
        return null;
      },
    );
  }
}

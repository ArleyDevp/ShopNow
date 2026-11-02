import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/favorites_service.dart';
import 'pages/login.dart';
import 'pages/registro.dart';
import 'pages/recuperar_password.dart';
import 'pages/main_shell.dart';

final cartService = CartService();
final favoritesService = FavoritesService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await AuthService.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopNow',
      theme: AppTheme.light(),
      initialRoute: AuthService.currentUser == null ? '/login' : '/home',
      routes: {
        '/login': (context) => const LoginPage(),
        '/registro': (context) => const RegistroPage(),
        '/recuperar-password': (context) => const RecuperarPasswordPage(),
        '/home': (context) => const MainShell(),
      },
    );
  }
}
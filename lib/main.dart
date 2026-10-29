
import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/registro.dart';
import 'pages/home.dart';
import 'pages/compras.dart';
import 'pages/recuperar_password.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Tienda',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: Color(0xFFF5F6FA),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/registro': (context) => RegistroPage(),
        '/home': (context) => CatalogPage(),
        '/compras': (context) => ComprasPage(),
        '/recuperar-password': (context) => RecuperarPasswordPage(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'app.dart';
import 'state/favoritos_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await favoritosStore.cargar();
  runApp(const MainApp());
}

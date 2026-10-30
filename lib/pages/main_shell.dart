import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../main.dart' as m;
import 'home.dart';
import 'favoritos.dart';
import 'carrito.dart';
import 'perfil.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _pages = const [HomePage(), FavoritosPage(), CarritoPage(), PerfilPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i)=>setState(()=>_index=i),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Stack(children: [
            const Icon(Icons.shopping_cart_outlined),
            if (m.cartService.count>0) Positioned(right:0,top:0,child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: Text('${m.cartService.count}', style: const TextStyle(color: Colors.white, fontSize: 9)))),
          ]), activeIcon: const Icon(Icons.shopping_cart), label: 'Carrito'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
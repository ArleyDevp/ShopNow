
import 'package:flutter/material.dart';
import '../carrito.dart';
import 'producto.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _busqueda = TextEditingController();
  String _categoria = 'Todos';

  final List<Map<String, dynamic>> _productos = [
    {
      'nombre': 'Audífonos Bluetooth',
      'precio': 89900,
      'categoria': 'Tecnología',
      'icono': Icons.headphones,
      'descripcion': 'Audífonos inalámbricos para escuchar música.',
    },
    {
      'nombre': 'Reloj inteligente',
      'precio': 129900,
      'categoria': 'Tecnología',
      'icono': Icons.watch,
      'descripcion': 'Reloj inteligente para tus actividades diarias.',
    },
    {
      'nombre': 'Mochila urbana',
      'precio': 74900,
      'categoria': 'Accesorios',
      'icono': Icons.backpack,
      'descripcion': 'Mochila práctica para estudiar y viajar.',
    },
    {
      'nombre': 'Gorra deportiva',
      'precio': 39900,
      'categoria': 'Ropa',
      'icono': Icons.checkroom,
      'descripcion': 'Gorra cómoda para actividades al aire libre.',
    },
    {
      'nombre': 'Camiseta casual',
      'precio': 49900,
      'categoria': 'Ropa',
      'icono': Icons.dry_cleaning,
      'descripcion': 'Camiseta para usar todos los días.',
    },
    {
      'nombre': 'Gafas de sol',
      'precio': 59900,
      'categoria': 'Accesorios',
      'icono': Icons.wb_sunny_outlined,
      'descripcion': 'Gafas de sol con diseño moderno.',
    },
  ];

  String _precio(num valor) {
    final texto = valor.round().toString();
    final resultado = StringBuffer();

    for (int i = 0; i < texto.length; i++) {
      if (i > 0 && (texto.length - i) % 3 == 0) {
        resultado.write('.');
      }
      resultado.write(texto[i]);
    }

    return '\$$resultado';
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categorias = [
      'Todos',
      'Tecnología',
      'Ropa',
      'Accesorios',
    ];

    final filtrados = _productos.where((producto) {
      final nombre = producto['nombre'].toString().toLowerCase();
      final texto = _busqueda.text.toLowerCase().trim();

      return nombre.contains(texto) &&
          (_categoria == 'Todos' ||
              producto['categoria'] == _categoria);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Tienda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          AnimatedBuilder(
            animation: carrito,
            builder: (context, child) {
              return IconButton(
                tooltip: 'Carrito',
                onPressed: () {
                  Navigator.pushNamed(context, '/compras');
                },
                icon: Badge(
                  label: Text('${carrito.cantidadTotal}'),
                  isLabelVisible: carrito.cantidadTotal > 0,
                  child: Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
          SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descubre algo nuevo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Encuentra tus productos favoritos.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              TextField(
                controller: _busqueda,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: categorias.map((categoria) {
                  return ChoiceChip(
                    label: Text(categoria),
                    selected: _categoria == categoria,
                    onSelected: (_) {
                      setState(() => _categoria = categoria);
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 24),
              Text(
                'Productos (${filtrados.length})',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final ancho = constraints.maxWidth;
                  final columnas = ancho >= 800
                      ? 4
                      : ancho >= 520
                          ? 3
                          : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filtrados.length,
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnas,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final producto = filtrados[index];

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductoPage(producto: producto),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      producto['icono'] as IconData,
                                      size: 54,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  producto['categoria'].toString(),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  producto['nombre'].toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  _precio(producto['precio'] as num),
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              if (filtrados.isEmpty)
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Text('No se encontraron productos.'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String image;
  final bool featured;
  const Product({required this.id, required this.name, required this.category, required this.price, required this.image, this.featured = false});
}
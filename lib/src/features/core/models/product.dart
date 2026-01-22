// Stores the model for products

class Product {
  String name;
  String category;
  String image;
  String description;
  double price;
  int quantity;

  Product({
    required this.name,
    required this.category,
    required this.image,
    required this.description,
    required this.price,
    required this.quantity,
  });
}

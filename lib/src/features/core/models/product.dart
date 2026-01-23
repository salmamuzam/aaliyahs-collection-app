
class Product {
  final int? id;
  final String name;
  final String description;
  final String price; // We'll keep it as String for display, matching API
  final List<String> images;
  final int? categoryId;
  final String categoryName;
  int quantity;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    this.categoryId,
    required this.categoryName,
    this.quantity = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> translatedImages = [];
    if (json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        String url = img.toString();
        // IP Translation for 192.168.1.11
        url = url.replaceAll('localhost', '192.168.1.11');
        url = url.replaceAll('127.0.0.1', '192.168.1.11');
        url = url.replaceAll('10.0.2.2', '192.168.1.11');
        translatedImages.add(url);
      }
    } else if (json['image'] != null) {
      // Handle cases where 'image' (singular) might be passed (e.g. from old repo)
      String url = json['image'].toString();
      url = url.replaceAll('localhost', '192.168.1.11');
      url = url.replaceAll('127.0.0.1', '192.168.1.11');
      url = url.replaceAll('10.0.2.2', '192.168.1.11');
      translatedImages.add(url);
    }

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0',
      images: translatedImages,
      categoryId: json['category'] != null && json['category'] is Map 
          ? json['category']['id'] 
          : null,
      categoryName: json['category'] != null 
          ? (json['category'] is Map ? json['category']['name'] : json['category'].toString())
          : 'Uncategorized',
      quantity: json['quantity'] ?? 0,
    );
  }

  // To maintain compatibility with existing code
  String get image => images.isNotEmpty ? images[0] : '';
  String get category => categoryName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          (id != null && other.id != null ? id == other.id : name == other.name);

  @override
  int get hashCode => id != null ? id.hashCode : name.hashCode;
}

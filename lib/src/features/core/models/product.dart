
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    String? apiBase = dotenv.env['API_BASE_URL'];
    String targetHost = '10.0.2.2'; // Default Emulator
    if (apiBase != null) {
      try {
        Uri uri = Uri.parse(apiBase);
        targetHost = uri.host;
      } catch (_) {}
    }

    List<String> translatedImages = [];
    if (json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        String url = img.toString();
        // Dynamic Translation based on Config
        url = url.replaceAll('localhost', targetHost);
        url = url.replaceAll('127.0.0.1', targetHost);
        if (targetHost != '10.0.2.2') {
           // If we are on physical device, we might need to replace emulator IP too
           url = url.replaceAll('10.0.2.2', targetHost); 
        }
        translatedImages.add(url);
      }
    } else if (json['image'] != null) {
      String url = json['image'].toString();
      url = url.replaceAll('localhost', targetHost);
      url = url.replaceAll('127.0.0.1', targetHost);
      if (targetHost != '10.0.2.2') {
          url = url.replaceAll('10.0.2.2', targetHost); 
      }
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

  /// Returns the price as a double, cleaning any non-numeric characters.
  double get priceDouble {
    final String cleanPrice = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          (id != null && other.id != null ? id == other.id : name == other.name);

  @override
  int get hashCode => id != null ? id.hashCode : name.hashCode;
}

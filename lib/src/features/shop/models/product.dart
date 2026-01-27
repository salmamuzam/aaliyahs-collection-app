
import 'package:aaliyahs_collection_estore/src/constants/api_strings.dart';
import 'package:aaliyahs_collection_estore/src/utils/formatters/text_formatter.dart';

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
    List<String> validImages = [];
    
    // Helper to process a single URL
    String processUrl(String url) {
       if (url.isEmpty) return '';
       
       // 1. Handle complete URLs pointing to localhost/emulator IPs
       if (url.startsWith('http')) {
           if (url.contains('localhost') || url.contains('127.0.0.1') || url.contains('10.0.2.2')) {
              final Uri uri = Uri.parse(url);
              return "$rootBaseURL${uri.path}";
           }
           return url;
       }

       // 2. Normalize path
       String path = url;
       if (path.startsWith('/')) {
         path = path.substring(1);
       }
       
       // 3. Ensure storage prefix exists
       if (!path.startsWith('storage/')) {
         path = 'storage/$path';
       }

       // 4. Return full URL
       return "$rootBaseURL$path";
    }

    if (json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        validImages.add(processUrl(img.toString()));
      }
    } else if (json['image'] != null) {
      validImages.add(processUrl(json['image'].toString()));
    }

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0',
      images: validImages,
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
  String get category => TFormatter.toSentenceCase(categoryName);
  String get displayName => TFormatter.toSentenceCase(name);

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


import 'package:aaliyahs_collection_estore/utils/constants/api_strings.dart';
import 'package:aaliyahs_collection_estore/utils/formatters/text_formatter.dart';

class ProductModel {
  final int? id;
  final String name;
  final String description;
  final String price; 
  final List<String> images;
  final int? categoryId;
  final String categoryName;
  int quantity;

  ProductModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    this.categoryId,
    required this.categoryName,
    this.quantity = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String> validImages = [];
    

    String processUrl(String url) {
       if (url.isEmpty) return '';
       
     
       if (url.startsWith('assets/')) {
          return url; 
       }
       

       if (url.startsWith('http')) {
           if (url.contains('localhost') || url.contains('127.0.0.1') || url.contains('10.0.2.2')) {
              final Uri uri = Uri.parse(url);
              return '$rootBaseURL${uri.path}';
           }
           return url;
       }

   
       String path = url;
       if (path.startsWith('/')) {
         path = path.substring(1);
       }
       
   
       if (!path.startsWith('storage/')) {
         path = 'storage/$path';
       }

     
       return '$rootBaseURL$path';
    }

    if (json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        validImages.add(processUrl(img.toString()));
      }
    } else if (json['image'] != null) {
      validImages.add(processUrl(json['image'].toString()));
    }

    return ProductModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0',
      images: validImages,
      categoryId: json['category_id'] ?? json['CategoryModel_id'] ?? (json['CategoryModel'] != null && json['CategoryModel'] is Map 
          ? json['CategoryModel']['id'] 
          : null),
      categoryName: json['CategoryModel'] != null 
          ? (json['CategoryModel'] is Map ? json['CategoryModel']['name'] : json['CategoryModel'].toString())
          : 'Uncategorized',
      quantity: json['quantity'] ?? 0,
    );
  }

 
  String get image => images.isNotEmpty ? images[0] : '';
  String get categoryNameFormatted => TFormatter.toSentenceCase(categoryName);
  String get displayName => TFormatter.toSentenceCase(name);

  /// Returns the price as a double
  double get priceDouble {
    final String cleanPrice = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'category_id': categoryId,
      'CategoryModel': {'name': categoryName, 'id': categoryId},
      'quantity': quantity,
    };
  }
}

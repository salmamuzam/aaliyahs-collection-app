
// This model stores information about a product that has been added to cart



import 'package:aaliyahs_collection_estore/utils/formatters/text_formatter.dart';

class CartItem {
  final int id;            
  final String name;        
  final double price;       
  final String image;        
  int quantity;              
  
  // Optional fields that may be needed for checkout
  final String? categoryName;
  final String? description;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
    this.categoryName,
    this.description,
  });


  
  // Display name (formatted in title case)
  String get displayName => TFormatter.toSentenceCase(name);
  
  // Price as double (for calculations)
  double get priceDouble => price;
  
  // Total price for this item (price × quantity)
  double get totalPrice => price * quantity;

  // ============================================================================
  // JSON CONVERSION - For Database Storage
  // ============================================================================
  
  // Convert CartItem to JSON Map (for saving to database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'quantity': quantity,
      'categoryName': categoryName,
      'description': description,
    };
  }

  // Create CartItem from JSON Map (for loading from database)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      quantity: json['quantity'] as int? ?? 1,
      categoryName: json['categoryName'] as String?,
      description: json['description'] as String?,
    );
  }


  // Useful for updating quantity without modifying original
  CartItem copyWith({
    int? id,
    String? name,
    double? price,
    String? image,
    int? quantity,
    String? categoryName,
    String? description,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
    );
  }
}

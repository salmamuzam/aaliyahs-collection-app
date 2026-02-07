// ============================================================================
// CART ITEM MODEL - Represents a Product in Shopping Cart
// ============================================================================
// This model stores information about a product that has been added to cart
// It's simpler than ProductModel because we only need essential info
//
// Stored in: SQLite database (via DataRepository)
// Used by: CartController
// ============================================================================

class CartItem {
  final int id;              // Product ID (matches ProductModel.id)
  final String name;         // Product name for display
  final double price;        // Price per unit (as number, not string)
  final String image;        // Product image URL
  int quantity;              // How many of this item (can change)
  
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

  // ============================================================================
  // GETTERS - Convenience Properties
  // ============================================================================
  
  // Display name (alias for name)
  String get displayName => name;
  
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

  // ============================================================================
  // COPY WITH - Create Modified Copy
  // ============================================================================
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

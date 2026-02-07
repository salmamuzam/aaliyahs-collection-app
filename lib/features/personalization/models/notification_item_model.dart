class NotificationOrderItem {
  final String categoryName;
  final String productImage;
  final int quantity;
  final double price;

  NotificationOrderItem({
    required this.categoryName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'categoryName': categoryName,
    'productImage': productImage,
    'quantity': quantity,
    'price': price,
  };

  factory NotificationOrderItem.fromJson(Map<String, dynamic> json) => NotificationOrderItem(
    categoryName: json['categoryName'] ?? '',
    productImage: json['productImage'] ?? json['ProductModelImage'] ?? '',
    quantity: json['quantity'] ?? 1,
    price: (json['price'] ?? 0.0).toDouble(),
  );
}

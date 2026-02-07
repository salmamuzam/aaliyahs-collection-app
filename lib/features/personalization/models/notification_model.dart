import 'notification_item_model.dart';

class NotificationModel {
  final String? id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  
  final String? orderId;
  final double? totalAmount;
  final String? paymentMethod;
  final List<NotificationOrderItem>? orderItems;

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.orderId,
    this.totalAmount,
    this.paymentMethod,
    this.orderItems,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'orderId': orderId,
    'totalAmount': totalAmount,
    'paymentMethod': paymentMethod,
    'orderItems': orderItems?.map((x) => x.toJson()).toList(),
  };

  factory NotificationModel.fromJson(Map<String, dynamic> json, [String? id]) => NotificationModel(
    id: id,
    title: json['title'] ?? '',
    body: json['body'] ?? '',
    timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    isRead: json['isRead'] ?? false,
    orderId: json['orderId'],
    totalAmount: (json['totalAmount'] as num?)?.toDouble(),
    paymentMethod: json['paymentMethod'],
    orderItems: json['orderItems'] != null 
      ? (json['orderItems'] as List).map((i) => NotificationOrderItem.fromJson(Map<String, dynamic>.from(i))).toList() 
      : null,
  );
}

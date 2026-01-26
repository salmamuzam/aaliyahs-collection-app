
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationOrderItem {
  final String productName;
  final String productImage;
  final int quantity;
  final double price;

  NotificationOrderItem({
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'productImage': productImage,
    'quantity': quantity,
    'price': price,
  };

  factory NotificationOrderItem.fromJson(Map<String, dynamic> json) => NotificationOrderItem(
    productName: json['productName'] ?? '',
    productImage: json['productImage'] ?? '',
    quantity: json['quantity'] ?? 1,
    price: (json['price'] ?? 0.0).toDouble(),
  );
}

/// Model representing a single notification event.
class NotificationModel {
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  
  // Extended Details for Orders
  final String? orderId;
  final double? totalAmount;
  final String? paymentMethod;
  final List<NotificationOrderItem>? orderItems;

  NotificationModel({
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

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    title: json['title'] ?? '',
    body: json['body'] ?? '',
    timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    isRead: json['isRead'] ?? false,
    orderId: json['orderId'],
    totalAmount: (json['totalAmount'] as num?)?.toDouble(),
    paymentMethod: json['paymentMethod'],
    orderItems: json['orderItems'] != null 
      ? (json['orderItems'] as List).map((i) => NotificationOrderItem.fromJson(i)).toList() 
      : null,
  );
}

/// Manages the list of application notifications received during the session and persists them.
class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  static const String _storageKey = 'cached_notifications_v2'; // Changed key to avoid conflict with old data

  NotificationProvider() {
    _loadFromPrefs();
  }

  /// Returns an unmodifiable list of current notifications.
  List<NotificationModel> get notifications => List<NotificationModel>.unmodifiable(_notifications);
  
  /// Total count of unread notifications.
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Loads notifications from SharedPreferences.
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encodedData = prefs.getString(_storageKey);
      if (encodedData != null) {
        final List<dynamic> decodedData = jsonDecode(encodedData);
        _notifications = decodedData.map((item) => NotificationModel.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    }
  }

  /// Saves notifications to SharedPreferences.
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(_notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, encodedData);
    } catch (e) {
      debugPrint("Error saving notifications: $e");
    }
  }

  /// Adds a new notification to the top of the list.
  void addNotification(
    String title, 
    String body, {
    String? orderId,
    double? totalAmount,
    String? paymentMethod,
    List<NotificationOrderItem>? orderItems,
  }) {
    _notifications.insert(0, NotificationModel(
      title: title,
      body: body,
      timestamp: DateTime.now(),
      orderId: orderId,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      orderItems: orderItems,
    ));
    _saveToPrefs();
    notifyListeners();
  }

  /// Removes a notification from the list.
  void removeNotification(NotificationModel notification) {
    _notifications.remove(notification);
    _saveToPrefs();
    notifyListeners();
  }

  /// Marks all notifications as read.
  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    _saveToPrefs();
    notifyListeners();
  }

  /// Removes all notifications from the list.
  void clearNotifications() {
    _notifications.clear();
    _saveToPrefs();
    notifyListeners();
  }
}

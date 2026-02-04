import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aaliyahs_collection_estore/data/services/notification_service.dart';

// ============================================================================
// NOTIFICATION ORDER ITEM - Product Info in Notification
// ============================================================================
// This model represents a product in an order notification
// Used to show order details in the notification screen
// ============================================================================

class NotificationOrderItem {
  final String categoryName;   // Product category (e.g., "Abayas")
  final String productImage;   // Image URL
  final int quantity;          // How many items ordered
  final double price;          // Price per item

  NotificationOrderItem({
    required this.categoryName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  // Convert to JSON for saving to Firebase
  Map<String, dynamic> toJson() => {
    'categoryName': categoryName,
    'productImage': productImage,
    'quantity': quantity,
    'price': price,
  };

  // Create from JSON when loading from Firebase
  factory NotificationOrderItem.fromJson(Map<String, dynamic> json) => NotificationOrderItem(
    categoryName: json['categoryName'] ?? '',
    productImage: json['productImage'] ?? json['ProductModelImage'] ?? '',  // Fallback for old data
    quantity: json['quantity'] ?? 1,
    price: (json['price'] ?? 0.0).toDouble(),
  );
}

// ============================================================================
// NOTIFICATION MODEL - Single Notification Data
// ============================================================================
// This model represents one notification (e.g., "Order Confirmed")
// Includes basic info (title, body) and optional order details
// ============================================================================

class NotificationModel {
  final String? id;           // Firebase unique key
  final String title;         // Notification title (e.g., "Order Confirmed")
  final String body;          // Notification message
  final DateTime timestamp;   // When notification was created
  bool isRead;                // Has user seen this notification?
  
  // Optional order details (only for order-related notifications)
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

  // Convert to JSON for saving to Firebase
  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),  // Convert DateTime to string
    'isRead': isRead,
    'orderId': orderId,
    'totalAmount': totalAmount,
    'paymentMethod': paymentMethod,
    'orderItems': orderItems?.map((x) => x.toJson()).toList(),
  };

  // Create from JSON when loading from Firebase
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

// ============================================================================
// NOTIFICATION CONTROLLER - Manages App Notifications
// ============================================================================
// This controller handles all notifications using Firebase Realtime Database
// Notifications sync in real-time across all user's devices
//
// Features:
// - Real-time sync with Firebase
// - Add new notifications
// - Remove notifications
// - Mark as read/unread
// - Count unread notifications
// - Show local popup notifications
//
// Used for:
// - Order confirmations
// - Shipping updates
// - Promotional messages
// ============================================================================

class NotificationController extends ChangeNotifier {
  List<NotificationModel> _notifications = [];  // Private list of notifications
  final FirebaseDatabase _db = FirebaseDatabase.instance;  // Firebase Realtime Database
  final FirebaseAuth _auth = FirebaseAuth.instance;        // To get current user
  
  // Constructor - sets up real-time sync when controller is created
  NotificationController() {
    _initRealtimeSync();
  }

  // Public getter - returns unmodifiable list (can't be changed directly)
  List<NotificationModel> get notifications => List<NotificationModel>.unmodifiable(_notifications);
  
  // Count how many notifications are unread
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // ============================================================================
  // SETUP REAL-TIME SYNC - Listen for Firebase Changes
  // ============================================================================
  // This sets up a listener that automatically updates when Firebase data changes
  // Works like a live connection - any change in Firebase instantly updates the app
  void _initRealtimeSync() {
    final user = _auth.currentUser;
    if (user == null) return;  // No user logged in, can't sync

    // Listen to Firebase path: notifications/{userId}
    _db.ref('notifications/${user.uid}').onValue.listen((event) {
      // Get data from Firebase
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      
      if (data == null) {
        // No notifications in Firebase
        _notifications = [];
      } else {
        // Convert Firebase data to NotificationModel objects
        final List<NotificationModel> loadedNotifications = [];
        data.forEach((key, value) {
          loadedNotifications.add(
            NotificationModel.fromJson(Map<String, dynamic>.from(value), key.toString())
          );
        });
        
        // Sort by newest first (most recent at top)
        loadedNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _notifications = loadedNotifications;
      }
      
      // Update UI with new notifications
      notifyListeners();
    });
  }

  // ============================================================================
  // ADD NOTIFICATION - Create New Notification
  // ============================================================================
  // Adds notification to Firebase and shows local popup
  Future<void> addNotification(
    String title, 
    String body, {
    String? orderId,
    double? totalAmount,
    String? paymentMethod,
    List<NotificationOrderItem>? orderItems,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;  // No user logged in

    // Create new notification object
    final newNotification = NotificationModel(
      title: title,
      body: body,
      timestamp: DateTime.now(),
      orderId: orderId,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      orderItems: orderItems,
    );

    try {
      // Save to Firebase (push() generates unique ID)
      await _db.ref('notifications/${user.uid}').push().set(newNotification.toJson());
      
      // Show local popup notification on device
      await NotificationService.showOrderNotification(title: title, body: body);
    } catch (e) {
      debugPrint("Error adding notification to Firebase: $e");
    }
  }

  // ============================================================================
  // REMOVE NOTIFICATION - Delete Single Notification
  // ============================================================================
  Future<void> removeNotification(NotificationModel notification) async {
    final user = _auth.currentUser;
    if (user == null || notification.id == null) return;

    try {
      // Remove from Firebase
      await _db.ref('notifications/${user.uid}/${notification.id}').remove();
      // Real-time listener will automatically update _notifications list
    } catch (e) {
      debugPrint("Error removing notification from Firebase: $e");
    }
  }

  // ============================================================================
  // MARK ALL AS READ - Clear Notification Badge
  // ============================================================================
  // Updates all unread notifications to read status in Firebase
  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Prepare batch update (more efficient than updating one by one)
      final updates = <String, dynamic>{};
      for (var n in _notifications) {
        if (!n.isRead && n.id != null) {
          updates['notifications/${user.uid}/${n.id}/isRead'] = true;
        }
      }
      
      // Apply all updates at once
      if (updates.isNotEmpty) {
        await _db.ref().update(updates);
      }
      // Real-time listener will automatically update _notifications list
    } catch (e) {
      debugPrint("Error marking notifications as read: $e");
    }
  }

  // ============================================================================
  // CLEAR ALL NOTIFICATIONS - Delete Everything
  // ============================================================================
  Future<void> clearNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Remove entire notifications node for this user
      await _db.ref('notifications/${user.uid}').remove();
      // Real-time listener will automatically update _notifications list to empty
    } catch (e) {
      debugPrint("Error clearing notifications: $e");
    }
  }
}

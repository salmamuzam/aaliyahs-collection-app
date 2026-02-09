import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aaliyahs_collection_estore/data/services/notification_service.dart';
import 'package:aaliyahs_collection_estore/features/personalization/models/notification_model.dart';
import 'package:aaliyahs_collection_estore/features/personalization/models/notification_item_model.dart';


// This controller handles all notifications using Firebase Realtime Database
// Notifications sync in real-time across all user's devices


class NotificationController extends ChangeNotifier {
  List<NotificationModel> _notifications = [];  
  final FirebaseDatabase _db = FirebaseDatabase.instance;  // Firebase Realtime Database
  final FirebaseAuth _auth = FirebaseAuth.instance;        // To get current user
  
  // sets up real-time sync when controller is created
  NotificationController() {
    _initRealtimeSync();
  }

  // returns unmodifiable list 
  List<NotificationModel> get notifications => List<NotificationModel>.unmodifiable(_notifications);
  
  // Count how many notifications are unread
  int get unreadCount => _notifications.where((n) => !n.isRead).length;


  // This sets up a listener that automatically updates when Firebase data changes

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
        
        // Sort by newest first
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
      // 1. Show local popup notification IMMEDIATELY 
      await NotificationService.showOrderNotification(title: title, body: body);

      // 2. Save to Firebase in background for history
      _db.ref('notifications/${user.uid}').push().set(newNotification.toJson()).catchError((e) {
         debugPrint('Background Firebase Sync Error: $e');
      });
    } catch (e) {
      debugPrint('Error triggering notification: $e');
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
      debugPrint('Error removing notification from Firebase: $e');
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
      // Prepare batch update 
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
      debugPrint('Error marking notifications as read: $e');
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
      debugPrint('Error clearing notifications: $e');
    }
  }
}

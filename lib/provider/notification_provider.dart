
import 'package:flutter/material.dart';

/// Model representing a single notification event.
class NotificationModel {
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationModel({required this.title, required this.body, required this.timestamp});
}

/// Manages the list of application notifications received during the session.
class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];

  /// Returns an unmodifiable list of current notifications.
  List<NotificationModel> get notifications => List<NotificationModel>.unmodifiable(_notifications);
  
  /// Total count of unread notifications.
  int get unreadCount => _notifications.length; 

  /// Adds a new notification to the top of the list.
  void addNotification(String title, String body) {
    _notifications.insert(0, NotificationModel(
      title: title,
      body: body,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Removes all notifications from the list.
  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}

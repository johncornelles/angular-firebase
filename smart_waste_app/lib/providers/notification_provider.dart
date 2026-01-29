import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';

/// Notification state provider
class NotificationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  StreamSubscription? _notificationsSubscription;

  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  List<NotificationModel> get priorityNotifications =>
      _notifications.where((n) => n.type == 'critical' || n.type == 'admin_alert').toList();
  int get unreadCount => unreadNotifications.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize with zone ID
  void init(String zoneId) {
    _listenToNotifications(zoneId);
  }

  /// Listen to notifications for a zone
  void _listenToNotifications(String zoneId) {
    _notificationsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _notificationsSubscription = _firestoreService
        .streamNotifications(zoneId)
        .listen(
      (notifications) {
        _notifications = notifications;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestoreService.markNotificationAsRead(notificationId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String zoneId) async {
    try {
      await _firestoreService.markAllNotificationsAsRead(zoneId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}

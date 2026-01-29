import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Notification model for in-app notifications
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // "critical" | "admin_alert" | "info" | "system"
  final DateTime createdAt;
  final bool isRead;
  final String? zoneId;
  final String? scheduleId;
  final String? imageUrl;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.zoneId,
    this.scheduleId,
    this.imageUrl,
    this.actionUrl,
  });

  /// Create NotificationModel from Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'info',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      zoneId: data['zoneId'],
      scheduleId: data['scheduleId'],
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
    );
  }

  /// Convert NotificationModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
      if (zoneId != null) 'zoneId': zoneId,
      if (scheduleId != null) 'scheduleId': scheduleId,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (actionUrl != null) 'actionUrl': actionUrl,
    };
  }

  /// Get notification type color
  Color get typeColor {
    switch (type) {
      case 'critical':
        return AppTheme.statusDelayed;
      case 'admin_alert':
        return AppTheme.gold;
      case 'system':
        return AppTheme.statusCompleted;
      case 'info':
      default:
        return AppTheme.textSecondary;
    }
  }

  /// Get notification type icon
  IconData get typeIcon {
    switch (type) {
      case 'critical':
        return Icons.local_shipping;
      case 'admin_alert':
        return Icons.inventory_2;
      case 'system':
        return Icons.verified;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }

  /// Get formatted time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}M AGO';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}H AGO';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}D AGO';
    } else {
      return '${(difference.inDays / 7).floor()}W AGO';
    }
  }

  /// Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? createdAt,
    bool? isRead,
    String? zoneId,
    String? scheduleId,
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      zoneId: zoneId ?? this.zoneId,
      scheduleId: scheduleId ?? this.scheduleId,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}

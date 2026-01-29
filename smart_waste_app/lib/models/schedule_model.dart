import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Schedule model representing a waste collection schedule
class ScheduleModel {
  final String scheduleId;
  final String zoneId;
  final DateTime date;
  final String pickupTime;
  final String status; // "On Time" | "Delayed" | "Cancelled" | "Completed" | "Pending"
  final String message;
  final DateTime updatedAt;
  final String? zoneName;
  final bool isRecurring;
  final String? specialInstructions;

  ScheduleModel({
    required this.scheduleId,
    required this.zoneId,
    required this.date,
    required this.pickupTime,
    required this.status,
    required this.message,
    required this.updatedAt,
    this.zoneName,
    this.isRecurring = false,
    this.specialInstructions,
  });

  /// Create ScheduleModel from Firestore document
  factory ScheduleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScheduleModel(
      scheduleId: doc.id,
      zoneId: data['zoneId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      pickupTime: data['pickupTime'] ?? '',
      status: data['status'] ?? 'Pending',
      message: data['message'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      zoneName: data['zoneName'],
      isRecurring: data['isRecurring'] ?? false,
      specialInstructions: data['specialInstructions'],
    );
  }

  /// Convert ScheduleModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'zoneId': zoneId,
      'date': Timestamp.fromDate(date),
      'pickupTime': pickupTime,
      'status': status,
      'message': message,
      'updatedAt': FieldValue.serverTimestamp(),
      if (zoneName != null) 'zoneName': zoneName,
      'isRecurring': isRecurring,
      if (specialInstructions != null) 'specialInstructions': specialInstructions,
    };
  }

  /// Get status color based on current status
  Color get statusColor {
    switch (status) {
      case 'On Time':
        return AppTheme.statusOnTime;
      case 'Delayed':
        return AppTheme.statusDelayed;
      case 'Cancelled':
        return AppTheme.statusCancelled;
      case 'Completed':
        return AppTheme.statusCompleted;
      case 'Pending':
      default:
        return AppTheme.statusPending;
    }
  }

  /// Get status icon based on current status
  IconData get statusIcon {
    switch (status) {
      case 'On Time':
        return Icons.check_circle;
      case 'Delayed':
        return Icons.warning;
      case 'Cancelled':
        return Icons.cancel;
      case 'Completed':
        return Icons.done_all;
      case 'Pending':
      default:
        return Icons.schedule;
    }
  }

  /// Check if schedule is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if schedule is upcoming (future date)
  bool get isUpcoming {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduleDate = DateTime(date.year, date.month, date.day);
    return scheduleDate.isAfter(today);
  }

  /// Create a copy with updated fields
  ScheduleModel copyWith({
    String? scheduleId,
    String? zoneId,
    DateTime? date,
    String? pickupTime,
    String? status,
    String? message,
    DateTime? updatedAt,
    String? zoneName,
    bool? isRecurring,
    String? specialInstructions,
  }) {
    return ScheduleModel(
      scheduleId: scheduleId ?? this.scheduleId,
      zoneId: zoneId ?? this.zoneId,
      date: date ?? this.date,
      pickupTime: pickupTime ?? this.pickupTime,
      status: status ?? this.status,
      message: message ?? this.message,
      updatedAt: updatedAt ?? this.updatedAt,
      zoneName: zoneName ?? this.zoneName,
      isRecurring: isRecurring ?? this.isRecurring,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  String toString() {
    return 'ScheduleModel(scheduleId: $scheduleId, zoneId: $zoneId, date: $date, status: $status)';
  }
}

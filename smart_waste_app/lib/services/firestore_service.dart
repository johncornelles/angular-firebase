import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/zone_model.dart';
import '../models/schedule_model.dart';
import '../models/notification_model.dart';
import '../config/constants.dart';

/// Firestore service for all database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ USER OPERATIONS ============

  /// Get user by ID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  /// Stream user data
  Stream<UserModel?> streamUser(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Update user data
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  // ============ ZONE OPERATIONS ============

  /// Get all zones
  Future<List<ZoneModel>> getZones() async {
    final snapshot = await _firestore
        .collection(AppConstants.zonesCollection)
        .orderBy('zoneName')
        .get();
    return snapshot.docs.map((doc) => ZoneModel.fromFirestore(doc)).toList();
  }

  /// Stream all zones
  Stream<List<ZoneModel>> streamZones() {
    return _firestore
        .collection(AppConstants.zonesCollection)
        .orderBy('zoneName')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ZoneModel.fromFirestore(doc)).toList());
  }

  /// Get zone by ID
  Future<ZoneModel?> getZone(String zoneId) async {
    final doc = await _firestore
        .collection(AppConstants.zonesCollection)
        .doc(zoneId)
        .get();
    return doc.exists ? ZoneModel.fromFirestore(doc) : null;
  }

  /// Create a new zone (admin only)
  Future<String> createZone(ZoneModel zone) async {
    final docRef = await _firestore
        .collection(AppConstants.zonesCollection)
        .add(zone.toFirestore());
    return docRef.id;
  }

  // ============ SCHEDULE OPERATIONS ============

  /// Stream schedules for a specific zone (real-time)
  Stream<List<ScheduleModel>> streamSchedulesByZone(String zoneId) {
    return _firestore
        .collection(AppConstants.schedulesCollection)
        .where('zoneId', isEqualTo: zoneId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ScheduleModel.fromFirestore(doc)).toList());
  }

  /// Stream all schedules (admin view)
  Stream<List<ScheduleModel>> streamAllSchedules() {
    return _firestore
        .collection(AppConstants.schedulesCollection)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ScheduleModel.fromFirestore(doc)).toList());
  }

  /// Stream today's schedules for a zone
  Stream<List<ScheduleModel>> streamTodaySchedules(String zoneId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(AppConstants.schedulesCollection)
        .where('zoneId', isEqualTo: zoneId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ScheduleModel.fromFirestore(doc)).toList());
  }

  /// Stream upcoming schedules for a zone
  Stream<List<ScheduleModel>> streamUpcomingSchedules(String zoneId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _firestore
        .collection(AppConstants.schedulesCollection)
        .where('zoneId', isEqualTo: zoneId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('date')
        .limit(10)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ScheduleModel.fromFirestore(doc)).toList());
  }

  /// Get schedule by ID
  Future<ScheduleModel?> getSchedule(String scheduleId) async {
    final doc = await _firestore
        .collection(AppConstants.schedulesCollection)
        .doc(scheduleId)
        .get();
    return doc.exists ? ScheduleModel.fromFirestore(doc) : null;
  }

  /// Create a new schedule (admin only)
  Future<String> createSchedule(ScheduleModel schedule) async {
    final docRef = await _firestore
        .collection(AppConstants.schedulesCollection)
        .add(schedule.toFirestore());
    return docRef.id;
  }

  /// Update schedule (admin only)
  Future<void> updateSchedule(String scheduleId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection(AppConstants.schedulesCollection)
        .doc(scheduleId)
        .update(data);
  }

  /// Update schedule status (admin only)
  Future<void> updateScheduleStatus(
    String scheduleId,
    String status, {
    String? message,
  }) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (message != null) {
      data['message'] = message;
    }
    await _firestore
        .collection(AppConstants.schedulesCollection)
        .doc(scheduleId)
        .update(data);
  }

  /// Delete schedule (admin only)
  Future<void> deleteSchedule(String scheduleId) async {
    await _firestore
        .collection(AppConstants.schedulesCollection)
        .doc(scheduleId)
        .delete();
  }

  // ============ NOTIFICATION OPERATIONS ============

  /// Stream notifications for a user
  Stream<List<NotificationModel>> streamNotifications(String zoneId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('zoneId', isEqualTo: zoneId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList());
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection(AppConstants.notificationsCollection)
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Mark all notifications as read for a zone
  Future<void> markAllNotificationsAsRead(String zoneId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection(AppConstants.notificationsCollection)
        .where('zoneId', isEqualTo: zoneId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ============ ADMIN STATISTICS ============

  /// Get schedule statistics for admin dashboard
  Future<Map<String, dynamic>> getScheduleStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Get all zones count
    final zonesSnapshot = await _firestore
        .collection(AppConstants.zonesCollection)
        .count()
        .get();

    // Get today's schedules
    final todaySnapshot = await _firestore
        .collection(AppConstants.schedulesCollection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    int totalToday = todaySnapshot.docs.length;
    int delayedCount = 0;
    
    for (final doc in todaySnapshot.docs) {
      if (doc.data()['status'] == 'Delayed') {
        delayedCount++;
      }
    }

    return {
      'totalZones': zonesSnapshot.count,
      'todayPickups': totalToday,
      'delayedCount': delayedCount,
    };
  }
}

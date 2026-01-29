import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/schedule_model.dart';
import '../models/zone_model.dart';
import '../services/firestore_service.dart';

/// Schedule state provider with real-time updates
class ScheduleProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<ScheduleModel> _schedules = [];
  List<ScheduleModel> _todaySchedules = [];
  List<ZoneModel> _zones = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentZoneId;
  
  StreamSubscription? _schedulesSubscription;
  StreamSubscription? _todaySubscription;
  StreamSubscription? _zonesSubscription;

  List<ScheduleModel> get schedules => _schedules;
  List<ScheduleModel> get todaySchedules => _todaySchedules;
  List<ScheduleModel> get upcomingSchedules => 
      _schedules.where((s) => s.isUpcoming || s.isToday).toList();
  List<ZoneModel> get zones => _zones;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize with zone ID for residents
  void initForResident(String zoneId) {
    if (_currentZoneId == zoneId) return;
    _currentZoneId = zoneId;
    _listenToSchedules(zoneId);
    _listenToTodaySchedules(zoneId);
    _listenToZones();
  }

  /// Initialize for admin (all schedules)
  void initForAdmin() {
    _listenToAllSchedules();
    _listenToZones();
  }

  /// Listen to schedules for a specific zone
  void _listenToSchedules(String zoneId) {
    _schedulesSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _schedulesSubscription = _firestoreService
        .streamUpcomingSchedules(zoneId)
        .listen(
      (schedules) {
        _schedules = schedules;
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

  /// Listen to today's schedules
  void _listenToTodaySchedules(String zoneId) {
    _todaySubscription?.cancel();

    _todaySubscription = _firestoreService
        .streamTodaySchedules(zoneId)
        .listen(
      (schedules) {
        _todaySchedules = schedules;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  /// Listen to all schedules (admin)
  void _listenToAllSchedules() {
    _schedulesSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _schedulesSubscription = _firestoreService
        .streamAllSchedules()
        .listen(
      (schedules) {
        _schedules = schedules;
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

  /// Listen to zones
  void _listenToZones() {
    _zonesSubscription?.cancel();

    _zonesSubscription = _firestoreService.streamZones().listen(
      (zones) {
        _zones = zones;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  /// Get zone name by ID
  String getZoneName(String zoneId) {
    final zone = _zones.firstWhere(
      (z) => z.zoneId == zoneId,
      orElse: () => ZoneModel(zoneId: zoneId, zoneName: 'Unknown Zone'),
    );
    return zone.zoneName;
  }

  /// Create a new schedule (admin only)
  Future<bool> createSchedule(ScheduleModel schedule) async {
    try {
      await _firestoreService.createSchedule(schedule);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update schedule status (admin only)
  Future<bool> updateScheduleStatus(
    String scheduleId,
    String status, {
    String? message,
  }) async {
    try {
      await _firestoreService.updateScheduleStatus(
        scheduleId,
        status,
        message: message,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update schedule (admin only)
  Future<bool> updateSchedule(String scheduleId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateSchedule(scheduleId, data);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete schedule (admin only)
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _firestoreService.deleteSchedule(scheduleId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _schedulesSubscription?.cancel();
    _todaySubscription?.cancel();
    _zonesSubscription?.cancel();
    super.dispose();
  }
}

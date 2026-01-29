/// App-wide constants and configuration
class AppConstants {
  // App Info
  static const String appName = 'WasteAlert';
  static const String appTagline = 'Smart Waste Collection';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String zonesCollection = 'zones';
  static const String schedulesCollection = 'schedules';
  static const String notificationsCollection = 'notifications';
  
  // User Roles
  static const String roleResident = 'resident';
  static const String roleAdmin = 'admin';
  
  // Schedule Statuses
  static const String statusOnTime = 'On Time';
  static const String statusDelayed = 'Delayed';
  static const String statusCancelled = 'Cancelled';
  static const String statusCompleted = 'Completed';
  static const String statusPending = 'Pending';
  
  // FCM Topics prefix
  static const String fcmTopicPrefix = 'zone_';
  
  // Shared Preferences Keys
  static const String prefUserRole = 'user_role';
  static const String prefZoneId = 'zone_id';
  static const String prefThemeMode = 'theme_mode';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
}

/// Status enum for type safety
enum ScheduleStatus {
  onTime('On Time'),
  delayed('Delayed'),
  cancelled('Cancelled'),
  completed('Completed'),
  pending('Pending');
  
  final String value;
  const ScheduleStatus(this.value);
  
  static ScheduleStatus fromString(String value) {
    return ScheduleStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ScheduleStatus.pending,
    );
  }
}

/// User role enum
enum UserRole {
  resident('resident'),
  admin('admin');
  
  final String value;
  const UserRole(this.value);
  
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.resident,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing a user in the system
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // "resident" | "admin"
  final String zoneId;
  final DateTime? createdAt;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.zoneId,
    this.createdAt,
    this.fcmToken,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'resident',
      zoneId: data['zoneId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      fcmToken: data['fcmToken'],
    );
  }

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'zoneId': zoneId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user is resident
  bool get isResident => role == 'resident';

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? zoneId,
    DateTime? createdAt,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      zoneId: zoneId ?? this.zoneId,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, role: $role, zoneId: $zoneId)';
  }
}

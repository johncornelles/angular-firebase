import 'package:cloud_firestore/cloud_firestore.dart';

/// Zone model representing a collection zone/area
class ZoneModel {
  final String zoneId;
  final String zoneName;
  final String? description;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  ZoneModel({
    required this.zoneId,
    required this.zoneName,
    this.description,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  /// Create ZoneModel from Firestore document
  factory ZoneModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ZoneModel(
      zoneId: doc.id,
      zoneName: data['zoneName'] ?? '',
      description: data['description'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert ZoneModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'zoneName': zoneName,
      if (description != null) 'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated fields
  ZoneModel copyWith({
    String? zoneId,
    String? zoneName,
    String? description,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return ZoneModel(
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ZoneModel(zoneId: $zoneId, zoneName: $zoneName)';
  }
}

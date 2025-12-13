// lib/db/models.dart
import 'package:hive/hive.dart';

// part 'models.g.dart';

// User model
@HiveType(typeId: 0)
class User {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String email;
  
  @HiveField(2)
  String name;
  
  @HiveField(3)
  String role;
  
  @HiveField(4)
  String? organization;
  
  @HiveField(5)
  String? phone;
  
  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.organization,
    this.phone,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      role: json['role'] ?? 'field_agent',
      organization: json['organization'],
      phone: json['phone'] ?? json['phone_number'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'organization': organization,
      'phone': phone,
    };
  }
}

// Disaster Report model (for offline storage)
@HiveType(typeId: 1)
class DisasterReport {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String type;
  
  @HiveField(2)
  String severity;
  
  @HiveField(3)
  double lat;
  
  @HiveField(4)
  double lng;
  
  @HiveField(5)
  String description;
  
  @HiveField(6)
  int peopleAffected;
  
  @HiveField(7)
  List<String>? photos;
  
  @HiveField(8)
  String status; // 'draft', 'pending', 'synced', 'failed'
  
  @HiveField(9)
  DateTime createdAt;
  
  DisasterReport({
    required this.id,
    required this.type,
    required this.severity,
    required this.lat,
    required this.lng,
    required this.description,
    required this.peopleAffected,
    this.photos,
    this.status = 'draft',
    required this.createdAt,
  });
}